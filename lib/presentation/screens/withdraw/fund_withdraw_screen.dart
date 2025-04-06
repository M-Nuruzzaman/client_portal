import 'dart:convert';
import 'dart:developer';

import 'package:client_portal/presentation/screens/withdraw/withdraw_history_screen.dart';
import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/api_config.dart';
import '../../../core/utils/api_service_with_file.dart';
import '../../../utils/AppColors.dart';
import '../../../utils/custom_page_route.dart';
import '../../../utils/session_manager.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/custom_notification_bar.dart';
import '../../widgets/reusable_button.dart';

class FundWithdrawScreen extends StatefulWidget {
  const FundWithdrawScreen({super.key});

  @override
  State<FundWithdrawScreen> createState() => _FundWithdrawScreenState();
}

class _FundWithdrawScreenState extends State<FundWithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  double availableAmount = 50000.00;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_amountListener);
    getAvailableBalance();
  }

  Future<void> getAvailableBalance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String email = SessionManager.getEmail() ?? "default@example.com";
      String mobileNumber = SessionManager.getMobileNumber() ?? "01705942721";

      log("Calling API: POST investor/balance?mobileNumber=$mobileNumber", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "investor/balance?mobileNumber=$mobileNumber",
        baseUrl: ApiConfig.baseUrlTransactionService,
        method: "GET",
      );
      log("Response from investor/balance?mobileNumber=$mobileNumber API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      } else {
        setState(() {
          availableAmount = double.parse(response.content!); // Converts the string to double
        });
      }
    } catch (e) {
      showCustomNotification(context, "Error: ${e.toString()}", Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Listener function to handle the text change
  void _amountListener() {
    String text = _amountController.text;

    // If the text is "৳", remove it
    if (text == '৳' || text == '0') {
      _amountController.text = '';
      _amountController.selection = TextSelection.collapsed(offset: 0);
    }
    // If the text is not empty and does not start with "৳", add "৳" at the beginning
    else if (text.isNotEmpty && !text.startsWith('৳')) {
      _amountController.text = '৳$text';
      _amountController.selection = TextSelection.collapsed(offset: _amountController.text.length);
    }
    // Check for exceeding amount
    if (text.length > 1) {
      String cleanAmount = text.substring(1);
      double? enteredAmount = double.tryParse(cleanAmount);
      if (enteredAmount != null) {
        if (enteredAmount > availableAmount) {
          showCustomNotification(context, "Amount exceeds available balance", Colors.red);
          _amountController.text = '৳${availableAmount.toStringAsFixed(2)}';
          _amountController.selection = TextSelection.collapsed(offset: _amountController.text.length);
        }
      }
    }
  }

  Future<void> withdraw() async {
    showConfirmationDialog(
      context: context,
      title: "Are you sure, Do you want to proceed?",
      onConfirm: submit,
    );
  }

  Future<void> submit() async {
    String _amount = _amountController.text.trim();
    if (_amount.isNotEmpty) {
      // Remove first character (if needed)
      String cleanAmount = _amount.substring(1);

      // Convert String to double safely
      double? parsedAmount = double.tryParse(cleanAmount);

      if (parsedAmount != null && parsedAmount != 0) {
        try {
          String email = SessionManager.getEmail() ?? "default@example.com";
          String mobileNumber = SessionManager.getMobileNumber() ?? "01705942721";
          Map<String, dynamic> data = {
            "amount": parsedAmount,
            "mobileNumber": mobileNumber
          };

          log("Calling API: POST withdrawals/request", name: "API_CALL");
          log("Request Data: ${jsonEncode(data)}", name: "API_CALL");

          final apiService = ApiServiceWithFile();
          final response = await apiService.apiCall(
            endpoint: "withdrawals/request",
            baseUrl: ApiConfig.baseUrlTransactionService,
            method: "POST",
            data: data,
          );
          log("Response from withdrawals/request API: ${response.content}", name: "API_RESPONSE");

          if (response.hasError) {
            showCustomNotification(context, response.message, Colors.red);
          } else {
            Navigator.push(
              context,
              CustomPageRoute(page: WithdrawHistoryScreen()),
            );
          }
        } catch (e) {
          showCustomNotification(context, "Error: ${e.toString()}", Colors.red);
        }
      } else {
        showCustomNotification(context, "Invalid amount", Colors.red);
        return;
      }
    } else {
      showCustomNotification(context, "Enter amount", Colors.red);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Fund withdraw",
        titleColor: Colors.white,
        onLeadingButtonPressed: () {
          Navigator.pop(context);
        },
        showBackButton: true,
      ),
      body: GradientBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),

                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center, // Center the text inside the input box
                      style: TextStyle(
                        fontSize: 24.0, // Increase text size
                      ),
                      decoration: InputDecoration(
                        hintText: '৳0',
                        hintStyle: TextStyle(
                          fontSize: 24.0, // Increase hintText size
                          color: Colors.grey, // Optional: Change hintText color
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey), // Single line below the input
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "Available Balance: ৳${availableAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    CustomButton(
                      text: "Withdraw",
                      onPressed: withdraw,
                      backgroundColor: AppColors.primaryColor,
                      textColor: AppColors.secondaryBackgroundColor,
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const Positioned.fill(
                child: CustomLoader(),
              ),
          ],
        ),
      ),
    );
  }
}
