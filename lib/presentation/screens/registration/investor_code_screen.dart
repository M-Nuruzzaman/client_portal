import 'dart:convert';
import 'dart:developer';

import 'package:client_portal/presentation/widgets/custom_loader.dart';
import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:flutter/material.dart';
import 'package:client_portal/presentation/screens/registration/take_otp_screen.dart';
import '../../../core/utils/api_config.dart';
import '../../../core/utils/api_service.dart';
import '../../../data/models/service_response.dart';
import '../../../utils/custom_page_route.dart';
import '../../widgets/custom_notification_bar.dart';
import '../../widgets/custom_text_feild.dart';
import '../../widgets/reusable_button.dart';
import '../auth/login_screen.dart';
import '../../../utils/AppColors.dart'; // Import your color constants

class InvestorCodeScreen extends StatefulWidget {
  const InvestorCodeScreen({super.key});

  @override
  _InvestorCodeScreenState createState() => _InvestorCodeScreenState();
}

class _InvestorCodeScreenState extends State<InvestorCodeScreen> {
  final TextEditingController _investorCodeController = TextEditingController();
  String? investorCode;
  Map<String, bool> emptyFields = {};
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  void _resentOtp() async{
    if(_isLoading)return;

    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      "investorCode": investorCode!
    };

    Map<String, String> headers = {
      'mobileNumber': "",
      'otp': "",
      'investorCode': investorCode!,
    };

    log("Calling API: POST deposits/offline", name: "API_CALL");
    log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
    log("Request Header: ${jsonEncode(headers)}", name: "API_CALL");

    // Resent OTP
    ServiceResponse response = await _apiService.apiCall(
      endpoint: 'public/auth/reset-password',
      baseUrl: ApiConfig.baseUrlClientPortal,
      method: 'POST',
      data: data,
      headers: headers,
    );

    log("Response from deposits/offline API: ${response.content}", name: "API_RESPONSE");
  }

  Future<void> _submit() async {
    if(_isLoading)return;

    setState(() {
      if (investorCode == null || investorCode!.isEmpty) {
        emptyFields["investorCode"] = true;
      }
    });
    if (investorCode == null || investorCode!.isEmpty) {
      return;
    }
    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      "investorCode": investorCode!
    };

    Map<String, String> headers = {
      'mobileNumber': "",
      'otp': "",
      'investorCode': investorCode!,
    };

    log("Calling API: POST deposits/offline", name: "API_CALL");
    log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
    log("Request Header: ${jsonEncode(headers)}", name: "API_CALL");

    // First API call (Register Request)
    ServiceResponse response = await _apiService.apiCall(
      endpoint: 'public/auth/reset-password',
      baseUrl: ApiConfig.baseUrlClientPortal,
      method: 'POST',
      data: data,
      headers: headers,
    );

    log("Response from deposits/offline API: ${response.content}", name: "API_RESPONSE");

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
      // showCustomNotification(context, "Temporary login password sent to your phone.", Colors.green);
    }

    setState(() => _isLoading = false);
  }

  /// Submit OTP after being updated in the Cubit
  Future<void> _submitOtp(String otp) async {
    String investorCode = _investorCodeController.text.trim();
    if (otp.isEmpty) {
      showCustomNotification(context, "OTP is required to proceed!", Colors.red);
      return;
    }
    Map<String, dynamic> data = {
      "investorCode": investorCode
    };

    Map<String, String> headers = {
      'mobileNumber': "",
      'otp': otp,
      'investorCode': investorCode,
    };

    log("Calling API: POST deposits/offline", name: "API_CALL");
    log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
    log("Request Header: ${jsonEncode(headers)}", name: "API_CALL");

    // Second API call (Complete Registration)
    ServiceResponse responseWithOtp = await _apiService.apiCall(
      endpoint: 'public/auth/reset-password',
      baseUrl: ApiConfig.baseUrlClientPortal,
      method: 'POST',
      data: data,
      headers: headers,
    );

    log("Response from deposits/offline API: ${responseWithOtp.content}", name: "API_RESPONSE");

    if (responseWithOtp.hasError) {
      showCustomNotification(context, responseWithOtp.message, Colors.red);
    } else {
      if(responseWithOtp.message == "OTP Required"){
        showCustomNotification(context, "OTP doesn't match!", Colors.red);

      }
      else{
        // showCustomNotification(context, "Temporary login password sent to your phone.", Colors.green);
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
                          'Please provide your investor code',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Roboto', // Modern font for a clean look
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Investor Code field
                        CustomTextField(
                          label: "Investor Code",
                          value: investorCode,
                          onChanged: (value) {
                            setState(() {
                              investorCode = value;
                              emptyFields["investorCode"] = false;
                            });
                          },
                          isError: emptyFields["investorCode"] ?? false,
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
