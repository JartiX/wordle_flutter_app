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

class _TileState extends State<Tile> with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  late final AnimationController _inputController;
  late final Animation<double> _inputScale;

  late final AnimationController _removeController;
  late final Animation<double> _removeScale;

  String _displayLetter = "";
  HitType _displayHitType = HitType.none;

  @override
  void initState() {
    super.initState();
    _displayLetter = widget.letter;
    _displayHitType = widget.hitType;

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    );

    if (widget.hitType != HitType.none) {
      _startFlip(widget.animationDelay);
    }

    _inputController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      value: 1.0,
    );

    _inputScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.8,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_inputController);

    _removeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      value: 1.0,
    );

    _removeScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.8,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.8,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_removeController);
  }

  void _startFlip(int delay) {
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _flipController.forward();
    });
  }

  void resetListener() {
    if (_flipController.status == AnimationStatus.reverse &&
        _flipController.value <= 0.5) {
      if (mounted) {
        setState(() {
          _displayLetter = widget.letter;
          _displayHitType = widget.hitType;
        });
      }
      _flipController.removeListener(resetListener);
    }
  }

  @override
  void didUpdateWidget(covariant Tile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.hitType != HitType.none && widget.hitType == HitType.none) {
      _displayLetter = oldWidget.letter;
      _displayHitType = oldWidget.hitType;

      if (_flipController.value > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _flipController.addListener(resetListener);
            _flipController.reverse();
          }
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _flipController.value = 1.0;
            _flipController.addListener(resetListener);
            _flipController.reverse();
          }
        });
      }
    } else if (oldWidget.hitType != widget.hitType &&
        widget.hitType != HitType.none) {
      _displayLetter = widget.letter;
      _displayHitType = widget.hitType;
      Future.delayed(Duration(milliseconds: widget.animationDelay), () {
        if (mounted) _flipController.forward(from: 0);
      });
    } else if (oldWidget.letter != widget.letter &&
        !_flipController.isAnimating) {
      if (widget.letter.isNotEmpty && oldWidget.letter.isEmpty) {
        setState(() => _displayLetter = widget.letter);
        if (widget.hitType == HitType.none) {
          _inputController.forward(from: 0);
        }
      } else if (widget.letter.isEmpty && oldWidget.letter.isNotEmpty) {
        _removeController.forward(from: 0);
        Future.delayed(const Duration(milliseconds: 80), () {
          if (mounted) {
            setState(() => _displayLetter = widget.letter);
          }
        });
      } else {
        setState(() => _displayLetter = widget.letter);
        if (widget.letter.isNotEmpty && widget.hitType == HitType.none) {
          _inputController.forward(from: 0);
        }
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _inputController.dispose();
    _removeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = widget.size * 0.18;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _flipController,
        _inputController,
        _removeController,
      ]),
      builder: (context, child) {
        final flipValue = _flipAnimation.value;
        final isSecondHalf = flipValue > 0.5;
        final baseColor = _getHitColor(context, isDark, _displayHitType);
        final bool showFullStyle =
            isSecondHalf && _displayHitType != HitType.none;

        double currentScale;
        if (_displayHitType == HitType.none) {
          if (_removeController.isAnimating) {
            currentScale = _removeScale.value;
          } else {
            currentScale = _inputScale.value;
          }
        } else {
          currentScale = 1.0;
        }

        final Color borderHighlight;
        final Color borderShadow;
        final Color outerShadowColor;
        final Color innerShadowLight;
        final Color innerShadowDark;

        if (showFullStyle) {
          final hsl = HSLColor.fromColor(baseColor);
          borderHighlight = hsl
              .withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0))
              .toColor()
              .withValues(alpha: 0.9);
          borderShadow = hsl
              .withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0))
              .toColor()
              .withValues(alpha: 0.9);
          outerShadowColor = baseColor.withValues(alpha: isDark ? 0.5 : 0.55);
          innerShadowLight = Colors.white.withValues(alpha: 0.3);
          innerShadowDark = Colors.black.withValues(alpha: 0.25);
        } else {
          if (isDark) {
            borderHighlight = Colors.white.withValues(alpha: 0.12);
            borderShadow = Colors.black.withValues(alpha: 0.4);
            outerShadowColor = Colors.black.withValues(alpha: 0.35);
            innerShadowLight = Colors.white.withValues(alpha: 0.06);
            innerShadowDark = Colors.black.withValues(alpha: 0.2);
          } else {
            borderHighlight = Colors.white.withValues(alpha: 0.85);
            borderShadow = theme.colorScheme.primary.withValues(alpha: 0.18);
            outerShadowColor = theme.colorScheme.primary.withValues(
              alpha: 0.12,
            );
            innerShadowLight = Colors.white.withValues(alpha: 0.5);
            innerShadowDark = theme.colorScheme.primary.withValues(alpha: 0.08);
          }
        }

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateX(flipValue * pi)
            ..scale(currentScale),
          child: Transform(
            alignment: Alignment.center,
            transform: isSecondHalf
                ? Matrix4.rotationX(pi)
                : Matrix4.identity(),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: outerShadowColor,
                    blurRadius: showFullStyle ? 12 : 6,
                    spreadRadius: showFullStyle ? 1 : 0,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: (showFullStyle
                        ? baseColor.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: isDark ? 0.25 : 0.08)),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                  if (showFullStyle)
                    BoxShadow(
                      color: baseColor.withValues(alpha: isDark ? 0.25 : 0.2),
                      blurRadius: 20,
                      spreadRadius: -2,
                    ),
                ],
              ),
              child: CustomPaint(
                painter: _RaisedBorderPainter(
                  radius: radius,
                  borderWidth: showFullStyle ? 2.5 : 2.0,
                  highlightColor: borderHighlight,
                  shadowColor: borderShadow,
                ),
                child: Container(
                  margin: EdgeInsets.all(showFullStyle ? 2.5 : 2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      radius - (showFullStyle ? 2.5 : 2.0),
                    ),
                    gradient: showFullStyle
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _lighten(baseColor, 0.08),
                              baseColor,
                              _darken(baseColor, 0.06),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    theme.colorScheme.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    theme.colorScheme.surfaceContainer,
                                    theme.colorScheme.surface.withValues(
                                      alpha: 0.15,
                                    ),
                                  ]
                                : [
                                    Colors.white,
                                    Colors.white.withValues(alpha: 0.95),
                                    theme.colorScheme.primary.withValues(
                                      alpha: 0.06,
                                    ),
                                  ],
                          ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            radius - (showFullStyle ? 2.5 : 2.0),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              innerShadowLight,
                              Colors.transparent,
                              Colors.transparent,
                              innerShadowDark,
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            radius - (showFullStyle ? 2.5 : 2.0),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(
                                alpha: showFullStyle ? 0.25 : 0.12,
                              ),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.45],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            radius - (showFullStyle ? 2.5 : 2.0),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(
                                alpha: showFullStyle ? 0.15 : 0.05,
                              ),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.35],
                          ),
                        ),
                      ),
                      if (showFullStyle)
                        Positioned(
                          top: -widget.size * 0.1,
                          left: -widget.size * 0.1,
                          child: Container(
                            width: widget.size * 0.7,
                            height: widget.size * 0.7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      Center(
                        child: Opacity(
                          opacity: widget.needOpacity ? 0.3 : 1.0,
                          child: Text(
                            _displayLetter.trim().toUpperCase(),
                            style: TextStyle(
                              fontSize: widget.size * 0.5,
                              fontWeight: FontWeight.w900,
                              color: showFullStyle
                                  ? Colors.white
                                  : theme.colorScheme.primary.withValues(
                                      alpha: 0.9,
                                    ),
                              shadows: showFullStyle
                                  ? [
                                      Shadow(
                                        offset: const Offset(0, 1),
                                        blurRadius: 0,
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                      const Shadow(
                                        offset: Offset(0, 2),
                                        blurRadius: 6,
                                        color: Colors.black26,
                                      ),
                                    ]
                                  : [
                                      if (!isDark)
                                        Shadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.08),
                                        ),
                                    ],
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
        );
      },
    );
  }

  Color _getHitColor(BuildContext context, bool isDark, HitType type) {
    final theme = Theme.of(context);
    switch (type) {
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

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

class _RaisedBorderPainter extends CustomPainter {
  final double radius;
  final double borderWidth;
  final Color highlightColor;
  final Color shadowColor;

  _RaisedBorderPainter({
    required this.radius,
    required this.borderWidth,
    required this.highlightColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final innerRRect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth),
      Radius.circular((radius - borderWidth).clamp(0, double.infinity)),
    );

    canvas.save();
    final outerPath = Path()..addRRect(rrect);
    final innerPath = Path()..addRRect(innerRRect);
    final borderPath = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );
    canvas.clipPath(borderPath);

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [highlightColor, highlightColor.withValues(alpha: 0.0)],
        stops: const [0.0, 0.6],
      ).createShader(rect);
    canvas.drawRRect(rrect, highlightPaint);

    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
        colors: [shadowColor, shadowColor.withValues(alpha: 0.0)],
        stops: const [0.0, 0.6],
      ).createShader(rect);
    canvas.drawRRect(rrect, shadowPaint);

    canvas.restore();

    final innerEdgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = highlightColor.withValues(alpha: 0.3);
    canvas.drawRRect(innerRRect, innerEdgePaint);

    final outerEdgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = shadowColor.withValues(alpha: 0.4);
    canvas.drawRRect(rrect, outerEdgePaint);
  }

  @override
  bool shouldRepaint(covariant _RaisedBorderPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}
