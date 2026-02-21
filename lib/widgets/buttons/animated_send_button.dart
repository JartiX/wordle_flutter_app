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

class _AnimatedSendButtonState extends State<AnimatedSendButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowAnimation = Tween<double>(begin: 2.0, end: 12.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isEnabled) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedSendButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color iconColor = widget.isEnabled
        ? Colors.white
        : theme.colorScheme.onSurface.withValues(alpha: 0.3);

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isEnabled) return;
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (_isPressed) {
          setState(() => _isPressed = false);
          if (widget.isEnabled) {
            widget.audioController.playSend();
            widget.onPressed();
          }
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: _isPressed ? Colors.black12 : Colors.transparent,
                shape: BoxShape.rectangle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: widget.isEnabled
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(
                                  alpha: _pulseController.value * 0.4,
                                ),
                                blurRadius: _glowAnimation.value,
                                spreadRadius: _pulseController.value * 2,
                              ),
                            ]
                          : [],
                    ),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                        CurvedAnimation(
                          parent: _pulseController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Icon(
                          Icons.send_rounded,
                          color: iconColor,
                          shadows: widget.isEnabled
                              ? [
                                  const Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
