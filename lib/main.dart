import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/audio_player_service.dart';
import 'repositories/word_repository.dart';
import 'start_screen.dart';
import 'statistics_page.dart';
import 'controllers/audio_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/game_controller.dart';
import 'controllers/statistics_controller.dart';
import 'controllers/theme_controller.dart';
import 'services/settings_service.dart';
import 'services/statistics_service.dart';
import 'widgets/settings_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  SettingsController? _settingsController;
  AudioController? _audioController;
  GameController? _gameController;
  StatisticsController? _statisticsController;
  ThemeController? _themeController;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _settingsController = SettingsController(SettingsService());
    await _settingsController!.load();

    final currentLength = _settingsController!.wordLength.value;
    await WordRepository(currentLength).load();

    _statisticsController = StatisticsController(StatisticsService());
    await _statisticsController!.load();

    _gameController = GameController(
      _settingsController!,
      _statisticsController!,
    );
    _gameController!.init();

    _audioController = AudioController(
      AudioPlayerService(),
      _settingsController!,
    );
    _audioController!.init();
    await _audioController!.load();

    _themeController = ThemeController(_settingsController!);

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    _audioController?.handleLifecycle(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _audioController == null || _gameController == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return ValueListenableBuilder(
      valueListenable: _settingsController!.theme,
      builder: (context, theme, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: _themeController!.themeMode,

          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
              outline: Colors.deepPurple.shade300,
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

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
              outline: Colors.deepPurple.shade200,
            ),
            cardColor: Color(0xFF1E1E2E),
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
            audioController: _audioController!,
            gameController: _gameController!,
            statisticsController: _statisticsController!,
            themeMode: _themeController!.themeMode,
          ),
        );
      },
    );
  }
}

class _RootScreen extends StatelessWidget {
  final AudioController audioController;
  final GameController gameController;
  final StatisticsController statisticsController;

  final ThemeMode themeMode;

  const _RootScreen({
    required this.audioController,
    required this.gameController,
    required this.statisticsController,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("ВОРДЛИ"),
        actions: [
          IconButton(
            onPressed: () {
              audioController.playClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatisticsPage(
                    statisticsController: statisticsController,
                    audioController: audioController,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.insert_chart_outlined_rounded),
          ),
          IconButton(
            onPressed: () {
              audioController.playClick();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => SettingsWidget(
                  gameController: gameController,
                  audioController: audioController,
                ),
              );
            },
            icon: Icon(Icons.settings_rounded),
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
        child: StartScreen(
          audioController: audioController,
          gameController: gameController,
        ),
      ),
    );
  }
}
