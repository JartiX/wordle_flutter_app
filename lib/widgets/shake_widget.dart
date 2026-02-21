import 'dart:math';

import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Stream<void>? trigger;

  const ShakeWidget({super.key, required this.child, this.trigger});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.red.withValues(alpha: 0.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    widget.trigger?.listen((_) => _shake());
  }

  void _shake() {
    _controller.forward(from: 0.0).then((_) => _controller.reverse(from: 0.5));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final sineValue = sin(4 * pi * _controller.value);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: _colorAnimation.value ?? Colors.transparent,
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Transform.translate(
            offset: Offset(sineValue * 10, 0),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}