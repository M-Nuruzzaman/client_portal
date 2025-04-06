import 'dart:convert';
import 'dart:developer';

import 'package:client_portal/presentation/widgets/custom_loader.dart';
import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:client_portal/core/utils/api_service.dart';
import 'package:client_portal/data/models/service_response.dart';
import 'package:client_portal/presentation/screens/registration/take_otp_screen.dart';
import '../../../core/utils/api_config.dart';
import '../../../utils/custom_page_route.dart';
import '../../widgets/custom_loading_indicator.dart';
import '../../widgets/custom_notification_bar.dart';
import '../../widgets/custom_text_feild.dart';
import '../../widgets/reusable_button.dart';
import 'login_screen.dart';
import '../../../utils/AppColors.dart';  // Import your color constants here

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String? mobileNo;
  String? email;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();



  void _resentOtp() async{
    Map<String, dynamic> data = {
      "email": email,
      "mobileNumber": mobileNo,
      "investorCode": ""
    };

    Map<String, String> headers = {
      'mobileNumber': mobileNo!,
      "email": email!,
      'otp': "",
      'investorCode': "",
    };
    // Recall For resent OTP
    ServiceResponse response = await _apiService.apiCall(
      endpoint: 'public/auth/register',
      baseUrl: ApiConfig.baseUrlClientPortal,
      method: 'POST',
      data: data,
      headers: headers,
    );
  }


  Future<void> _submit() async {
    if(_isLoading)return;
    setState(() {
      if(mobileNo == null || mobileNo!.isEmpty){
        emptyFields["mobileNo"] = true;
      }
      if(email == null || email!.isEmpty){
        emptyFields["email"] = true;
      }
    });
    if (mobileNo == null || email == null || mobileNo!.isEmpty || email!.isEmpty) {
      return;
    }
    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      "email": email,
      "mobileNumber": mobileNo,
      "investorCode": ""
    };

    Map<String, String> headers = {
      'mobileNumber': mobileNo!,
      "email": email!,
      'otp': "",
      'investorCode': "",
    };

    log("Calling API: POST public/auth/register (Confirm)", name: "API_CALL");
    log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
    log("Request Header: ${jsonEncode(headers)}", name: "API_CALL");

    // First API call (Register Request)
    ServiceResponse response = await _apiService.apiCall(
      endpoint: 'public/auth/register',
      baseUrl: ApiConfig.baseUrlClientPortal,
      method: 'POST',
      data: data,
      headers: headers,
    );

    log("Response from public/auth/register (Confirm) API: ${response.content}", name: "API_RESPONSE");

    if (response.hasError) {
      showCustomNotification(context, response.message, Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    if (response.message == "OTP Required") {
      // Open OTP screen
      await Navigator.push(
        context,
        CustomPageRoute(page: TakeOtpScreen(onResendOtp: _resentOtp, submitWithOtp: _submitOtp,),),
      );
    } else {
      // If OTP isn't required, inform the user
      // showCustomNotification(context, "Temporary login password sent to your email.", Colors.green);
    }

    setState(() => _isLoading = false);
  }

  /// Submit OTP after being updated in the Cubit
  Future<void> _submitOtp(String otp) async {
    if (otp.isEmpty) {
      showCustomNotification(context, "OTP is required to proceed", Colors.red);
      return;
    }
    Map<String, dynamic> data = {
      "email": email!,
      "mobileNumber": mobileNo!,
      "investorCode": ""
    };

    Map<String, String> headers = {
      'mobileNumber': mobileNo!,
      'otp': otp,
      'investorCode': "",
    };

    log("Calling API: POST public/auth/register (Confirm)", name: "API_CALL");
    log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
    log("Request Header: ${jsonEncode(headers)}", name: "API_CALL");

    // Second API call (Complete Registration)
    ServiceResponse responseWithOtp = await _apiService.apiCall(
      endpoint: 'public/auth/register',
      baseUrl: ApiConfig.baseUrlClientPortal,
      method: 'POST',
      data: data,
      headers: headers,
    );

    log("Response from public/auth/register (Confirm) API: ${responseWithOtp.content}", name: "API_RESPONSE");

    if (responseWithOtp.hasError) {
      showCustomNotification(context, responseWithOtp.message, Colors.red);
      return;
    } else {
      if(responseWithOtp.message == "OTP Required"){
        showCustomNotification(context, "OTP doesn't match!", Colors.red);

      }
      else{
        // showCustomNotification(context, "Registration successful. Temporary login password sent to your email.", Colors.green);
        // Navigate to LoginScreen
        Navigator.push(
          context,
          CustomPageRoute(page: const LoginScreen()),
        );
      }
    }
  }

  Map<String, bool> emptyFields = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
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
                          "Please provide your email address and mobileNo number",
                          style: TextStyle(
                            color: AppColors.secondaryBackgroundColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: "Mobile No",
                          value: mobileNo,
                          onChanged: (value) {
                            setState(() {
                              mobileNo = value;
                              emptyFields["mobileNo"] = false;
                            });
                          },
                          isError: emptyFields["mobileNo"] ?? false,
                        ),
        
                        CustomTextField(
                          label: "Email Address",
                          value: email,
                          onChanged: (value) {
                            setState(() {
                              email = value;
                              emptyFields["email"] = false; // Clear error when typing
                            });
                          },
                          isError: emptyFields["email"] ?? false,
                        ),
                        const SizedBox(height: 8),
        
                        CustomButton(
                          text: "Submit",
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
