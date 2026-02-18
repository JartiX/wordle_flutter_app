import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/audio_player_service.dart';
import 'repositories/word_repository.dart';
import 'start_screen.dart';
import 'controllers/shared_preferences_controller.dart';
import 'controllers/audio_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await WordRepository().load();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AudioController _audioController;

  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _audioController = AudioController(
      AudioPlayerService(),
      SharedPreferencesController(),
    );

    _audioController.load().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _audioController.playBackground();
      });
      setState(() {});
    });
  }

  void _onAudioButtonPressed() async {
    _audioController.toggleAudio();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

      // 🌞 Светлая тема
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.deepPurple.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.black87,
          ),
          iconTheme: IconThemeData(color: Colors.deepPurple.shade300),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple.shade300,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // 🌚 Тёмная тема
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFBB86FC),
          onPrimary: Colors.white,
          secondary: Color(0xFF03DAC6),
          onSecondary: Colors.black,
          error: Color(0xFFCF6679),
          onError: Colors.white,
          surface: Color(0xFF1E1E2E),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Color(0xFFBB86FC)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBB86FC),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      home: _RootScreen(
        audioController: _audioController,
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
        onToggleAudio: _onAudioButtonPressed,
      ),
    );
  }
}

class _RootScreen extends StatelessWidget {
  final AudioController audioController;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleAudio;

  const _RootScreen({
    required this.audioController,
    required this.themeMode,
    required this.onToggleTheme,
    required this.onToggleAudio,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("ВОРДЛИ"),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: audioController.audioMuted,
            builder: (context, muted, _) {
              return IconButton(
                onPressed: onToggleAudio,
                icon: Icon(muted ? Icons.volume_off : Icons.volume_up),
              );
            },
          ),
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF1E1E2E), Color(0xFF121212)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFF3E5F5), Color(0xFFEDE7F6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: StartScreen(audioController: audioController),
      ),
    );
  }
}
