import 'package:flutter/material.dart';
import '../models/types.dart';
import '../constants/keyboard_layouts.dart';
import 'buttons/animated_send_button.dart';

class GameKeyboard extends StatelessWidget {
  final Map<String, HitType> statuses;
  final Function(String) onKeyTap;
  final GameLanguage language;
  final Widget enterButton;

  const GameKeyboard({
    super.key,
    required this.statuses,
    required this.onKeyTap,
    required this.language,
    required this.enterButton,
  });

  @override
  Widget build(BuildContext context) {
    final layout = KeyboardLayouts.layouts[language]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double horizontalGap = 4.0;
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
                      final theme = Theme.of(context);
                      final isDark = theme.brightness == Brightness.dark;

                      bool isActive = false;
                      if (enterButton is AnimatedSendButton) {
                        isActive =
                            (enterButton as AnimatedSendButton).isEnabled;
                      }

                      final Color color = theme.colorScheme.primary;

                      final double radius = keyHeight * 0.2;

                      return Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalGap / 2,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(radius),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(
                                          alpha: isDark ? 0.4 : 0.3,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(radius),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOut,

                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isActive
                                        ? [color.withValues(alpha: 0.9), color]
                                        : [
                                            color.withValues(alpha: 0.2),
                                            color.withValues(alpha: 0.3),
                                          ],
                                  ),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeInOut,

                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withValues(
                                          alpha: isActive ? 0.2 : 0.05,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Center(child: enterButton),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return _KeyboardKey(
                      label: char,
                      status: statuses[char.toUpperCase()] ?? HitType.none,
                      onTap: () => onKeyTap(char),
                      height: keyHeight,
                      horizontalGap: horizontalGap,
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

class _KeyboardKey extends StatelessWidget {
  final String label;
  final HitType status;
  final VoidCallback onTap;
  final double height;
  final double horizontalGap;

  const _KeyboardKey({
    required this.label,
    required this.status,
    required this.onTap,
    required this.height,
    required this.horizontalGap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool hasStatus = status != HitType.none;
    final double radius = height * 0.2;

    final bool isDeleteKey = label == KeyboardLayouts.deleteKey;

    Color getBaseColor() {
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

    final baseColor = getBaseColor();

    return Expanded(
      flex: isDeleteKey ? 3 : 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: hasStatus
                ? [
                    BoxShadow(
                      color: baseColor.withValues(alpha: isDark ? 0.5 : 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(radius),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: hasStatus
                        ? [baseColor.withValues(alpha: 0.9), baseColor]
                        : [
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                          ],
                  ),
                ),
                child: Center(
                  child: isDeleteKey
                      ? Icon(
                          Icons.backspace_outlined,
                          size: height * 0.5,
                          color: hasStatus
                              ? Colors.white
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                        )
                      : Text(
                          label.toUpperCase(),
                          style: TextStyle(
                            fontSize: height * 0.45,
                            fontWeight: FontWeight.w900,
                            fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                            color: hasStatus
                                ? Colors.white
                                : theme.colorScheme.primary.withValues(
                                    alpha: 0.7,
                                  ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
