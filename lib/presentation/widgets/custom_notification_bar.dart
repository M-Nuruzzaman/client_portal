import 'package:flutter/material.dart';

// Custom Notification Bar Widget
class CustomNotificationBar extends StatelessWidget {
  final String message;
  final Color backgroundColor;

  CustomNotificationBar({
    required this.message,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30,
      left: 0,
      right: 0,
      child: Material(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// Function to Show the Custom Notification
void showCustomNotification(BuildContext context, String message, Color backgroundColor) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => CustomNotificationBar(
      message: message,
      backgroundColor: backgroundColor,
    ),
  );

  // Insert the overlay
  overlay.insert(overlayEntry);

  // Remove the notification after 3 seconds
  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}