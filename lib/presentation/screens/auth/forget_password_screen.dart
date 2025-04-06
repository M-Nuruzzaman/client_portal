import 'dart:convert';
import 'dart:developer';

import 'package:client_portal/core/utils/api_config.dart';
import 'package:client_portal/presentation/widgets/custom_loader.dart';
import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:flutter/material.dart';
import 'package:client_portal/presentation/screens/registration/take_otp_screen.dart';
import '../../../core/utils/api_service.dart';
import '../../../data/models/service_response.dart';
import '../../../utils/custom_page_route.dart';
import '../../widgets/custom_notification_bar.dart';
import '../../widgets/custom_text_feild.dart';
import '../../widgets/reusable_button.dart';
import '../auth/login_screen.dart';
import '../../../utils/AppColors.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {

  String? mobileNumber;
  String? email;
  bool _isLoading = false;
  Map<String, bool> emptyFields = {};

  final ApiService _apiService = ApiService();

  void _resentOtp() async{

    Map<String, dynamic> data = {
      "mobileNumber": mobileNumber,
      "email": email
    };

    Map<String, String> headers = {
      'email': email!,
      'otp': "",
      'mobileNumber': mobileNumber!,
    };

    log("Calling API: POST public/auth/forget-password (Confirm)", name: "API_CALL");
    log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
    log("Request Header: ${jsonEncode(headers)}", name: "API_CALL");

    // Resent OTP
    ServiceResponse response = await _apiService.apiCall(
      endpoint: 'public/auth/forget-password',
      baseUrl: ApiConfig.baseUrlClientPortal,
      method: 'POST',
      data: data,
      headers: headers,
    );
    log("Response from public/auth/forget-password (Confirm) API: ${response.content}", name: "API_RESPONSE");

  }
  Future<void> _submit() async {
    if(_isLoading)return;
    setState(() {
      if(mobileNumber == null || mobileNumber!.isEmpty){
        emptyFields["mobileNumber"] = true;
      }
      if(email == null || email!.isEmpty){
        emptyFields["email"] = true;
      }
    });
    if (mobileNumber == null || email == null || mobileNumber!.isEmpty  || email!.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> data = {
      "mobileNumber": mobileNumber,
      "email": email
    };

    Map<String, String> headers = {
      'email': email!,
      'otp': "",
      'mobileNumber': mobileNumber!,
    };

    log("Calling API: POST public/auth/forget-password (Confirm)", name: "API_CALL");
    log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
    log("Request Header: ${jsonEncode(headers)}", name: "API_CALL");

    // First API call (Register Request)
    ServiceResponse response = await _apiService.apiCall(
      endpoint: 'public/auth/forget-password',
      baseUrl: ApiConfig.baseUrlClientPortal,
      method: 'POST',
      data: data,
      headers: headers,
    );
    log("Response from public/auth/forget-password (Confirm) API: ${response.content}", name: "API_RESPONSE");

    if (response.hasError) {
      showCustomNotification(context, response.message, Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    if (response.message == "OTP Required") {
      // Open OTP screen
      Navigator.push(
        context,
        CustomPageRoute(page: TakeOtpScreen(onResendOtp: _resentOtp, submitWithOtp: _submitOtp,)),
      );
    } else {
      // If OTP isn't required, inform the user
      showCustomNotification(context, "Temporary login password sent to your phone.", Colors.green);
    }

    setState(() => _isLoading = false);
  }

  /// Submit OTP after being updated in the Cubit
  Future<void> _submitOtp(String otp) async {
    if(_isLoading)return;
    if (otp.isEmpty) {
      showCustomNotification(context, "OTP is required to proceed!", Colors.red);
      return;
    }
    Map<String, dynamic> data = {
      "mobileNumber": mobileNumber,
      "email": email
    };

    Map<String, String> headers = {
      'email': email!,
      'otp': otp,
      'mobileNumber': mobileNumber!,
    };

    log("Calling API: POST public/auth/forget-password (Confirm)", name: "API_CALL");
    log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
    log("Request Header: ${jsonEncode(headers)}", name: "API_CALL");

    // Second API call (Complete Registration)
    ServiceResponse responseWithOtp = await _apiService.apiCall(
      endpoint: 'public/auth/forget-password',
      baseUrl: ApiConfig.baseUrlClientPortal,
      method: 'POST',
      data: data,
      headers: headers,
    );

    log("Response from public/auth/forget-password (Confirm) API: ${responseWithOtp.content}", name: "API_RESPONSE");

    if (responseWithOtp.hasError) {
      showCustomNotification(context, responseWithOtp.message, Colors.red);
    } else {
      if(responseWithOtp.message == "OTP Required"){
        showCustomNotification(context, "OTP doesn't match!", Colors.red);
      }
      else{
        showCustomNotification(context, "Temporary login password sent to your email.", Colors.green);
        // Navigate to LoginScreen
        Navigator.push(
          context,
          CustomPageRoute(page: const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,  // Make container full-width
                    constraints: BoxConstraints(maxWidth: 400),  // Limit width for better layout
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/LOGO.png', // Add your logo image in the assets folder
                          height: 70,
                          width: 280,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Please provide your mobile number',
                          style: TextStyle(
                            color: AppColors.secondaryBackgroundColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: "mobile",
                          value: mobileNumber,
                          onChanged: (value) {
                            setState(() {
                              mobileNumber = value;
                              emptyFields["mobileNumber"] = false;
                            });
                          },
                          isError: emptyFields["mobileNumber"] ?? false,
                        ),
                        CustomTextField(
                          label: "email",
                          value: email,
                          onChanged: (value) {
                            setState(() {
                              email = value;
                              emptyFields["email"] = false;
                            });
                          },
                          isError: emptyFields["email"] ?? false,
                        ),
                        const SizedBox(height: 8),
                        // Submit button or loading indicator
                        CustomButton(
                          text: "Next",
                          onPressed: _submit,
                          backgroundColor: AppColors.buttonColor,
                          textColor: AppColors.secondaryBackgroundColor,
                        ),
                      ],
                    ),
                  ),
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
      ),
    );
  }
}
