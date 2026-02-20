import 'package:flutter/material.dart';
import '../models/types.dart';

class Tile extends StatefulWidget {
  const Tile(this.letter, this.hitType, {super.key, required this.size});

  final String letter;
  final HitType hitType;
  final double size;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
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

    Future.delayed(Duration(milliseconds: 700), () {
      setState(() {
        _isAnimating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color baseColor;
    switch (widget.hitType) {
      case HitType.hit:
        baseColor = isDark ? Colors.green.shade900 : Colors.green.shade700;
        break;
      case HitType.partial:
        baseColor = isDark ? Colors.amber.shade700 : Colors.amber.shade500;
        break;
      case HitType.miss:
        baseColor = isDark ? Colors.red.shade900 : Colors.red.shade700;
        break;
      default:
        baseColor = isDark ? Colors.grey.shade800 : Colors.white;
    }

    final gradient = widget.hitType == HitType.none
        ? LinearGradient(
            colors: [
              isDark ? theme.colorScheme.surfaceBright.withValues(alpha: .4) : theme.colorScheme.onSecondary .withValues(alpha: .4),
              isDark ? theme.colorScheme.surfaceBright.withValues(alpha: .95) : theme.colorScheme.onSecondary.withValues(alpha: .95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [baseColor.withValues(alpha: .7), baseColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      scale: _isAnimating ? 1.1 : 1.0,
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? theme.colorScheme.surfaceBright .withValues(alpha: .1)
                  : theme.colorScheme.inversePrimary .withValues(alpha: .6),
              offset: const Offset(2, 4),
              blurRadius: 6,
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: .7),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            widget.letter.toUpperCase(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: widget.size * 0.45,
              fontWeight: FontWeight.bold,
              color: widget.hitType == HitType.none
                  ? (isDark ? Colors.white70 : Colors.black87)
                  : Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.black26,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
