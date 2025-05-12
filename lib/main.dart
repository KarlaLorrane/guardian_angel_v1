import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

// modelos e telas
import 'profile_model.dart';
import 'profilepage.dart';
import 'historypage.dart';
import 'settingspage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ProfileAdapter());
  await Hive.openBox<Profile>('profileBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const GuardianHomePage(),
    );
  }
}

class GuardianHomePage extends StatefulWidget {
  const GuardianHomePage({super.key});

  @override
  State<GuardianHomePage> createState() => _GuardianHomePageState();
}

class _GuardianHomePageState extends State<GuardianHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const ProfilePage(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.security),
        title: const Text('Guardian Angel SOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => setState(() => _selectedIndex = 3),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
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
  const HomeScreen({super.key});

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

  void _triggerSOS() {
    // lógica de acionamento automático do SOS
    print('SOS acionado automaticamente');
    // Aqui você pode chamar a função de gravação ou envio de alerta
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
        content: Text(
            'Um impacto de \$magnitude m/s² foi detectado. Está tudo bem?'),
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

    // Aguarda 30 segundos pela resposta do usuário
    Future.delayed(const Duration(seconds: 30), () async {
      if (!responded) {
        // Vibra três vezes
        if (await Vibration.hasVibrator() ?? false) {
          for (int i = 0; i < 3; i++) {
            Vibration.vibrate(duration: 500);
            await Future.delayed(const Duration(seconds: 1));
          }
        }
        Navigator.of(context).pop(); // fecha dialog
        _triggerSOS();
      }
    });
  }

  void _toggleMonitoring() {
    setState(() => _monitoring = !_monitoring);

    if (_monitoring) {
      _accelSub = accelerometerEvents.listen((event) {
        final double sumOfSquares =
            event.x * event.x + event.y * event.y + event.z * event.z;
        final double magnitude = sqrt(sumOfSquares);
        if (magnitude > 25) {
          _onImpactDetected(magnitude);
        }
      });
    } else {
      _accelSub.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double elementHeight = kToolbarHeight;
    final double sosButtonHeight = elementHeight * 2.5;

    return Column(
      children: [
        SizedBox(
          height: elementHeight,
          child: SafeArea(
            bottom: false,
            child: Center(
              child: Image.asset(
                'assets/guardiansoslogo.png',
                height: elementHeight * 0.8,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: elementHeight,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleMonitoring,
              icon: Icon(
                _monitoring ? Icons.pause_circle : Icons.play_circle,
                color: Colors.white,
              ),
              label: Text(
                _monitoring ? 'Parar Monitoramento' : 'Ativar Monitoramento',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _monitoring ? Colors.grey : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: SizedBox(
                height: sosButtonHeight,
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.warning, color: Colors.white),
                  label: const Text(
                    'SOS',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  onPressed: () {
                    _triggerSOS();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
