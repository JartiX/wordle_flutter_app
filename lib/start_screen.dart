import 'package:flutter/material.dart';
import 'controllers/audio_controller.dart';
import 'controllers/game_controller.dart';
import 'game_page.dart';

class StartScreen extends StatefulWidget {
  final AudioController audioController;
  final GameController gameController;

  const StartScreen({
    super.key,
    required this.audioController,
    required this.gameController,
  });

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _gameStarted = false;

  bool _isPressed = false;

  void _startGame() async {
    setState(() {
      _isPressed = true;
    });

    await Future.delayed(const Duration(milliseconds: 250));

    setState(() {
      _isPressed = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _gameStarted = true;
    });

    widget.audioController.load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: _gameStarted
          ? GamePage(
              key: const ValueKey("game"),
              audioController: widget.audioController,
              gameController: widget.gameController,
            )
          : Container(
              key: const ValueKey("start"),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1E2E), const Color(0xFF121212)]
                      : [const Color(0xFFEDE7F6), const Color(0xFFD1C4E9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: AnimatedScale(
                  scale: _isPressed ? 0.9 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "ИГРАТЬ",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
