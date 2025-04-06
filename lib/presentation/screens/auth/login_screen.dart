import 'dart:convert';
import 'dart:developer';

import 'package:client_portal/presentation/screens/auth/forget_password_screen.dart';
import 'package:client_portal/presentation/widgets/custom_loader.dart';
import 'package:client_portal/utils/AppColors.dart';
import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:client_portal/utils/fcm_token_manager.dart';
import 'package:client_portal/utils/session_manager.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/api_config.dart';
import '../../../core/utils/api_service.dart';
import '../../../data/models/registration_response.dart';
import '../../../data/models/service_response.dart';
import '../../../utils/custom_page_route.dart';
import '../../widgets/custom_notification_bar.dart';
import '../../widgets/custom_password_feild.dart';
import '../../widgets/custom_text_feild.dart';
import '../../widgets/reusable_button.dart';
import '../home/account_screen.dart';
import 'new_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  String? mobileNo;
  String? password;
  bool _isLoading = false;
  bool _rememberMe = false;
  Map<String, bool> emptyFields = {};

  Future<void> login() async {
    if(_isLoading)return;
    setState(() {
      if(mobileNo == null || mobileNo!.isEmpty){
        emptyFields["mobileNo"] = true;
      }
      if(password == null || password!.isEmpty){
        emptyFields["password"] = true;
      }
    });
    if (mobileNo == null || password == null || mobileNo!.isEmpty  || password!.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> data = {
      "mobileNumber": mobileNo,
      "password": password,
      "investorCode": "",
    };

    log("Calling API: POST public/auth/login (Confirm)", name: "API_CALL");
    log("Request Data: ${jsonEncode(data)}", name: "API_CALL");

    ServiceResponse response = await _apiService.apiCall(
      endpoint: 'public/auth/login',
      baseUrl: ApiConfig.baseUrlClientPortal,
      method: 'POST',
      data: data,
    );

    log("Response from public/auth/login (Confirm) API: ${response.content}", name: "API_RESPONSE");

    if (response.hasError) {
      // Show the error message
      showCustomNotification(context, response.message, Colors.red);
    } else {
      if (response.content != null) {
        Map<String, dynamic> content = jsonDecode(response.content!);
        RegistrationResponse registrationResponse = RegistrationResponse.fromJson(content);
        await SessionManager.saveUserData(registrationResponse.email, registrationResponse.mobileNumber);
        print(SessionManager.getMobileNumber());
        print(SessionManager.getEmail());
        String? fcmToken = await FcmTokenManager.getFcmToken();
        print("FCM TOKEN: $fcmToken");
        //call to store FCM token

        log("Calling API: POST register-token?mobileNumber=$mobileNo&fcmToken=$fcmToken&deviceType=MOBILE (Confirm)", name: "API_CALL");

        ServiceResponse res = await _apiService.apiCall(
          endpoint: 'register-token?mobileNumber=$mobileNo&fcmToken=$fcmToken&deviceType=MOBILE',
          baseUrl: ApiConfig.baseUrlNotificationService,
          method: 'POST',
        );

        log("Response from register-token?mobileNumber=$mobileNo&fcmToken=$fcmToken&deviceType=MOBILE (Confirm) API: ${res.content}", name: "API_RESPONSE");

        if (registrationResponse.tempPasswordActive) {
          //Redirect to Set password page
          Navigator.push(
            context,
            CustomPageRoute(page: SetNewPasswordScreen()),
          );
        } else {
          // Redirect to Dashboard
          Navigator.push(
            context,
            CustomPageRoute(page: AccountPage()),
          );
          // showCustomNotification(context, "Login Successfully.", Colors.green);
        }
      } else {
        showCustomNotification(context, "Unexpected error, please try again.", Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: GradientBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: SingleChildScrollView( // ✅ Added to prevent overflow
                child: Container(
                  padding: const EdgeInsets.all(40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/LOGO.png',
                          height: 70,
                          width: 280,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Login with Email or Mobile",
                          style: TextStyle(
                            color: AppColors.secondaryBackgroundColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: "mobile or email",
                          value: mobileNo,
                          onChanged: (value) {
                            setState(() {
                              mobileNo = value;
                              emptyFields["mobileNo"] = false;
                            });
                          },
                          isError: emptyFields["mobileNo"] ?? false,
                        ),
                        const SizedBox(height: 4),
                        CustomPasswordField(
                          label: "password",
                          value: password,
                          onChanged: (value) {
                            setState(() {
                              password = value;
                              emptyFields["password"] = false;
                            });
                          },
                          isError: emptyFields["password"] ?? false,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text('Remember Me'),
                          ],
                        ),
                        CustomButton(
                          text: "Login",
                          onPressed: login,
                          backgroundColor: AppColors.buttonColor,
                          textColor: AppColors.secondaryBackgroundColor,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              CustomPageRoute(page: ForgetPasswordScreen()),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.secondaryBackgroundColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading) const Positioned.fill(child: CustomLoader()),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.secondaryBackgroundColor),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
