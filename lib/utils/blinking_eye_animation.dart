import 'dart:async';
import 'package:flutter/material.dart';

class BlinkingEyeAnimation extends StatefulWidget {
  @override
  _BlinkingEyeAnimationState createState() => _BlinkingEyeAnimationState();
}

class _BlinkingEyeAnimationState extends State<BlinkingEyeAnimation> {
  bool _isBlinking = false;
  bool _isVisible = false; // Initially hidden
  Timer? _visibilityTimer;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _startBlinking();
    _startVisibilityCycle();
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _isBlinking = !_isBlinking;
      });
    });
  }

  void _startVisibilityCycle() {
    // Start immediately by showing for 3s
    _toggleVisibility();

    // Repeat the cycle every 6 seconds
    _visibilityTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _toggleVisibility();
    });
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = true;
    });

    // Hide after 3 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _visibilityTimer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50), // 50px padding from top
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _isVisible ? 1.0 : 0.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isBlinking ? Icons.remove : Icons.visibility,
              size: 40,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 20),
            Icon(
              _isBlinking ? Icons.remove : Icons.visibility,
              size: 40,
              color: Colors.white.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
