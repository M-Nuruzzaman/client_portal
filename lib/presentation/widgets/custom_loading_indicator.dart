import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class RamadanMoonLoader extends StatefulWidget {
  final double size;
  final Color blueMoonColor;
  final Color yellowMoonColor;
  final Duration animationDuration;

  const RamadanMoonLoader({
    Key? key,
    this.size = 80.0,
    this.blueMoonColor = Colors.blue,
    this.yellowMoonColor = Colors.yellow,
    this.animationDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _RamadanMoonLoaderState createState() => _RamadanMoonLoaderState();
}

class _RamadanMoonLoaderState extends State<RamadanMoonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.animationDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred Background for everything
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.withOpacity(0.2), // Optional background color
          ),
        ),

        // Loader (with blur applied to all elements)
        Center(
          child: SizedBox(
            height: widget.size,
            width: widget.size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Blue Moon
                    Transform.rotate(
                      angle: _controller.value * 2 * pi + pi / 4, // Added pi/4 offset
                      child: CustomPaint(
                        size: Size(widget.size / 1.4, widget.size / 1.4),
                        painter: MoonPainter(widget.blueMoonColor),
                      ),
                    ),

                    // Yellow Moon
                    Transform.rotate(
                      angle: -_controller.value * 2 * pi + pi / 4, // Added pi/4 offset
                      child: CustomPaint(
                        size: Size(widget.size / 1.4, widget.size / 1.4),
                        painter: MoonPainter(widget.yellowMoonColor),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class MoonPainter extends CustomPainter {
  final Color color;

  MoonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final double center = radius;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final moonRect = Rect.fromCircle(
      center: Offset(center, center),
      radius: radius * 1.2, // Increased radius
    );

    // Draw Shadow
    canvas.drawArc(
      moonRect.translate(3, 3),
      -pi / 4,
      pi / 2,
      false,
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );

    canvas.drawArc(
      moonRect,
      -pi / 4,
      pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant MoonPainter oldDelegate) =>
      oldDelegate.color != color;
}

// Example usage in any widget:
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ramadan Moon Loader Example'),
      ),
      body: Center(
        child: RamadanMoonLoader(
          size: 100,
          blueMoonColor: Colors.blue[300]!,
          yellowMoonColor: Colors.yellow[300]!,
          animationDuration: const Duration(milliseconds: 1000),
        ),
      ),
    );
  }
}
