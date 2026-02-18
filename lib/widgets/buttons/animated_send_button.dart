import 'package:flutter/material.dart';
import '../../controllers/audio_controller.dart';

class AnimatedSendButton extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback onPressed;
  final AudioController audioController;

  const AnimatedSendButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
    required this.audioController,
  });

  @override
  State<AnimatedSendButton> createState() => _AnimatedSendButtonState();
}

class _AnimatedSendButtonState extends State<AnimatedSendButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color enabledColor = widget.isEnabled
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: .5);
    final Color backgroundColor = _isPressed
        ? (theme.brightness == Brightness.dark
              ? Colors.white12
              : Colors.black12)
        : Colors.transparent;

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isEnabled) return;
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.isEnabled) {
          widget.audioController.playSend();
          widget.onPressed();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: AnimatedScale(
          scale: _isPressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Icon(Icons.send_rounded, color: enabledColor, size: 32),
        ),
      ),
    );
  }
}
