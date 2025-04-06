import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomLoader extends StatelessWidget {
  final double size;
  final Duration speed;

  const CustomLoader({
    Key? key,
    this.size = 50.0,
    this.speed = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.7),
          ),
        ),
        Center(
          child: SizedBox(
            width: size * 2.5,
            height: size * 2.5,
            child: _RotatingCircleLoader(size: size),
          ),
        ),
      ],
    );
  }
}

class _RotatingCircleLoader extends StatefulWidget {
  final double size;

  const _RotatingCircleLoader({Key? key, required this.size}) : super(key: key);

  @override
  _RotatingCircleLoaderState createState() => _RotatingCircleLoaderState();
}

class _RotatingCircleLoaderState extends State<_RotatingCircleLoader> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi, // Rotating the circle
          child: CustomPaint(
            size: Size(widget.size * 2, widget.size * 2),
            painter: _CirclePainter(),
          ),
        );
      },
    );
  }
}

class _CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Paint paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 5.0  // Increased width of the bars
      ..style = PaintingStyle.stroke; // To draw only the outline (lines)

    // The angle for one section is 120 degrees (1/3 of the circle)
    final double angle = math.pi / 3;

    // Drawing the elements on the outer circle (outer edge)
    for (int i = 0; i < 6; i++) {
      if(i%2==1)continue;
      double startAngle = i * angle - math.pi / 2;
      double endAngle = (i + 1) * angle - math.pi / 2;

      // Calculate the start and end position for each element on the circle's perimeter
      final double xStart = size.width / 2 + radius * math.cos(startAngle);
      final double yStart = size.height / 2 + radius * math.sin(startAngle);

      final double xEnd = size.width / 2 + radius * math.cos(endAngle);
      final double yEnd = size.height / 2 + radius * math.sin(endAngle);

      // Draw the element as a line (5px wide) from start to end position
      canvas.drawLine(Offset(xStart, yStart), Offset(xEnd, yEnd), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

void showCustomLoader(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const CustomLoader(),
  );
}

void hideCustomLoader(BuildContext context) {
  Navigator.of(context).pop();
}
