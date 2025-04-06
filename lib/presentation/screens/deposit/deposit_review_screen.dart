import 'package:client_portal/presentation/screens/deposit/deposit_history_screen.dart';
import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:flutter/material.dart';

import '../../../utils/custom_page_route.dart';
import '../../widgets/custom_appbar.dart';
import '../home/account_screen.dart';    // Import AccountPage

class DepositReviewScreen extends StatelessWidget {
  const DepositReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(
      //   title: "Fund Deposit Successfully",
      //   titleColor: Colors.white,
      //   onLeadingButtonPressed: () {
      //     Navigator.pop(context);
      //   },
      //   showBackButton: false,
      // ),
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.orangeAccent,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Your deposit is under review',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We will notify you once it is processed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // Add Profile Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CustomPageRoute(page: DepositsScreen()),
                  );
                },
                child: const Text(
                  'Go to Deposit History',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
