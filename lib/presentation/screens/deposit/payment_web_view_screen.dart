import 'dart:convert';
import 'dart:developer';

import 'package:client_portal/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/utils/api_config.dart';
import '../../../core/utils/api_service_with_file.dart';
import '../../../utils/custom_page_route.dart';
import '../../widgets/custom_notification_bar.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String type;
  final String userId;
  final Widget successRedirectPage;
  final Future<void> Function() onSuccessPayment;
  const PaymentWebViewScreen({super.key, required this.url, required this.userId, required this.successRedirectPage, required this.onSuccessPayment, required this.type,});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  // TODO: need to make this function reusable
  Future<void> _paymentStatus(String url) async {
    try {
      Map<String, dynamic> data = {
        "url": url,
        "type": widget.type,
      };

      log("Calling API: POST deposits/offline", name: "API_CALL");
      log("Request Data: ${jsonEncode(data)}", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "transaction/redirection",
        baseUrl: ApiConfig.baseUrlTransactionService,
        method: "POST",
        data: data,
      );

      log("Response from deposits/offline API: ${response.content}", name: "API_RESPONSE");

      // : test this api response
      widget.onSuccessPayment();

      // if (response.hasError) {
      //   showCustomNotification(context, response.message, Colors.red);
      // }else{
      //   // Decoding the response JSON string
      //   if(response.content == "SUCCESS") {
      //     widget.onSuccessPayment();
      //   }
      //   else if(response.content == "FAIL"){
      //     showCustomNotification(context, "Payment Failed", Colors.red);
      //     Navigator.pop(context);
      //   }
      //   else{
      //     Navigator.push(
      //         context,
      //         CustomPageRoute(page: widget.successRedirectPage)
      //     );
      //   }
      // }
    } catch (e) {
      showCustomNotification(context, e.toString(), Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains("https://sandbox.sslcommerz.com/gwprocess/v4/gw.php?Q=REDIRECT")) {
              // Redirect back to the app
              _paymentStatus(request.url);

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  // Function to handle back navigation
  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Make Payment",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                _controller.goBack();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()), // Loading indicator
            if (_hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    const Text(
                      "Failed to load page",
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _controller.loadRequest(Uri.parse(widget.url));
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
