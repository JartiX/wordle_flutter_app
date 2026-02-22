import 'package:flutter/material.dart';

class AttemptsBarChart extends StatefulWidget {
  final Map<int, int> winsByAttempts;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final double maxHeight;

  const AttemptsBarChart({
    super.key,
    required this.winsByAttempts,
    required this.colorScheme,
    required this.textTheme,
    this.maxHeight = 120,
  });

  @override
  State<AttemptsBarChart> createState() => _AttemptsBarChartState();
}

class _AttemptsBarChartState extends State<AttemptsBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final int _maxWins;

  @override
  void initState() {
    super.initState();

    _maxWins = widget.winsByAttempts.values.fold<int>(
      0,
      (prev, element) => element > prev ? element : prev,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutSine,
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AttemptsBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.winsByAttempts != widget.winsByAttempts) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.winsByAttempts.entries.map((entry) {
            final attempts = entry.key;
            final wins = entry.value;
            final double fraction = _maxWins == 0
                ? 0
                : (wins / _maxWins) * _animation.value;

            final bool isMax = wins == _maxWins && wins != 0;

            const double labelHeight = 36;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                SizedBox(
                  height: widget.maxHeight + labelHeight,
                  width: 28,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        bottom: 0,
                        child: SizedBox(
                          height: widget.maxHeight,
                          width: 28,
                          child: FractionallySizedBox(
                            heightFactor: fraction,
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    widget.colorScheme.primaryContainer,
                                    widget.colorScheme.primary,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (wins > 0)
                        Positioned(
                          bottom: widget.maxHeight * fraction,
                          child: isMax
                              ? Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      bottom: 18,
                                      child: Text(
                                        wins.toString(),
                                        style: widget.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.onSurface,
                                              height: 1,
                                            ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.emoji_events_rounded,
                                      size: 20,
                                      color: Colors.amber.shade700,
                                    ),
                                  ],
                                )
                              : Text(
                                  wins.toString(),
                                  style: widget.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  attempts.toString(),
                  style: widget.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
