import 'dart:convert';
import 'dart:developer';

import 'package:client_portal/data/models/service_response.dart';
import 'package:client_portal/presentation/screens/home/account_screen.dart';
import 'package:client_portal/presentation/widgets/custom_loader.dart';
import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:client_portal/utils/session_manager.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/api_config.dart';
import '../../../core/utils/api_service.dart';
import '../../../utils/AppColors.dart';
import '../../../utils/custom_page_route.dart';
import '../../widgets/custom_notification_bar.dart';
import '../../widgets/custom_password_feild.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});


  @override
  _SetNewPasswordScreenState createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  String? password = "";
  String? confirmPassword = "";
  Map<String, bool> emptyFields = {};

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });
    emptyFields.clear();
    if (_formKey.currentState!.validate()) {
      if (password != confirmPassword) {
        showCustomNotification(context, "Passwords doesn't match.", Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Map<String, dynamic> data = {
        "mobileNumber": SessionManager.getMobileNumber()!,
        "newPassword": password,
      };
      Map<String, String> headers = {
        'mobileNumber': SessionManager.getMobileNumber()!,
        'otp': "",
        'investorCode': "",
      };

      setState(() {
        bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password!);
        bool hasLowercase = RegExp(r'[a-z]').hasMatch(password!);
        bool hasDigit = RegExp(r'[0-9]').hasMatch(password!);
        bool hasSpecialChar = RegExp(r'[@#_]').hasMatch(password!);

        if (!hasUppercase || !hasLowercase || !hasDigit || !hasSpecialChar) {
          emptyFields["password"] = true;
        }
        if(confirmPassword == null || confirmPassword!.isEmpty){
          emptyFields["confirmPassword"] = true;
        }
      });
      if(emptyFields.isNotEmpty){
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {

        log("Calling API: POST public/auth/new-password (Confirm)", name: "API_CALL");
        log("Request Data: ${jsonEncode(data)}", name: "API_CALL");

        // Make the API call
        ServiceResponse response = await _apiService.apiCall(
          endpoint: 'public/auth/new-password',
          baseUrl: ApiConfig.baseUrlClientPortal,
          method: 'POST',
          data: data,
          headers: headers,
        );

        log("Response from public/auth/new-password (Confirm) API: ${response.content}", name: "API_RESPONSE");

        if (response.hasError) {
          showCustomNotification(context, response.message, Colors.red);

        } else {
          if (response.message == "OTP Required") {

          } else {
            showCustomNotification(context, "Password updated successfully", Colors.green);
            Navigator.push(
              context,
              CustomPageRoute(page: AccountPage(),),
            );
          }
        }
      } catch (e) {
        showCustomNotification(context, "Something went wrong!", Colors.red);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevent overflow
      body: GradientBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: SingleChildScrollView( // Allows scrolling when keyboard appears
                padding: const EdgeInsets.all(40.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        'assets/LOGO.png',
                        height: 70,
                        width: 280,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Please set a new password for your account",
                        style: TextStyle(
                          color: AppColors.secondaryBackgroundColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      CustomPasswordField(
                        label: "Password",
                        value: password,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                            emptyFields["password"] = false; // Remove error when user types
                          });
                        },
                        isError: emptyFields["password"] ?? false, // Apply error state
                      ),
                      const SizedBox(height: 16),
                      CustomPasswordField(
                        label: "Confirm Password",
                        value: confirmPassword,
                        onChanged: (value) {
                          setState(() {
                            confirmPassword = value;
                            emptyFields["confirmPassword"] = false; // Remove error when user types
                          });
                        },
                        isError: emptyFields["confirmPassword"] ?? false, // Apply error state
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Password must contain:",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            _buildPasswordRule("At least one uppercase letter", RegExp(r'[A-Z]').hasMatch(password!)),
                            _buildPasswordRule("At least one lowercase letter", RegExp(r'[a-z]').hasMatch(password!)),
                            _buildPasswordRule("At least one digit", RegExp(r'[0-9]').hasMatch(password!)),
                            _buildPasswordRule("At least one special character (@, #, _)", RegExp(r'[@#_]').hasMatch(password!)),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Submit",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondaryBackgroundColor),
                        ),
                      ),
                    ],
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

Widget _buildPasswordRule(String text, bool isValid) {
  return Row(
    children: [
      Icon(
        isValid ? Icons.check_circle : Icons.cancel,
        color: isValid ? Colors.green : Colors.red,
        size: 16,
      ),
      SizedBox(width: 5),
      Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isValid ? Colors.green : Colors.red,
        ),
      ),
    ],
  );
}
