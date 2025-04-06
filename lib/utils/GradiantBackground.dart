import 'package:flutter/material.dart';
import 'AppColors.dart'; // Update the path as needed

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Take full width
      height: double.infinity, // Take full height
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradiant, AppColors.gradiant1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
