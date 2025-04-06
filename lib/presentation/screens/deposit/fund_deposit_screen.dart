import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:client_portal/presentation/screens/deposit/deposit_history_screen.dart';
import 'package:client_portal/presentation/screens/deposit/payment_web_view_screen.dart';
import 'package:client_portal/presentation/widgets/reusable_button.dart';
import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/api_config.dart';
import '../../../core/utils/api_service.dart';
import '../../../core/utils/api_service_with_file.dart';
import '../../../data/models/Bank.dart';
import '../../../data/models/service_response.dart';
import '../../../utils/AppColors.dart';
import '../../../utils/custom_page_route.dart';
import '../../../utils/session_manager.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/custom_notification_bar.dart';
import '../../widgets/image_picker_component.dart';
import 'deposit_review_screen.dart';

class FundDepositScreen extends StatefulWidget {
  const FundDepositScreen({super.key});

  @override
  State<FundDepositScreen> createState() => _FundDepositScreenState();
}

class _FundDepositScreenState extends State<FundDepositScreen> {
  String selectedOption = 'Online';
  final TextEditingController _amountController = TextEditingController();

  // Track selected tile index
  String? filePath; // To hold the selected file path
  File? document;
  int selectedTileIndex = 0;
  String selectedBank = "";
  String selectedMfs = "";
  bool _isLoading = false;
  double amount = 0.0;
  // List of bank names to display in the modal
  List<Bank> banks = [];
  List<Bank> mfs = [];
  ApiService _apiService = ApiService();


  @override
  void initState() {
    super.initState();
    _amountController.addListener(_amountListener);
    getInfo();
  }

  @override
  void dispose() {
    _amountController.removeListener(_amountListener);
    _amountController.dispose();
    super.dispose();
  }

  Future<void> getInfo() async{

    try {
      // Make the API call
      log("Calling API: GET banks", name: "API_CALL");
      ServiceResponse response = await _apiService.apiCall(
        endpoint: 'banks',
        baseUrl: ApiConfig.baseUrlCommonService,
        method: 'GET',
      );
      log("Response from banks API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError == true) {
        // Show the error message
        showCustomNotification(context, "Something went wrong", Colors.red);
      } else {
        List<dynamic> jsonList = jsonDecode(response.content!);

        List<Bank> bankList = jsonList.map((json) => Bank.fromJson(json)).toList();

        setState(() {
          banks = bankList;
        });
      }
    } catch (e) {
      // Handle any exceptions that occur
      showCustomNotification(context, "Error getting info!", Colors.red);
    }

    try {
      // Make the API call
      log("Calling API: GET mfs", name: "API_CALL");
      ServiceResponse response = await _apiService.apiCall(
        endpoint: 'mfs',
        baseUrl: ApiConfig.baseUrlCommonService,
        method: 'GET',
      );
      log("Response from mfs API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError == true) {
        // Show the error message
        showCustomNotification(context, "Something went wrong", Colors.red);
      } else {
        List<dynamic> jsonList = jsonDecode(response.content!);

        List<Bank> mfsList = jsonList.map((json) => Bank.fromJson(json)).toList();

        setState(() {
          mfs = mfsList;
        });
      }
    } catch (e) {
      // Handle any exceptions that occur
      showCustomNotification(context, "Error getting info!", Colors.red);
    }
  }


  // Update the selected image and notify parent
  void _onImageSelected(int index, File? selectedImage) {
    setState(() {
      document = selectedImage;
    });
  }

  // Function to pick a file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        filePath = result.files.single.path; // Get the selected file path
      });
    }
  }

  void openBankSelectionModal() async {
    // Show bottom modal sheet with bank names and logos
    String? selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: banks.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.network(
                  banks[index].logoUrl, // Display logo
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error), // Handle error
                ),
                title: Text(
                  banks[index].name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                onTap: () {
                  // Return the selected bank name and close the modal
                  Navigator.pop(context, banks[index].name);
                },
              );
            },
          ),
        );
      },
    );

    // If a bank was selected, update the selected bank name
    if (selected != null) {
      setState(() {
        selectedTileIndex = 1;
        selectedBank = selected;
        selectedMfs = "";
      });
    }
  }

  void openMfsSelectionModal() async {
    // Show bottom modal sheet with Mfs names
    String? selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: mfs.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.network(
                  mfs[index].logoUrl, // Display logo
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error), // Handle error
                ),
                title: Text(
                  mfs[index].name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                onTap: () {
                  // Return the selected bank name and close the modal
                  Navigator.pop(context, mfs[index].name);
                },
              );
            },
          ),
        );
      },
    );

    // If a Mfs was selected, update the selected mfs name
    if (selected != null) {
      setState(() {
        selectedTileIndex = 2;
        selectedMfs = selected;
        selectedBank = "";
      });
    }
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
  }

  Future<void> submit() async {
    String _amount = _amountController.text.trim();
    if (_amount.isNotEmpty) {
      // Remove first character (if needed)
      String cleanAmount = _amount.substring(1);

      // Convert String to double safely
      double? parsedAmount = double.tryParse(cleanAmount);

      if (parsedAmount != null && parsedAmount != 0) {
        setState(() {
          amount = parsedAmount;
        });
      } else {
        showCustomNotification(context, "Invalid amount", Colors.red);
        return;
      }
    } else {
      showCustomNotification(context, "Enter amount", Colors.red);
      return;
    }

    if(selectedOption == 'Online'){
      _onlinePayment();
    }
    else{
      _offlinePayment();
    }
    print('Deposit Button Clicked');
  }

  Future<void> _onlinePayment()async {
    if(selectedBank != ""){
      onBankPayment();
    }
    else if(selectedMfs != ""){
      onMfsPayment();
    }
    else {
      onSSLPayment();
    }
  }

  Future<void> _offlinePayment()async {
    if(document == null){
      showCustomNotification(context, "Select deposit document", Colors.red);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> data = {
        "mobileNumber": SessionManager.getMobileNumber()?? "01705942721",
        "email": SessionManager.getEmail()?? "nuruzzaman.dev@gmail.com",
        "amount": amount,
        "paymentMethod": "OFFLINE",
        "flaggedTransaction": false
      };

      log("Calling API: POST deposits/offline", name: "API_CALL");
      log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
      log("Uploading file: ${document!.path}", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "deposits/offline",
        baseUrl: ApiConfig.baseUrlTransactionService,
        method: "POST",
        data: data,
        files: {
          "file": document!
        },
      );

      log("Response from deposits/offline API: ${response.content}", name: "API_RESPONSE");

      if(response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      }else{
        Map<String, dynamic> data = json.decode(response.content!);
        if(data["duplicateDeposit"]){
          showConfirmationDialog(
            context: context,
            title: response.message,
            onConfirm: onOfflineDepositConfirm,
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        Navigator.push(
          context,
          CustomPageRoute(page: DepositReviewScreen()),
        );
        showCustomNotification(context, response.message, Colors.greenAccent);
      }
    } catch (e) {
      showCustomNotification(context, e.toString(), Colors.red);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> onOfflineDepositConfirm() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> data = {
        "mobileNumber": SessionManager.getMobileNumber()?? "01705942721",
        "email": SessionManager.getEmail()?? "nuruzzaman.dev@gmail.com",
        "amount": amount,
        "paymentMethod": "OFFLINE",
        "flaggedTransaction": true
      };

      log("Calling API: POST deposits/offline (Confirm)", name: "API_CALL");
      log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
      log("Uploading file: ${document!.path}", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "deposits/offline",
        baseUrl: ApiConfig.baseUrlTransactionService,
        method: "POST",
        data: data,
        files: {
          "file": document!
        },
      );

      log("Response from deposits/offline (Confirm) API: ${response.content}", name: "API_RESPONSE");

      if(response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      }else{
        showCustomNotification(context, response.message, Colors.greenAccent);
        Navigator.push(
          context,
          CustomPageRoute(page: DepositReviewScreen()),
        );
      }
    } catch (e) {
      showCustomNotification(context, e.toString(), Colors.red);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> onSSLPayment() async {

    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure required data is not null
      String? email = SessionManager.getEmail() ?? "nuruzzaman.dev@gmail.com";
      String? mobileNumber = SessionManager.getMobileNumber() ?? "01705942721";

      if (email == null || mobileNumber == null) {
        showCustomNotification(context, "Email or Mobile Number is missing", Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      Map<String, dynamic> data = {
        "totalAmount": amount,
        "transactionId": "txn_123456789",
        "customerName": "name",
        "customerEmail": email,
        "customerAddress": "addressLine1",
        "customerCity": "city",
        "customerState": "state",
        "customerPostCode": "zipCode",
        "customerCountry": "Bangladesh",
        "customerPhone": mobileNumber
      };

      log("Calling API: POST payment/initiate", name: "API_CALL");
      log("Request Data: ${jsonEncode(data)}", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "payment/initiate",
        baseUrl: ApiConfig.baseUrlTransactionService,
        method: "POST",
        data: data,
      );

      log("Response from payment/initiate API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      } else {
        // Assuming response.content contains the Payment Gateway URL
        String? paymentUrl = response.content;
        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          print("Redirecting to Payment Gateway...");
          _redirectToPaymentGateway(paymentUrl);
        } else {
          showCustomNotification(context, "Invalid payment URL received!", Colors.red);
        }
      }
    } catch (e) {
      showCustomNotification(context, "Error: ${e.toString()}", Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> onBankPayment() async {

    // THis is Bank Deposit Final call too redirect to Deposit success page
    setState(() {
      _isLoading = true;
    });
    try {
      // Ensure required data is not null
      String? email = SessionManager.getEmail() ?? "nuruzzaman.dev@gmail.com";
      String? mobileNumber = SessionManager.getMobileNumber() ?? "01705942721";

      if (email == null || mobileNumber == null) {
        showCustomNotification(context, "Email or Mobile Number is missing", Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      Map<String, dynamic> data = {
        "amount": amount,
        "mobileNumber": mobileNumber,
        "paymentMethod": "ONLINE",
        "paymentChannel": "BANK_TRANSFER",
        "specificChannel": selectedBank,
      };

      log("Calling API: POST deposits/online", name: "API_CALL");
      log("Request Data: ${jsonEncode(data)}", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "deposits/online",
        baseUrl: ApiConfig.baseUrlTransactionService,
        method: "POST",
        data: data,
      );

      log("Response from deposits/online API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      } else {
        Map<String, dynamic> data = json.decode(response.content!);
        if(data["status"] == "FAILED"){
          showCustomNotification(context, response.message, Colors.red);
        }
        else{
          showCustomNotification(context, response.message, Colors.greenAccent);
          Navigator.push(
            context,
            CustomPageRoute(page: DepositsScreen()),
          );
        }
      }
    } catch (e) {
      showCustomNotification(context, "Error: ${e.toString()}", Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> onMfsPayment() async {

    // THis is Mfs Deposit Final call too redirect to Deposit success page
    setState(() {
      _isLoading = true;
    });
    try {
      // Ensure required data is not null
      String? email = SessionManager.getEmail() ?? "nuruzzaman.dev@gmail.com";
      String? mobileNumber = SessionManager.getMobileNumber() ?? "01705942721";

      if (email == null || mobileNumber == null) {
        showCustomNotification(context, "Email or Mobile Number is missing", Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      Map<String, dynamic> data = {
        "amount": amount,
        "mobileNumber": mobileNumber,
        "paymentMethod": "ONLINE",
        "paymentChannel": "MFS",
        "specificChannel": selectedMfs,
      };

      log("Calling API: POST deposits/online", name: "API_CALL");
      log("Request Data: ${jsonEncode(data)}", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "deposits/online",
        baseUrl: ApiConfig.baseUrlTransactionService,
        method: "POST",
        data: data,
      );

      log("Response from deposits/online API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      } else {
        Map<String, dynamic> data = json.decode(response.content!);
        if(data["status"] == "FAILED"){
          showCustomNotification(context, response.message, Colors.red);
        }
        else{
          showCustomNotification(context, response.message, Colors.greenAccent);
          Navigator.push(
            context,
            CustomPageRoute(page: DepositsScreen()),
          );
        }
      }
    } catch (e) {
      showCustomNotification(context, "Error: ${e.toString()}", Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

// Helper function to handle redirection
  void _redirectToPaymentGateway(String url) {
    Navigator.push(
      context,
      CustomPageRoute(page: PaymentWebViewScreen(url: url, userId: "userId", successRedirectPage: DepositsScreen(), onSuccessPayment: _onSuccessPayment, type: 'DEPOSIT',)),
    );
  }
  //TODO: Need to change this function
  Future<void> _onSuccessPayment() async{
    Navigator.push(
        context,
        CustomPageRoute(page: DepositsScreen())
    );

    // try {
    //   final apiService = ApiServiceWithFile();
    //   final response = await apiService.apiCall(
    //     endpoint: "public/account-open-final?partialAccountId=userId",
    //     baseUrl: ApiConfig.baseUrlClientPortal,
    //     method: "POST",
    //   );
    //   if (response.hasError) {
    //     showCustomNotification(context, response.message, Colors.red);
    //   }else{
    //     // Map<String, dynamic> data = json.decode(response.content!);
    //     Navigator.push(
    //         context,
    //         CustomPageRoute(page: DepositsScreen(initialTab: 0,))
    //     );
    //   }
    // } catch (e) {
    //   showCustomNotification(context, e.toString(), Colors.red);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Fund Deposit",
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
                    const Text(
                      'Select Deposit Method',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedOption = 'Online';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedOption == 'Online' ? Colors.blueGrey : Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedOption == 'Online' ? AppColors.onSelect : Colors.grey,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Online',
                                style: TextStyle(
                                  color: selectedOption == 'Online' ? AppColors.onSelect : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (selectedOption == 'Online')
                                const Icon(Icons.check_circle_outlined, color: AppColors.onSelect, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0), // Adds space between the rows
                    // Offline Row
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedOption = 'Offline';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedOption == 'Offline' ? Colors.blueGrey : Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedOption == 'Offline' ? AppColors.onSelect : Colors.grey,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns text left and icon right
                            children: [
                              Text(
                                'Offline',
                                style: TextStyle(
                                  color: selectedOption == 'Offline' ? AppColors.onSelect : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (selectedOption == 'Offline')
                                const Icon(Icons.check_circle_outlined, color: AppColors.onSelect, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8.0),

                    // Show Online Options if selected
                    if (selectedOption == 'Online') ...[
                      const Text(
                        'Select Deposit Option',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8.0),

                      // SSL Payment Option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTileIndex = 0;
                            selectedMfs = "";
                            selectedBank = "";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedTileIndex == 0 ? Colors.blueGrey : Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedTileIndex == 0 ? AppColors.onSelect : Colors.grey,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'SSL Payment',
                                  style: TextStyle(
                                    color: selectedTileIndex == 0 ? AppColors.onSelect : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (selectedTileIndex == 0)
                                  const Icon(Icons.check_circle_outlined, color: AppColors.onSelect, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Bank Payment Option
                      GestureDetector(
                        onTap: () {
                          openBankSelectionModal();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedTileIndex == 1 ? Colors.blueGrey : Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedTileIndex == 1 ? Colors.greenAccent : Colors.grey,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bank Payment',
                                      style: TextStyle(
                                        color: selectedTileIndex == 1 ? Colors.greenAccent : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (selectedBank.isNotEmpty)
                                      Text(
                                        selectedBank,
                                        style: TextStyle(
                                          color: selectedTileIndex == 1 ? Colors.greenAccent : Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),
                                if (selectedTileIndex == 1)
                                  const Icon(
                                    Icons.check_circle_outlined,
                                    color: Colors.greenAccent,
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8.0),

                      // Mobile Banking Option
                      GestureDetector(
                        onTap: () {
                          openMfsSelectionModal();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedTileIndex == 2 ? Colors.blueGrey : Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedTileIndex == 2 ? Colors.greenAccent : Colors.grey,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mobile Banking',
                                      style: TextStyle(
                                        color: selectedTileIndex == 2 ? Colors.greenAccent : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (selectedMfs.isNotEmpty)
                                      Text(
                                        selectedMfs,
                                        style: TextStyle(
                                          color: selectedTileIndex == 2 ? Colors.greenAccent : Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),
                                if (selectedTileIndex == 2)
                                  const Icon(
                                    Icons.check_circle_outlined,
                                    color: Colors.greenAccent,
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Add Offline Options (Optional)
                    if (selectedOption == 'Offline') ...[
                      const SizedBox(height: 4.0),
                      // File Picker Section with Design
                      ImagePickerComponent(onImageSelected: _onImageSelected, heading: "Upload Deposit Document", index: 0),
                    ],
                    SizedBox(height: 30.0,),

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

                    SizedBox(height: 20.0),
                    CustomButton(
                      text: "Deposit",
                      onPressed: submit,
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
