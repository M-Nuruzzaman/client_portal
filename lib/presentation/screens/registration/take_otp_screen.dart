import 'dart:async';
import 'package:client_portal/presentation/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:client_portal/utils/AppColors.dart';
import '../../widgets/custom_notification_bar.dart';
import '../../widgets/reusable_button.dart';

class TakeOtpScreen extends StatefulWidget {
  final Function? onResendOtp;// Function to call when OTP is resent
  final Function? submitWithOtp;// Function to call when OTP is submit

  const TakeOtpScreen({super.key,required this.onResendOtp, this.submitWithOtp});

  @override
  _TakeOtpScreenState createState() => _TakeOtpScreenState();
}

class _TakeOtpScreenState extends State<TakeOtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(4, (index) => TextEditingController());
  bool _isLoading = false;
  int _countdown = 30;
  late Timer _timer;

  void _startCountdown() {
    // Start the countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  void _submitOtp() async{
    String otp = _controllers.map((controller) => controller.text).join();

    if (otp.length < 4) {
      showCustomNotification(context, "Please enter a 4-digit OTP!", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await widget.submitWithOtp!(otp);
    // Start the countdown after submitting OTP
    setState(() {
      _isLoading = false;
    });
    _startCountdown();
  }

  Future<void> _resendOtp() async {
    if (_countdown > 0) {
      showCustomNotification(context, "You can resend OTP in $_countdown", Colors.red);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    await widget.onResendOtp!();

    showCustomNotification(context, "OTP resent!", Colors.green);
    setState(() {
      _isLoading = false;
    });
    setState(() {
      _countdown = 30;
    });
    // Start a new countdown
    _startCountdown();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _countdown = 30; // Reset the countdown to 30 seconds
    });
    _startCountdown();
  }

  @override
  void dispose() {
    // Clean up the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/background.jpg', // Make sure this image is in the assets folder
            fit: BoxFit.cover,
          ),
          // Main content
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter the 4-digit OTP',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _controllers[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(fontSize: 24, color: Colors.white),
                          decoration: const InputDecoration(
                            counterText: '',
                            hintText: '-',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 24),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 3) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: "Verify OTP",
                    onPressed: _submitOtp,
                    backgroundColor: AppColors.buttonColor,
                    textColor: AppColors.secondaryBackgroundColor,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Resend OTP in: $_countdown',
                        style: const TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      const SizedBox(width: 25), // Add some spacing between text and link
                      GestureDetector(
                        onTap: _resendOtp, // Calls the resend OTP function
                        child: Text(
                          "Resend OTP",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white, // Keep it white for consistency
                            decoration: TextDecoration.underline, // Makes it look like a link
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
          if (_isLoading)
            const Positioned.fill(
              child: CustomLoader(),
            ),
          // Back button positioned at the top-left corner
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.secondaryBackgroundColor),
              onPressed: () {
                Navigator.pop(context); // Navigate back when tapped
              },
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
    );
  }
}
