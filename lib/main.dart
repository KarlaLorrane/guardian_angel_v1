import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'profile_model.dart';
import 'contact_model.dart';
import 'alert_model.dart';

import 'profilepage.dart';
import 'historypage.dart';
import 'settingspage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ProfileAdapter());
  await Hive.openBox<Profile>('profileBox');
  Hive.registerAdapter(ContactAdapter());
  await Hive.openBox<Contact>('contactsBox');
  Hive.registerAdapter(AlertAdapter());
  await Hive.openBox<Alert>('alertsBox');
  await Hive.openBox('settingsBox');

  final cameras = await availableCameras();

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Angel SOS',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
      ),
      home: GuardianHomePage(cameras: cameras),
    );
  }
}

class GuardianHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const GuardianHomePage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<GuardianHomePage> createState() => _GuardianHomePageState();
}

class _GuardianHomePageState extends State<GuardianHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[
      HomeScreen(cameras: widget.cameras),
      const ProfilePage(),
      const HistoryPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.security),
        title: const Text('Guardian Angel SOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _onItemTapped(3),
          ),
        ],
      ),
      body: widgets[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({super.key, required this.cameras});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _monitoring = false;
  bool _sendingSOS = false;
  bool _stopSendingSOS = false;
  Timer? _sosTimer;
  late StreamSubscription<AccelerometerEvent> _accelSub;

  @override
  void dispose() {
    if (_monitoring) _accelSub.cancel();
    _sosTimer?.cancel(); // Cancelar o envio contínuo ao sair
    super.dispose();
  }

  Future<void> _triggerSOS({bool isRepeated = false}) async {
    try {
      final contacts = Hive.box<Contact>('contactsBox').values.toList();
      if (isRepeated) {
        // Verificar a bateria antes de enviar SOS repetido
        final battery = await Battery().batteryLevel;
        if (battery <= 15) {
          _stopSendingSOS = true; // Parar o envio de alertas se a bateria for menor que 15%
          return;
        }
      }

      await SosService(cameras: widget.cameras).sendAlerts(contacts: contacts);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alerta enviado!')));
    } catch (e, stack) {
      print('Erro ao acionar SOS: $e');
      print(stack);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao acionar SOS: $e')));
    }
  }

  void _onImpactDetected(double magnitude) async {
    if (!_monitoring) return;
    setState(() => _monitoring = false);
    _accelSub.cancel();

    final profileBox = Hive.box<Profile>('profileBox');
    final profile = profileBox.isNotEmpty ? profileBox.getAt(0) : null;
    final fullName = profile?.name ?? 'N/A';
    final bloodType = profile?.bloodType ?? 'N/A';
    final medicalConditions = profile?.medicalConditions ?? 'N/A';
    final vehicleInfo = profile?.vehicleInfo ?? 'N/A';

    Position? position;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (_) {
      position = null;
    }

    final locationText = position != null
        ? 'Latitude: ${position.latitude}, Longitude: ${position.longitude}'
        : 'Localização indisponível';

    bool responded = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final dialogWidth = MediaQuery.of(context).size.width * 0.95;
        final dialogHeight = MediaQuery.of(context).size.height * 0.65;

        return AlertDialog(
          title: const Text('Impacto Detectado'),
          content: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Text('''
Impacto de ${magnitude.toStringAsFixed(1)} m/s². Está tudo bem?

Informações do Perfil:
- Nome: $fullName
- Tipo Sanguíneo: $bloodType
- Condições Médicas: $medicalConditions
- Veículo: $vehicleInfo
- Localização: $locationText
'''),
                  ),
                ),
                const SizedBox(height: 8),
                if (position != null)
                  SizedBox(
                    height: dialogHeight * 0.4,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 16,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('impact_location'),
                          position: LatLng(position.latitude, position.longitude),
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      liteModeEnabled: true,
                    ),
                  )
                else
                  const Text(
                    'Mapa indisponível (sem localização)',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                responded = true;
                Navigator.of(context).pop();
              },
              child: const Text('Estou bem'),
            ),
          ],
        );
      },
    );

    Future.delayed(const Duration(seconds: 30), () async {
      if (!responded) {
        if (await Vibration.hasVibrator()) {
          for (int i = 0; i < 3; i++) {
            Vibration.vibrate(duration: 500);
            await Future.delayed(const Duration(seconds: 1));
          }
        }
        if (Navigator.canPop(context)) Navigator.of(context).pop();
        await _triggerSOS();
        _startSOSLoop(); // Iniciar o loop de envio repetido após o impacto
      }
    });
  }

  // Função para iniciar o envio contínuo
  void _startSOSLoop() {
    if (_sendingSOS || _stopSendingSOS) return;
    _sendingSOS = true;
    _sosTimer = Timer.periodic(const Duration(minutes: 15), (timer) async {
      if (_stopSendingSOS) {
        _sosTimer?.cancel();
        return;
      }
      await _triggerSOS(isRepeated: true); // Enviar SOS repetido
    });
  }

  // Função para parar o envio contínuo de SOS
  void _stopSOSLoop() {
    setState(() {
      _stopSendingSOS = true;
    });
    _sosTimer?.cancel();
  }

  void _toggleMonitoring() {
    setState(() => _monitoring = !_monitoring);
    if (_monitoring) {
      _accelSub = accelerometerEvents.listen((event) {
        final mag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        if (mag > 25) _onImpactDetected(mag);
      });
    } else {
      _accelSub.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double h = kToolbarHeight;
    final double sosH = h * 2.5;

    return Column(
      children: [
        SizedBox(
          height: h,
          child: SafeArea(
            bottom: false,
            child: Center(
              child: Image.asset('assets/guardiansoslogo.png', height: h * 0.8),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: h,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleMonitoring,
              icon: Icon(_monitoring ? Icons.pause_circle : Icons.play_circle, color: Colors.white),
              label: Text(_monitoring ? 'Parar Monitoramento' : 'Ativar Monitoramento',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _monitoring ? Colors.grey : Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: SizedBox(
              height: sosH,
              width: MediaQuery.of(context).size.width * 0.6,
              child: ElevatedButton.icon(
                onPressed: _triggerSOS,
                icon: const Icon(Icons.warning, color: Colors.white),
                label: const Text('SOS', style: TextStyle(color: Colors.white, fontSize: 24)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SosService {
  final List<CameraDescription> cameras;
  SosService({required this.cameras});

  Future<Position> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada');
      }
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<List<File>> _capturePhotos() async {
    final snaps = <File>[];
    for (var cam in cameras) {
      final controller = CameraController(cam, ResolutionPreset.medium);
      await controller.initialize();
      final xfile = await controller.takePicture();
      final dir = await getTemporaryDirectory();
      final newPath = '${dir.path}/${cam.lensDirection.name}.jpg';
      final file = File(xfile.path);
      await file.copy(newPath);
      snaps.add(File(newPath));
      await controller.dispose();
    }
    return snaps;
  }

  Future<void> sendAlerts({required List<Contact> contacts}) async {
    final profileBox = Hive.box<Profile>('profileBox');
    final profile = profileBox.isNotEmpty ? profileBox.getAt(0) : null;

    final fullName = profile?.name ?? 'N/A';
    final bloodType = profile?.bloodType ?? 'N/A';
    final medicalConditions = profile?.medicalConditions ?? 'N/A';
    final vehicleInfo = profile?.vehicleInfo ?? 'N/A';

    Position? pos;
    try {
      pos = await _getLocation();
    } catch (e) {
      print('Erro ao obter localização: $e');
    }

    final snaps = await _capturePhotos();
    final locUrl = pos != null ? 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}' : 'Localização indisponível';
    final battery = await Battery().batteryLevel;
    final msg = '''
    ⚠️ Alerta de Emergência!

    📍 Localização: $locUrl
    🔋 Bateria: $battery%

    🧾 Informações do Perfil:
    - Nome: $fullName
    - Tipo Sanguíneo: $bloodType
    - Condições Médicas: $medicalConditions
    - Veículo: $vehicleInfo
    ''';

    for (var c in contacts) {
      if (c.notificationPrefs[0]) {
        final uri = Uri.parse('sms:${c.phone}?body=${Uri.encodeComponent(msg)}');
        await launchUrl(uri);
      }
      if (c.notificationPrefs[2]) {
        final email = Email(
          recipients: [c.email ?? 'default@email.com'],
          subject: 'SOS – Emergência',
          body: msg,
          attachmentPaths: snaps.map((f) => f.path).toList(),
        );
        await FlutterEmailSender.send(email);
      }
    }

    final alertsBox = Hive.box<Alert>('alertsBox');
    alertsBox.add(Alert(
      emergencyId: DateTime.now(),
      dateTime: DateTime.now().toIso8601String(),
      locationUrl: locUrl,
      photos: snaps.map((f) => f.path).toList(),
      message: msg,
      batteryLevel: '$battery%',
      latitude: pos?.latitude ?? 0.0,
      longitude: pos?.longitude ?? 0.0,
    ));
  }
}
