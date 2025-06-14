import 'package:flutter/material.dart';

class CustomImageSpinner extends StatefulWidget {
  final double size;
  final Color? color;
  const CustomImageSpinner({Key? key, this.size = 48.0, this.color})
      : super(key: key);

  @override
  State<CustomImageSpinner> createState() => _CustomImageSpinnerState();
}

class _CustomImageSpinnerState extends State<CustomImageSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 6.28319, // 2*pi
            child: child,
          );
        },
        child: Image.asset(
          'assets/images/Logo_PMiniatura.png',
          color: widget.color,
        ),
      ),
    );
  }
}
