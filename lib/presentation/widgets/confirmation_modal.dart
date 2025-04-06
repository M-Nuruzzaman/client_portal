import 'package:flutter/material.dart';

import '../../utils/AppColors.dart';

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   "Terms and Conditions:",
            //   style: TextStyle(
            //     color: Colors.black,
            //     fontWeight: FontWeight.bold,
            //     fontSize: 14,
            //   ),
            // ),
            // SizedBox(height: 4),
            // Text(
            //   "• By proceeding, you agree to our terms and conditions.\n"
            //       "• Your data will be securely stored and handled.\n"
            //       "• You must comply with our policies while using this service.",
            //   style: TextStyle(
            //     color: Colors.black87,
            //     fontSize: 12,
            //   ),
            // ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
            ),
            child: Text("Confirm", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondaryBackgroundColor),),
          ),
        ],
      );
    },
  );
}
