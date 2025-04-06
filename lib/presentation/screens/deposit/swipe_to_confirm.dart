// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
//
// class LongPressToConfirm extends StatefulWidget {
//   final VoidCallback onConfirmed;
//
//   LongPressToConfirm({required this.onConfirmed});
//
//   @override
//   _LongPressToConfirmState createState() => _LongPressToConfirmState();
// }
//
// class _LongPressToConfirmState extends State<LongPressToConfirm>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _radiusAnimation;
//   late Animation<double> _opacityAnimation;
//   bool _confirmed = false;
//   bool _isPressed = false;
//   double _radius = 80;
//   late Timer _timer; // Timer to track press duration
//   bool _isTimerRunning = false; // To check if timer is running
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 5000),
//     );
//
//     _radiusAnimation = Tween<double>(begin: 80, end: 100).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeOut,
//       ),
//     );
//
//     _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeInOut,
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _timer.cancel(); // Cancel the timer when the widget is disposed
//     super.dispose();
//   }
//
//   void _startConfirming() {
//     if (_confirmed) return;
//
//     setState(() {
//       _confirmed = true;
//       _radius = 80; // Reset radius
//     });
//     widget.onConfirmed();
//     print('Confirmed');
//   }
//
//   void _onLongPressStart() {
//     HapticFeedback.vibrate(); // Provide feedback when press starts
//     print('Long press started');
//     _isPressed = true;
//     _isTimerRunning = true;
//     _timer = Timer(Duration(seconds: 5), _startConfirming); // Start 5-second timer
//     _animationController.forward(); // Start animation
//   }
//
//   void _onLongPressEnd() {
//     if (_isTimerRunning) {
//       _timer.cancel(); // Cancel the timer if press ends before 5 seconds
//       print('Long press ended early');
//     }
//     else{
//
//     }
//     setState(() {
//       _isPressed = false;
//       _isTimerRunning = false;
//     });
//     _animationController.reverse(); // Reverse animation if press is canceled
//   }
//
//   void _onLongPressCancel() {
//     _onLongPressEnd(); // Cancel on press cancel
//     print('Long press canceled');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           GestureDetector(
//             onLongPressStart: (_) => _onLongPressStart(),
//             onLongPressEnd: (_) => _onLongPressEnd(),
//             onLongPressCancel: _onLongPressCancel,
//             onTapDown: (_) {
//               setState(() {
//                 _isPressed = true;
//               });
//               print('Tap down');
//               _animationController.forward();
//             },
//             onTapUp: (_) {
//               setState(() {
//                 _isPressed = false;
//               });
//               print('Tap up');
//               _animationController.reverse();
//             },
//             onTapCancel: () {
//               setState(() {
//                 _isPressed = false;
//               });
//               print('Tap canceled');
//               _animationController.reverse();
//             },
//             child: AnimatedBuilder(
//               animation: _animationController,
//               builder: (context, child) {
//                 return AnimatedContainer(
//                   duration: Duration(milliseconds: 5000), // Quick size change
//                   width: _isPressed ? _radiusAnimation.value : _radius,
//                   height: _isPressed ? _radiusAnimation.value : _radius,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: _confirmed ? Colors.green : Colors.blue,
//                   ),
//                   child: Center(
//                     child: Icon(
//                       _confirmed ? Icons.check : Icons.fingerprint_sharp, // Icon change
//                       size: 40,
//                       color: Colors.white,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           SizedBox(height: 20),
//           Opacity(
//             opacity: _opacityAnimation.value, // Apply opacity animation
//             child: Column(
//               children: [
//                 Text(
//                   'Long press to confirm',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   'By confirming, you agree to the risks & terms.',
//                   style: TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
