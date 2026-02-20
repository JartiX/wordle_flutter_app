import 'package:flutter/material.dart';
import '../models/word.dart';
import 'buttons/animated_restart_button.dart';
import '../controllers/audio_controller.dart';

class GameOverDialog extends StatefulWidget {
  const GameOverDialog({
    super.key,
    required this.didWin,
    required this.wordToGuess,
    required this.onPlayAgain,
    required this.audioController,
  });

  final bool didWin;
  final Word wordToGuess;
  final VoidCallback onPlayAgain;
  final AudioController audioController;

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  Future<void> _closeDialog() async {
    _controller.reverse(from: 1.0);
    setState(() {});

    await Future.delayed(_controller.duration!);

    widget.onPlayAgain();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;

    final isSmallScreen = size.width < 360;
    final isTablet = size.width > 600;

    final isWin = widget.didWin;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = isWin
        ? (isDark ? Colors.green.shade400 : Colors.green.shade600)
        : (isDark ? Colors.red.shade700 : Colors.red.shade600);

    final List<Color> gradientColors = isWin
        ? [isDark ? Colors.green.shade900 : Colors.green.shade400, primaryColor]
        : [isDark ? Colors.red.shade900 : Colors.red.shade400, primaryColor];

    final Color wordBackgroundColor = isDark
        ? Colors.grey.shade800
        : Colors.white;

    final Color wordTextColor = primaryColor;

    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    final verticalPadding = isSmallScreen ? 20.0 : 28.0;
    final maxWidth = isTablet ? 420.0 : 500.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: size.height * 0.9,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: .4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isWin ? "🎉 ТЫ ПОБЕДИЛ!" : "💀 ТЫ ПРОИГРАЛ!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "Загаданное слово было:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .9),
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),

                    const SizedBox(height: 12),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: wordBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.wordToGuess.toString().toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: wordTextColor,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
  width: double.infinity,
  child: Material(
    color: wordBackgroundColor,
    borderRadius: BorderRadius.circular(24),
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: _closeDialog,
      child: AnimatedRestartButton(
        onPressed: _closeDialog,
        isEnabled: true,
        audioController: widget.audioController,
      ),
    ),
  ),
),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
