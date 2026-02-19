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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return SizedBox(
          height: widget.maxHeight + 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.winsByAttempts.entries.map((entry) {
              final attempts = entry.key;
              final wins = entry.value;
              final double fraction = _maxWins == 0
                  ? 0
                  : (wins / _maxWins) * _animation.value;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(wins != 0 ? wins.toString() : " ", style: widget.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Container(
                    height: widget.maxHeight,
                    width: 28,
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: fraction,
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
                  const SizedBox(height: 4),
                  Text(attempts.toString(), style: widget.textTheme.bodyMedium),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
