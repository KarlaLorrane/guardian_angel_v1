import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';

// modelos e telas
import 'profile_model.dart';
import 'contact_model.dart';
import 'profilepage.dart';
import 'historypage.dart';
import 'settingspage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ProfileAdapter());
  await Hive.openBox<Profile>('profileBox');
  Hive.registerAdapter(ContactAdapter());
  await Hive.openBox<Contact>('contactsBox');

  // Inicializa câmeras
  final cameras = await availableCameras();

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({Key? key, required this.cameras}) : super(key: key);

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
  const HomeScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _monitoring = false;
  late StreamSubscription<AccelerometerEvent> _accelSub;

  @override
  void dispose() {
    if (_monitoring) _accelSub.cancel();
    super.dispose();
  }

  Future<void> _triggerSOS() async {
    final contacts = Hive.box<Contact>('contactsBox').values.toList();
    await SosService(cameras: widget.cameras).sendAlerts(contacts: contacts);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Alertas enviados!')));
  }

  void _onImpactDetected(double magnitude) {
    if (!_monitoring) return;
    setState(() => _monitoring = false);
    _accelSub.cancel();

    bool responded = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Impacto Detectado'),
        content: Text('Impacto de \$magnitude m/s². Está tudo bem?'),
        actions: [
          TextButton(
            onPressed: () {
              responded = true;
              Navigator.of(context).pop();
            },
            child: const Text('Estou bem'),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 30), () async {
      if (!responded) {
        if (await Vibration.hasVibrator() ?? false) {
          for (int i = 0; i < 3; i++) {
            Vibration.vibrate(duration: 500);
            await Future.delayed(const Duration(seconds: 1));
          }
        }
        Navigator.of(context).pop();
        await _triggerSOS();
      }
    });
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

  Future<File> _recordVideo({int seconds = 5}) async {
    final back = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);
    final controller = CameraController(back, ResolutionPreset.high);
    await controller.initialize();
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/sos.mp4';
    await controller.startVideoRecording();
    await Future.delayed(Duration(seconds: seconds));
    final fileX = await controller.stopVideoRecording();
    await controller.dispose();
    return File(fileX.path);
  }

  Future<void> sendAlerts({required List<Contact> contacts}) async {
    final pos = await _getLocation();
    final snaps = await _capturePhotos();
    final video = await _recordVideo();
    final locUrl = 'https://maps.google.com/?q=\${pos.latitude},\${pos.longitude}';
    final msg = 'SOS EMERGÊNCIA! Local: \$locUrl';

    for (var c in contacts) {
      if (c.notificationPrefs[0]) {
        final uri = Uri.parse('sms:\${c.phone}?body=\${Uri.encodeComponent(msg)}');
        await launchUrl(uri);
      }
      if (c.notificationPrefs[1]) {
        final num = c.phone.replaceAll(RegExp(r'[^0-9]'), '');
        final uri = Uri.parse('https://wa.me/\$num?text=\${Uri.encodeComponent(msg)}');
        await launchUrl(uri);
      }
      if (c.notificationPrefs[2]) {
        final email = Email(
          recipients: [],
          subject: 'SOS – Emergência',
          body: msg,
          attachmentPaths: [
            ...snaps.map((f) => f.path), video.path
          ],
        );
        await FlutterEmailSender.send(email);
      }
    }
  }
}
