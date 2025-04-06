import 'dart:convert';
import 'dart:developer';

import 'package:client_portal/core/utils/api_service.dart';
import 'package:client_portal/presentation/drawer/app_drawer.dart';
import 'package:client_portal/presentation/screens/registration/information_screen.dart';
import 'package:client_portal/presentation/screens/registration/thank_you_screen.dart';
import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:client_portal/utils/session_manager.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/api_config.dart';
import '../../../data/models/AccountCompletion.dart';
import '../../../data/models/service_response.dart';
import '../../../utils/AppColors.dart';
import '../../../utils/custom_page_route.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_notification_bar.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  @override
  void initState() {
    super.initState();
    callCompletion();
  }


  final ApiService _apiService = ApiService();
  double completedPercentage = 0.0;
  final List<Map<String, String>> boughtShares = [
    {'name': 'ACI', 'quantity': '50', 'price': '1500 TK'},
    {'name': 'ACI', 'quantity': '50', 'price': '1500 TK'},
    {'name': 'ACI', 'quantity': '50', 'price': '1500 TK'},
    {'name': 'BRAC', 'quantity': '20', 'price': '800 TK'},
    {'name': 'BRAC', 'quantity': '20', 'price': '800 TK'},
    {'name': 'BRAC', 'quantity': '20', 'price': '800 TK'},
    {'name': 'SIBL', 'quantity': '10', 'price': '3000 TK'},
    {'name': 'SIBL', 'quantity': '10', 'price': '3000 TK'},
    {'name': 'SIBL', 'quantity': '10', 'price': '3000 TK'},
    {'name': 'SIBL', 'quantity': '10', 'price': '3000 TK'},
  ];

  Future<void> callCompletion() async{
    Map<String, dynamic> data = {
      "mobileNumber": SessionManager.getMobileNumber()!,
    };
    Map<String, String> headers = {
      'mobileNumber': SessionManager.getMobileNumber()!,
      'otp': "",
      'investorCode': "",
    };

    try {

      log("Calling API: POST investor/dashboard", name: "API_CALL");
      log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
      log("Request Header: ${jsonEncode(headers)}", name: "API_CALL");

      // Make the API call
      ServiceResponse response = await _apiService.apiCall(
        endpoint: 'investor/dashboard',
        baseUrl: ApiConfig.baseUrlClientPortal,
        method: 'POST',
        data: data,
        headers: headers,
      );

      log("Response from investor/dashboard API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError == true) {
        // Show the error message
        showCustomNotification(context, "Something went wrong", Colors.red);
      } else {
        Map<String, dynamic> parsedData = jsonDecode(response.content!);
        AccountCompletion accountCompletion = AccountCompletion.fromJson(parsedData);

        int completedSections = 0;
        int totalSections = 6; // personalDetails, bankDetails, nomineeDetails
        if(accountCompletion.nidPhotos == true) completedSections++;
        if (accountCompletion.personalDetails == true) completedSections++;
        if (accountCompletion.address == true) completedSections++;
        if (accountCompletion.bankDetails == true) completedSections++;
        if (accountCompletion.documents == true) completedSections++;

        if(accountCompletion.partialAccount.transactionStatus == "PENDING"){
          Navigator.push(
            context,
            CustomPageRoute(page: ThankYouPage()),
          );
        }

        if(accountCompletion.partialAccount.active == false){
          Navigator.push(
            context,
            CustomPageRoute(page: InformationScreen(step: completedSections, data: accountCompletion.partialAccount.toJson(),),),
          );
        }

        setState(() {
          completedPercentage = completedSections / totalSections;
        });
      }
    } catch (e) {
      // Handle any exceptions that occur
      showCustomNotification(context, "Error call completion!", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Dashboard",
        titleColor: Colors.white,
        onLeadingButtonPressed: () {
          Navigator.pop(context);
        },
        elevation : 4,
        showBackButton: false,
      ),
      drawer: AppDrawer(),
      body: GradientBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'Profile Completion',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryBackgroundColor,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: completedPercentage, // Should be between 0.0 and 1.0
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.successColor),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '${(completedPercentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryBackgroundColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Bought Shares',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryBackgroundColor,
                  ),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // Disable ListView scrolling
                  itemCount: boughtShares.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: AppColors.secondaryBackgroundColor,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          boughtShares[index]['name']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        subtitle: Text(
                          'Quantity: ${boughtShares[index]['quantity']} | Price: ${boughtShares[index]['price']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}