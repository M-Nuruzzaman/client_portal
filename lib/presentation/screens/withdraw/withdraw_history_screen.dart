import 'dart:convert';
import 'dart:developer';

import 'package:client_portal/presentation/widgets/custom_appbar.dart';
import 'package:client_portal/utils/AppColors.dart';
import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/api_config.dart';
import '../../../core/utils/api_service_with_file.dart';
import '../../../data/models/withdraw.dart';
import '../../../utils/session_manager.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/custom_notification_bar.dart';

class WithdrawHistoryScreen extends StatefulWidget {
  const WithdrawHistoryScreen({super.key});

  @override
  State<WithdrawHistoryScreen> createState() => _WithdrawHistoryScreenState();
}

class _WithdrawHistoryScreenState extends State<WithdrawHistoryScreen> {
  List<Withdraw> withdrawals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadWithdrawals();
  }

  // Replace this method with an actual API call in the future
  Future<void> loadWithdrawals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String email = SessionManager.getEmail() ?? "default@example.com";
      String mobileNumber = SessionManager.getMobileNumber() ?? "01705942721";

      log("Calling API: POST withdrawals/investor?mobileNumber=$mobileNumber", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "withdrawals/investor?mobileNumber=$mobileNumber",
        baseUrl: ApiConfig.baseUrlTransactionService,
        method: "GET",
      );
      log("Response from withdrawals/investor?mobileNumber=$mobileNumber API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      } else {
        try {
          if(response.content != "null"){
            final List<dynamic> jsonData = json.decode(response.content!);
            setState(() {
              withdrawals = jsonData.map((e) => Withdraw.fromJson(e)).toList();
            });
          }
          else{
            showCustomNotification(context, response.message, Colors.green);
          }
        } catch (e) {
          showCustomNotification(context, "Error decoding JSON: ${e.toString()}", Colors.red);
        }
      }
    } catch (e) {
      showCustomNotification(context, "Error: ${e.toString()}", Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Withdraw History",
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
            Column(
              children: [
                // Header section for the withdraw history
                Container(
                  color: Colors.white10,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Row(
                    children: const [
                      // Expanded(child: Text('Medium', style: headerTextStyle)),
                      Expanded(child: Text('Amount', style: headerTextStyle)),
                      Expanded(child: Text('Status', style: headerTextStyle)),
                      Expanded(child: Text('Time', style: headerTextStyle)),
                    ],
                  ),
                ),
                // List of withdrawals
                Expanded(
                  child: _buildWithdrawalsListView(),
                ),
              ],
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

  Widget _buildWithdrawalsListView() {
    return ListView.builder(
      itemCount: withdrawals.length,
      itemBuilder: (context, index) {
        final withdrawal = withdrawals[index];
        final isDeep = (index % 2 == 0); // Alternate row color

        return Container(
          color: isDeep ? Colors.white54 : Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              // Expanded(child: Text(withdrawal.paymentChannel!, style: dataTextStyle)),
              Expanded(child: Text('\৳${withdrawal.totalAmount}', style: dataTextStyle)),
              Expanded(child: Text(withdrawal.status, style: dataTextStyle)),
              Expanded(child: Text(withdrawal.initiatedOn, style: dataTextStyle)),
            ],
          ),
        );
      },
    );
  }
}

const headerTextStyle = TextStyle(
  color: AppColors.secondaryBackgroundColor,
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

const dataTextStyle = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.bold,
  fontSize: 13,
);
