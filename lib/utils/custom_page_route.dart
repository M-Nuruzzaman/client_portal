import 'package:flutter/material.dart';

// Custom Page Route
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  CustomPageRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Right to Left for forward navigation
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      // Reverse animation for when navigating back
      var reverseTween = Tween(begin: Offset.zero, end: begin).chain(CurveTween(curve: curve));
      var reverseOffsetAnimation = secondaryAnimation.drive(reverseTween);

      return SlideTransition(position: secondaryAnimation.status == AnimationStatus.reverse ? reverseOffsetAnimation : offsetAnimation, child: child);
    },
    transitionDuration: Duration(milliseconds: 500),
  );
}
