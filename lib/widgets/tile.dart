import 'package:flutter/material.dart';
import '../models/types.dart';

class Tile extends StatefulWidget {
  const Tile(
    this.letter,
    this.hitType, {
    super.key,
    required this.size,
    this.needOpacity = false,
  });

  final String letter;
  final HitType hitType;
  final double size;
  final bool needOpacity;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> with SingleTickerProviderStateMixin {
  bool _isAnimating = false;

  @override
  void didUpdateWidget(covariant Tile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hitType != widget.hitType && widget.hitType != HitType.none) {
      animateTrigger();
    }
  }

  void animateTrigger() {
    setState(() => _isAnimating = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isAnimating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color getBaseColor() {
      switch (widget.hitType) {
        case HitType.hit:
          return const Color(0xFF4CAF50);
        case HitType.partial:
          return const Color(0xFFFFB300);
        case HitType.miss:
          return isDark ? Colors.grey.shade700 : Colors.grey.shade400;
        default:
          return Colors.transparent;
      }
    }

    final baseColor = getBaseColor();

    final boxDecoration = widget.hitType == HitType.none
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(widget.size * 0.2),
            color: isDark
                ? theme.colorScheme.primary.withValues(alpha: 0.05)
                : theme.colorScheme.primary.withValues(alpha: 0.05),
            border: Border.all(
              color: isDark ? Colors.white24 : theme.colorScheme.outline,
              width: 1.5,
            ),
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(widget.size * 0.2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor.withValues(alpha: 0.8), baseColor],
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? baseColor.withValues(alpha: 0.5) : baseColor.withValues(alpha: 0.7),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          );

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: _isAnimating ? 1.15 : 1.0,
      curve: Curves.bounceOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: widget.size,
        height: widget.size,
        decoration: boxDecoration,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.size * 0.2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Opacity(
              opacity: widget.needOpacity ? 0.3 : 1.0,
              child: Text(
                widget.letter.toUpperCase(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: widget.size * 0.5,
                  fontWeight: FontWeight.w900,
                  color: widget.hitType == HitType.none
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.white,
                  shadows: widget.hitType != HitType.none
                      ? [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
