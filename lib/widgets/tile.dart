import 'dart:math';
import 'package:flutter/material.dart';
import '../models/types.dart';

class Tile extends StatefulWidget {
  const Tile(
    this.letter,
    this.hitType, {
    super.key,
    required this.size,
    this.needOpacity = false,
    this.animationDelay = 0,
  });

  final String letter;
  final HitType hitType;
  final double size;
  final bool needOpacity;
  final int animationDelay;

  @override
  State<Tile> createState() => _TileState();
}
class _TileState extends State<Tile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (widget.hitType != HitType.none) {
      Future.delayed(Duration(milliseconds: widget.animationDelay), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant Tile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hitType != widget.hitType) {
      if (widget.hitType == HitType.none) {
        _controller.reverse();
      } else {
        Future.delayed(Duration(milliseconds: widget.animationDelay), () {
          if (mounted) _controller.forward(from: 0);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBaseColor(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    switch (widget.hitType) {
      case HitType.hit:
        return const Color(0xFF4CAF50);
      case HitType.partial:
        return const Color(0xFFFFB300);
      case HitType.miss:
        return isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
            : theme.colorScheme.primary.withValues(alpha: 0.4);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = _getBaseColor(context, isDark);
    final radius = widget.size * 0.2;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final isSecondHalf = value > 0.5;
        final rotation = value * pi;
        
        final bool showFullStyle = isSecondHalf || (widget.hitType != HitType.none && value == 1.0);

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateX(rotation),
          child: Transform(
            alignment: Alignment.center,
            transform: isSecondHalf ? Matrix4.rotationX(pi) : Matrix4.identity(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: showFullStyle
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [baseColor.withValues(alpha: 0.9), baseColor],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [theme.colorScheme.primary.withValues(alpha: 0.05), theme.colorScheme.surface]
                            : [Colors.white, theme.colorScheme.primary.withValues(alpha: 0.1)],
                      ),
                boxShadow: showFullStyle
                    ? [
                        BoxShadow(
                          color: baseColor.withValues(alpha: isDark ? 0.4 : 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: showFullStyle
                      ? Colors.white24
                      : theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showFullStyle ? 0.0 : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.0,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: showFullStyle ? 0.2 : 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: widget.needOpacity ? 0.3 : 1.0,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: widget.size * 0.5,
                            fontWeight: FontWeight.w900,
                            fontFamily: theme.textTheme.titleLarge?.fontFamily,
                            color: showFullStyle
                                ? Colors.white
                                : theme.colorScheme.primary.withValues(alpha: 0.9),
                            shadows: showFullStyle
                                ? [
                                    const Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                      color: Colors.black26,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            widget.letter.trim().isEmpty ? '' : widget.letter.toUpperCase(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}