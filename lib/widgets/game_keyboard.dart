import 'package:flutter/material.dart';
import '../models/types.dart';
import '../constants/keyboard_layouts.dart';

class GameKeyboard extends StatelessWidget {
  final Map<String, HitType> statuses;
  final Function(String) onKeyTap;
  final GameLanguage language;
  final bool isEnabled;

  const GameKeyboard({
    super.key,
    required this.statuses,
    required this.onKeyTap,
    required this.language,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final layout = KeyboardLayouts.layouts[language]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double verticalGap = 6.0;

        final double totalVerticalSpacing = verticalGap * (layout.length - 1);
        final double keyHeight =
            (constraints.maxHeight - totalVerticalSpacing) / layout.length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: layout.map((row) {
              return Container(
                height: keyHeight,
                margin: EdgeInsets.only(
                  bottom: row == layout.last ? 0 : verticalGap,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: row.map((char) {
                    if (char == KeyboardLayouts.enterKey) {
                      return Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2.0,
                            vertical: 2.0,
                          ),
                          child: SizedBox(
                            height: keyHeight,
                            child: _WideEnterButton(
                              isEnabled: isEnabled,
                              onTap: () => onKeyTap(char),
                            ),
                          ),
                        ),
                      );
                    }
                    return _KeyboardKey(
                      key: ValueKey('key-$char'),
                      label: char,
                      status: statuses[char.toUpperCase()] ?? HitType.none,
                      onTap: () => onKeyTap(char),
                      height: keyHeight,
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _KeyboardKey extends StatefulWidget {
  final String label;
  final HitType status;
  final VoidCallback onTap;
  final double height;

  const _KeyboardKey({
    super.key,
    required this.label,
    required this.status,
    required this.onTap,
    required this.height,
  });

  @override
  State<_KeyboardKey> createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<_KeyboardKey>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late HitType _fromStatus;
  late HitType _toStatus;

  late AnimationController _pressController;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _fromStatus = widget.status;
    _toStatus = widget.status;

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: 1.0,
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _pressScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.90,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.90,
          end: 1.02,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.02,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_pressController);
  }

  @override
  void didUpdateWidget(covariant _KeyboardKey oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.status != widget.status) {
      _fromStatus = oldWidget.status;
      _toStatus = widget.status;
      _colorController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _pressController.forward(from: 0);
    widget.onTap();
  }

  Color _getColorForStatus(HitType status, ThemeData theme, bool isDark) {
    switch (status) {
      case HitType.hit:
        return const Color(0xFF4CAF50);
      case HitType.partial:
        return const Color(0xFFFFB300);
      case HitType.miss:
        return isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
            : theme.colorScheme.primary.withValues(alpha: 0.4);
      default:
        return theme.colorScheme.primary.withValues(alpha: 0.1);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double radius = widget.height * 0.2;
    final bool isDeleteKey = widget.label == KeyboardLayouts.deleteKey;
    final double borderWidth = 1.5;

    return Expanded(
      flex: isDeleteKey ? 3 : 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        child: AnimatedBuilder(
          animation: Listenable.merge([_colorController, _pressController]),
          builder: (context, child) {
            final double t = Curves.easeInOut.transform(_colorController.value);

            final fromColor = _getColorForStatus(_fromStatus, theme, isDark);
            final toColor = _getColorForStatus(_toStatus, theme, isDark);
            final currentColor = Color.lerp(fromColor, toColor, t)!;

            final bool fromHasStatus = _fromStatus != HitType.none;
            final bool toHasStatus = _toStatus != HitType.none;

            final double statusGlowOpacity = fromHasStatus && toHasStatus
                ? (isDark ? 0.5 : 0.4)
                : toHasStatus
                ? t * (isDark ? 0.5 : 0.4)
                : fromHasStatus
                ? (1 - t) * (isDark ? 0.5 : 0.4)
                : 0.0;

            final fromGradientColors = fromHasStatus
                ? [fromColor.withValues(alpha: 0.9), fromColor]
                : [
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                  ];

            final toGradientColors = toHasStatus
                ? [toColor.withValues(alpha: 0.9), toColor]
                : [
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                  ];

            final gradientColors = [
              Color.lerp(fromGradientColors[0], toGradientColors[0], t)!,
              Color.lerp(fromGradientColors[1], toGradientColors[1], t)!,
            ];

            final fromTextColor = fromHasStatus
                ? Colors.white
                : theme.colorScheme.primary.withValues(alpha: 0.8);
            final toTextColor = toHasStatus
                ? Colors.white
                : theme.colorScheme.primary.withValues(alpha: 0.8);
            final textColor = Color.lerp(fromTextColor, toTextColor, t)!;

            final double scale = _pressController.isAnimating
                ? _pressScale.value
                : 1.0;

            final double pressFraction = _pressController.isAnimating
                ? (1.0 - (1.0 - _pressScale.value).abs() * 5).clamp(0.3, 1.0)
                : 1.0;

            final bool showStatus = (fromHasStatus && !toHasStatus)
                ? t < 0.5
                : (toHasStatus || fromHasStatus);

            final Color borderHighlight;
            final Color borderShadowColor;

            if (showStatus && statusGlowOpacity > 0.1) {
              borderHighlight = _lighten(
                currentColor,
                0.25,
              ).withValues(alpha: 0.7);
              borderShadowColor = _darken(
                currentColor,
                0.25,
              ).withValues(alpha: 0.7);
            } else {
              if (isDark) {
                borderHighlight = Colors.white.withValues(alpha: 0.10);
                borderShadowColor = Colors.black.withValues(alpha: 0.35);
              } else {
                borderHighlight = Colors.white.withValues(alpha: 0.7);
                borderShadowColor = theme.colorScheme.primary.withValues(
                  alpha: 0.15,
                );
              }
            }

            final List<BoxShadow> shadows = [];

            if (statusGlowOpacity > 0) {
              shadows.add(
                BoxShadow(
                  color: currentColor.withValues(
                    alpha: statusGlowOpacity * pressFraction,
                  ),
                  blurRadius: 12 * pressFraction,
                  spreadRadius: 1,
                ),
              );
            }

            shadows.add(
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: (isDark ? 0.4 : 0.18) * pressFraction,
                ),
                blurRadius: 4 * pressFraction,
                offset: Offset(0, 2.5 * pressFraction),
              ),
            );

            shadows.add(
              BoxShadow(
                color:
                    (showStatus && statusGlowOpacity > 0.1
                            ? _darken(currentColor, 0.15)
                            : Colors.black)
                        .withValues(
                          alpha: (isDark ? 0.25 : 0.08) * pressFraction,
                        ),
                blurRadius: 2 * pressFraction,
                offset: Offset(0, 1 * pressFraction),
              ),
            );

            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  boxShadow: shadows,
                ),
                child: CustomPaint(
                  painter: _KeyBorderPainter(
                    radius: radius,
                    borderWidth: borderWidth,
                    highlightColor: borderHighlight,
                    shadowColor: borderShadowColor,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleTap,
                      borderRadius: BorderRadius.circular(radius),
                      child: Container(
                        margin: EdgeInsets.all(borderWidth),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            radius - borderWidth,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradientColors,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  radius - borderWidth,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(
                                      alpha:
                                          showStatus && statusGlowOpacity > 0.1
                                          ? 0.58
                                          : 0.18,
                                    ),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  radius - borderWidth,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(
                                      alpha:
                                          showStatus && statusGlowOpacity > 0.1
                                          ? 0.18
                                          : 0.09,
                                    ),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.4],
                                ),
                              ),
                            ),
                            Center(
                              child: isDeleteKey
                                  ? Icon(
                                      Icons.backspace_outlined,
                                      size: widget.height * 0.5,
                                      color: textColor,
                                    )
                                  : Text(
                                      widget.label.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: widget.height * 0.45,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: theme
                                            .textTheme
                                            .bodyMedium
                                            ?.fontFamily,
                                        color: textColor,
                                        shadows:
                                            showStatus &&
                                                statusGlowOpacity > 0.1
                                            ? [
                                                Shadow(
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 2,
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                ),
                                              ]
                                            : [],
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
          },
        ),
      ),
    );
  }
}

class _WideEnterButton extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const _WideEnterButton({required this.isEnabled, required this.onTap});

  @override
  State<_WideEnterButton> createState() => _WideEnterButtonState();
}

class _WideEnterButtonState extends State<_WideEnterButton>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseGlow;

  late final AnimationController _pressController;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseScale = Tween(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseGlow = Tween(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _pressScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.92,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.92,
          end: 1.03,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.03,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_pressController);

    if (widget.isEnabled) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _WideEnterButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEnabled && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isEnabled) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isEnabled) return;
    _pressController.forward(from: 0);
    widget.onTap();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = theme.colorScheme.primary;
    const radius = 16.0;
    const borderWidth = 2.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _pressController]),
      builder: (context, child) {
        final double pulseScale = widget.isEnabled ? _pulseScale.value : 1.0;
        final double pressScaleVal = _pressController.isAnimating
            ? _pressScale.value
            : 1.0;
        final double combinedScale = pulseScale * pressScaleVal;

        final double pressFraction = _pressController.isAnimating
            ? (1.0 - (1.0 - _pressScale.value).abs() * 5).clamp(0.3, 1.0)
            : 1.0;

        final Color borderHighlight;
        final Color borderShadowColor;

        if (widget.isEnabled) {
          borderHighlight = _lighten(color, 0.2).withValues(alpha: 0.8);
          borderShadowColor = _darken(color, 0.25).withValues(alpha: 0.8);
        } else {
          if (isDark) {
            borderHighlight = Colors.white.withValues(alpha: 0.08);
            borderShadowColor = Colors.black.withValues(alpha: 0.3);
          } else {
            borderHighlight = Colors.white.withValues(alpha: 0.6);
            borderShadowColor = color.withValues(alpha: 0.12);
          }
        }

        final List<BoxShadow> shadows = [];

        if (widget.isEnabled) {
          shadows.add(
            BoxShadow(
              color: color.withValues(
                alpha: _pulseGlow.value * (isDark ? 0.8 : 0.6) * pressFraction,
              ),
              blurRadius: 20 * pressFraction,
              spreadRadius: 2 * pressFraction,
            ),
          );
        }

        shadows.add(
          BoxShadow(
            color: Colors.black.withValues(
              alpha: (isDark ? 0.45 : 0.2) * pressFraction,
            ),
            blurRadius: 5 * pressFraction,
            offset: Offset(0, 3 * pressFraction),
          ),
        );

        shadows.add(
          BoxShadow(
            color: (widget.isEnabled ? _darken(color, 0.15) : Colors.black)
                .withValues(alpha: (isDark ? 0.3 : 0.1) * pressFraction),
            blurRadius: 2 * pressFraction,
            offset: Offset(0, 1.5 * pressFraction),
          ),
        );

        return Transform.scale(
          scale: combinedScale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: shadows,
            ),
            child: CustomPaint(
              painter: _KeyBorderPainter(
                radius: radius,
                borderWidth: borderWidth,
                highlightColor: borderHighlight,
                shadowColor: borderShadowColor,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleTap,
                  borderRadius: BorderRadius.circular(radius),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.all(borderWidth),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius - borderWidth),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isEnabled
                            ? [color.withValues(alpha: 0.9), color]
                            : [
                                color.withValues(alpha: 0.2),
                                color.withValues(alpha: 0.3),
                              ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              radius - borderWidth,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(
                                  alpha: widget.isEnabled ? 0.22 : 0.06,
                                ),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              radius - borderWidth,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(
                                  alpha: widget.isEnabled ? 0.15 : 0.04,
                                ),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.4],
                            ),
                          ),
                        ),
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "ПРОВЕРИТЬ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                fontFamily:
                                    theme.textTheme.bodyMedium?.fontFamily,
                                color: widget.isEnabled
                                    ? Colors.white
                                    : color.withValues(alpha: 0.6),
                                shadows: widget.isEnabled
                                    ? [
                                        Shadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 3,
                                          color: Colors.black.withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                      ]
                                    : [],
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
      },
    );
  }
}

class _KeyBorderPainter extends CustomPainter {
  final double radius;
  final double borderWidth;
  final Color highlightColor;
  final Color shadowColor;

  _KeyBorderPainter({
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
      ..color = highlightColor.withValues(alpha: 0.25);
    canvas.drawRRect(innerRRect, innerEdgePaint);

    final outerEdgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = shadowColor.withValues(alpha: 0.35);
    canvas.drawRRect(rrect, outerEdgePaint);
  }

  @override
  bool shouldRepaint(covariant _KeyBorderPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}
