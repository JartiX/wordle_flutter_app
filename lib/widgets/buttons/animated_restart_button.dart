import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../controllers/audio_controller.dart';

class AnimatedRestartButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  final VoidCallback? pressCallback;
  final AudioController audioController;

  const AnimatedRestartButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
    this.pressCallback,
    required this.audioController,
  });

  @override
  State<AnimatedRestartButton> createState() => _AnimatedRestartButtonState();
}

class _AnimatedRestartButtonState extends State<AnimatedRestartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Вращение: 0 -> 2π
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Масштаб: 1 -> 0.7 -> 1
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.7,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.7,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (!widget.isEnabled) return;

    widget.audioController.playClick();

    await _controller.forward(from: 0.0);

    widget.onPressed();
    widget.pressCallback?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color enabledColor = widget.isEnabled
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: .5);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          );
        },
        child: Icon(Icons.refresh, color: enabledColor, size: 32),
      ),
    );
  }
}
