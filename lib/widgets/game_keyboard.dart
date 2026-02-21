import 'package:flutter/material.dart';
import '../models/types.dart';
import '../constants/keyboard_layouts.dart';

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
        final double rowSpacing = 8.0;
        final double keyHeight =
            (constraints.maxHeight - (rowSpacing * (layout.length + 1))) /
            (layout.length * 1.2);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: layout.map((row) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: rowSpacing / 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((char) {
                    if (char == KeyboardLayouts.enterKey) {
                      return Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: SizedBox(
                            height: keyHeight,
                            child: enterButton,
                          ),
                        ),
                      );
                    }
                    return _KeyboardKey(
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

class _KeyboardKey extends StatelessWidget {
  final String label;
  final HitType status;
  final VoidCallback onTap;
  final double height;

  const _KeyboardKey({
    required this.label,
    required this.status,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool hasStatus = status != HitType.none;
    final double radius = height * 0.2;

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
      flex: label == KeyboardLayouts.deleteKey ? 3 : 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 2.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: hasStatus
                ? [
                    BoxShadow(
                      color: baseColor.withValues(alpha: isDark ? 0.5 : 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(radius),
              child: Ink(
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: hasStatus ? 0.2 : 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label == KeyboardLayouts.deleteKey
                          ? "⌫"
                          : label.toUpperCase(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: height * 0.35,
                        fontWeight: FontWeight.w900,
                        color: hasStatus
                            ? Colors.white
                            : theme.colorScheme.primary.withValues(alpha: 0.7),
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
