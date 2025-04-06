import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:client_portal/core/utils/api_config.dart';
import 'package:client_portal/presentation/screens/registration/thank_you_screen.dart';
import 'package:client_portal/presentation/widgets/confirmation_modal.dart';
import 'package:client_portal/presentation/widgets/custom_loader.dart';
import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/api_service_with_file.dart';
import '../../../utils/AppColors.dart';
import '../../../utils/custom_page_route.dart';
import '../../../utils/session_manager.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_checkbox.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_notification_bar.dart';
import '../../widgets/custom_progress_bar.dart';
import '../../widgets/custom_text_feild.dart';
import '../../widgets/dynamic_image_picker_slider.dart';
import '../../widgets/nid_image_picker_slider.dart';
import '../../widgets/reusable_button.dart';
import '../deposit/payment_web_view_screen.dart';

class InformationScreen extends StatefulWidget {
  int step;
  Map<String, dynamic> data;
  InformationScreen({super.key, required this.step, required this.data});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  String? amount;

  // Step 1
  File? nidFront;
  File? nidBack;
  File? photo;

  // Step 2
  String? name;
  String? fathersName;
  String? mothersName;
  String? dateOfBirth;
  String? nid;
  String? gender;
  String? residency;

  // Step 3
  String? addressLine1;
  String? city;
  String? zipCode;
  String? state;
  String country = "Bangladesh";

  // Step 4
  String? bankName;
  String? selectedBranch;
  String? branchName;
  String? routingNumber;
  String? accountNo;
  bool boLinked = false;
  //If Link BO selected
  String? boNumber;
  String? boType;
  //If select BO type = JOINT
  String? joinName;
  String? jointEmail;
  String? jointAddress;

  // Step 5
  File? signature;
  File? chequeLeaf;
  //If select Link BO
  File? boAttachment;
  //If select BO type = JOINT
  File? jointPicture;
  File? jointSignature;
  File? jointNidFront;
  File? jointNidBack;

  bool _isLoading = false;
  int currentStep = 0;
  int expandedIndex = 0;
  String? userId;

  @override
  void initState() {
    super.initState();
    currentStep = widget.step;
    setInfo(widget.data);
    getAmount();
  }

  List<File?> documentPhotos = List.filled(7, null);
  List<File?> nidPhotos = List.filled(3, null);
  List<String> stepTitles = [
    "NID Photos",
    "Personal Details",
    "Address",
    "Bank Details",
    "Documents",
    "Confirm Details"
  ];
  List<String> nothing = ['Signature', 'Cheque Leaf'];
  List<String> onlyBo = ['Signature', 'Cheque Leaf', 'BO Attachment'];
  List<String> onlyJoint = ['Signature', 'Cheque Leaf', 'Joint Holder Photo', 'Joint Holder Signature', 'Joint Holder Nid Front', 'Joint Holder Nid Back'];
  List<String> jointAndBo = ['Signature', 'Cheque Leaf', 'BO Attachment', 'Joint Holder Photo', 'Joint Holder Signature', 'Joint Holder Nid Front', 'Joint Holder Nid Back'];

  final List<String> bankList = ["Bank A", "Bank B", "Bank C"];
  final List<String> genderList = ["MALE", "FEMALE", "OTHER"];
  final List<String> boTypeList = ["SINGLE", "JOINT", "CORPORATE"];
  final List<String> residentList = ["RESIDENT", "NON_RESIDENT"];
  final Map<String, List<String>> branchList = {
    "Bank A": ["Branch A1 - 012930", "Branch A2 - 458344"],
    "Bank B": ["Branch B1 - 218732", "Branch B2 - 374834"],
    "Bank C": ["Branch C1 - 384788", "Branch C2 - 238742"],
  };

  void _nextStep() {
    setState(() {
      if (currentStep < stepTitles.length - 1) {
        currentStep = currentStep + 1;
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep = currentStep - 1;
      }
    });
  }

  void onStepTap(int goto){
    if(goto < currentStep){
      setState(() {
        currentStep = goto;
      });
    }
  }

  Future<void> setInfo(Map<String, dynamic> data) async {
    // Assigning values to all fields from the decoded JSON response
    userId = data["id"]?.toString() ?? "";
    name = data["name"]?.toString() ?? "";
    fathersName = data["fathersName"]?.toString() ?? "";
    mothersName = data["mothersName"]?.toString() ?? "";
    dateOfBirth = data["dateOfBirth"]?.toString() ?? "";
    nid = data["nid"]?.toString() ?? "";

    gender = data["gender"]?.toString();
    residency = data["residency"]?.toString();

    addressLine1 = data["addressLine1"]?.toString() ?? "";
    city = data["city"]?.toString() ?? "";
    state = data["state"]?.toString() ?? "";
    zipCode = data["zipCode"]?.toString() ?? "";
    country = data["country"]?.toString() ?? "Bangladesh";

    bankName = data["bankName"]?.toString();
    branchName = data["branchName"]?.toString();
    routingNumber = data["routingNumber"]?.toString();

    if (bankName != null && routingNumber != null) {
      selectedBranch = "$branchName - $routingNumber";
    }

    accountNo = data["accountNo"]?.toString() ?? "";

    // boLinked is a boolean field
    boLinked = data["boLinked"] is bool ? data["boLinked"] : false;

    boType = data["boType"]?.toString();

    if (boType == "JOINT" && data["JointAccountDto"] != null) {
      joinName = data["JointAccountDto"]["name"]?.toString() ?? "";
      jointEmail = data["JointAccountDto"]["email"]?.toString() ?? "";
      jointAddress = data["JointAccountDto"]["address"]?.toString() ?? "";
    }
  }

  Future<void> _uploadNidImages() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> data = {
        "mobileNumber": SessionManager.getMobileNumber(),
        "email": SessionManager.getEmail(),
      };

      log("Calling API: POST public/account-open-ekyc", name: "API_CALL");
      log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
      log("NidFront file: ${nidFront!.path}", name: "API_CALL");
      log("NidBack file: ${nidBack!.path}", name: "API_CALL");
      log("photo file: ${photo!.path}", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "public/account-open-ekyc",
        baseUrl: ApiConfig.baseUrlClientPortal,
        method: "POST",
        data: data,
        files: {
          "nidFront": nidFront!,
          "nidBack": nidBack!,
          "photo": photo!,
        },
      );

      log("Response from public/account-open-ekyc API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      }else{
        // Decoding the response JSON string
        Map<String, dynamic> data = json.decode(response.content!);
        await setInfo(data);
        _nextStep();
      }
    } catch (e) {
      showCustomNotification(context, e.toString(), Colors.red);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _savePersonalInfo() async {
    // Call to save personal information
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> data = {
        "mobileNumber": SessionManager.getMobileNumber(),
        "email": SessionManager.getEmail(),
        "name": name,
        "gender": gender,
        "nid": nid,
        "fathersName": fathersName,
        "mothersName": mothersName,
        "dateOfBirth": dateOfBirth,
        "residency": residency,
      };

      log("Calling API: POST public/account-open-personal-details", name: "API_CALL");
      log("Request Data: ${jsonEncode(data)}", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "public/account-open-personal-details",
        baseUrl: ApiConfig.baseUrlClientPortal,
        method: "POST",
        data: data,
      );

      log("Response from public/account-open-personal-details API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      }else{
        // Decoding the response JSON string
        Map<String, dynamic> data = json.decode(response.content!);
        await setInfo(data);
        _nextStep();
      }
    } catch (e) {
      showCustomNotification(context, e.toString(), Colors.red);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveAddressInfo() async {
    // Call to save personal information
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> data = {
        "mobileNumber": SessionManager.getMobileNumber(),
        "addressLine1": addressLine1,
        "city": city,
        "country": country,
        "state": state,
        "zipCode": zipCode
      };

      log("Calling API: POST public/account-open-address", name: "API_CALL");
      log("Request Data: ${jsonEncode(data)}", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "public/account-open-address",
        baseUrl: ApiConfig.baseUrlClientPortal,
        method: "POST",
        data: data,
      );

      log("Response from public/account-open-address API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      }else{
        // Decoding the response JSON string
        Map<String, dynamic> data = json.decode(response.content!);
        await setInfo(data);
        _nextStep();
      }
    } catch (e) {
      showCustomNotification(context, e.toString(), Colors.red);
    }
    setState(() {
      _isLoading = false;
    });

  }

  Future<void> _saveBankInfo() async {
    // Call to save personal information
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> data = {
        "mobileNumber": SessionManager.getMobileNumber(),
        "bankName": bankName,
        "branchName": branchName,
        "routingNumber": routingNumber,
        "accountNo": accountNo,
        "boType": boType,
        "boLinked": boLinked,
        "boNumber": boNumber ?? "N/A",
        "jointAccountName": joinName ?? "N/A",
        "jointAccountEmail": jointEmail ?? "N/A",
        "jointAccountAddress": jointAddress ?? "N/A",
      };

      log("Calling API: POST public/account-open-bank-details", name: "API_CALL");
      log("Request Data: ${jsonEncode(data)}", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "public/account-open-bank-details",
        baseUrl: ApiConfig.baseUrlClientPortal,
        method: "POST",
        data: data,
      );

      log("Response from public/account-open-bank-details API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      }else{
        // Decoding the response JSON string
        Map<String, dynamic> data = json.decode(response.content!);
        await setInfo(data);
        _nextStep();
      }
    } catch (e) {
      showCustomNotification(context, e.toString(), Colors.red);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveDocuments() async {
    // Call to save images and documents
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> data = {
        "mobileNumber": SessionManager.getMobileNumber(),
        "email": SessionManager.getEmail(),
      };
      final apiService = ApiServiceWithFile();

      log("Calling API: POST public/account-open-documents", name: "API_CALL");
      log("Request Data: ${jsonEncode(data)}", name: "API_CALL");
      log("Signature file: ${signature!.path}", name: "API_CALL");
      log("chequeLeaf file: ${chequeLeaf!.path}", name: "API_CALL");
      log("boAttachment file: ${boAttachment!.path}", name: "API_CALL");
      log("jointPicture file: ${jointPicture!.path}", name: "API_CALL");
      log("jointSignature file: ${jointSignature!.path}", name: "API_CALL");
      log("jointNidFront file: ${jointNidFront!.path}", name: "API_CALL");
      log("jointNidBack file: ${jointNidBack!.path}", name: "API_CALL");

      final response = await apiService.apiCall(
        endpoint: "public/account-open-documents",
        baseUrl: ApiConfig.baseUrlClientPortal,
        method: "POST",
        data: data,
        files: {
          "signature": signature ?? await _copyAssetToTemp('assets/background.gif'),
          "chequeLeaf": chequeLeaf ?? await _copyAssetToTemp('assets/background.gif'),
          "boAttachment": boAttachment ?? await _copyAssetToTemp('assets/background.gif'),
          "jointAccountPhoto": jointPicture ?? await _copyAssetToTemp('assets/background.gif'),
          "jointAccountSignature": jointSignature ?? await _copyAssetToTemp('assets/background.gif'),
          "jointAccountNidFront": jointNidFront ?? await _copyAssetToTemp('assets/background.gif'),
          "jointAccountNidBack": jointNidBack ?? await _copyAssetToTemp('assets/background.gif'),
        },
      );

      log("Response from public/account-open-documents API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      }else{
        // Decoding the response JSON string
        Map<String, dynamic> data = json.decode(response.content!);
        await setInfo(data);
        _nextStep();
      }
    } catch (e) {
      showCustomNotification(context, e.toString(), Colors.red);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _openAccount() async {
    showConfirmationDialog(
      context: context,
      title: "Do you want to proceed?",
      onConfirm: onConfirm,
    );
  }

  Future<void> onConfirm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure required data is not null
      String? email = SessionManager.getEmail();
      String? mobileNumber = SessionManager.getMobileNumber();

      if (email == null || mobileNumber == null) {
        showCustomNotification(context, "Email or Mobile Number is missing", Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      Map<String, dynamic> data = {
        "totalAmount": amount,
        "transactionId": "txn_123456789",
        "customerName": name,
        "customerEmail": email,
        "customerAddress": addressLine1,
        "customerCity": city,
        "customerState": state,
        "customerPostCode": zipCode,
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

// Helper function to handle redirection
  void _redirectToPaymentGateway(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentWebViewScreen(url: url, userId: userId!, successRedirectPage: ThankYouPage(), onSuccessPayment: _onSuccessPayment, type: 'FEE',),
      ),
    );
  }

  Future<void> _onSuccessPayment() async{
    try {

      log("Calling API: POST public/account-open-final?partialAccountId=$userId", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "public/account-open-final?partialAccountId=$userId",
        baseUrl: ApiConfig.baseUrlClientPortal,
        method: "POST",
      );

      log("Response from public/account-open-final?partialAccountId=$userId API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      }else{
        // Map<String, dynamic> data = json.decode(response.content!);
        Navigator.push(
            context,
            CustomPageRoute(page: ThankYouPage())
        );
      }
    } catch (e) {
      showCustomNotification(context, e.toString(), Colors.red);
    }
  }

  Future<void> separateBranchNameAndNumber(String branch) async {
    final regex = RegExp(r"^(.+?)\s*-\s*(\d+)$");
    final match = regex.firstMatch(branch);

    if (match != null) {
      branchName = match.group(1)?.trim() ?? ''; // Part before '-'
      routingNumber = match.group(2) ?? '';         // Part after '-'
    } else {
      showCustomNotification(context, "Invalid Branch Selected!", Colors.red);
    }
  }

  Future<File> _copyAssetToTemp(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/background.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  // Function to handle the selected images
  void _handleImagesSelected(List<File?> images) {
    setState(() {
      nidPhotos = images;
    });
    setState(() {
      nidFront = images[0];
      nidBack = images[1];
      photo = images[2];
    });
  }

  // Function to handle the selected images
  void _handleDocumentImagesSelected(List<File?> images) {
    setState(() {
      documentPhotos = images;
    });
    print('Document Length : $documentPhotos');
    if (images.isNotEmpty) {
      setState(() {
        signature = images[0];
        chequeLeaf = images[1];
        if(boLinked == true) {
          boAttachment = images[2];
          jointPicture = images[3];
          jointSignature = images[4];
          jointNidFront = images[5];
          jointNidBack = images[6];
        }
        else{
          jointPicture = images[2];
          jointSignature = images[3];
          jointNidFront = images[4];
          jointNidBack = images[5];
        }
      });
    }
    print('Singature : $signature');
    print('ChequeLeaf : $chequeLeaf');
    print('BO Attachment : $boAttachment');
    print('Joint Photo : $jointPicture');
    print('Joint signature : $jointSignature');
    print('Joint Nid front : $jointNidFront');
    print('Joint Nid Back : $jointNidBack');
  }

  List<String> get headerList {
    if (boType == "JOINT" && boLinked == true) {
      return jointAndBo;
    } else if (boType == "JOINT") {
      return onlyJoint;
    } else if(boLinked == true){
      return onlyBo;
    } else{
      return nothing;
    }
  }

  final Map<int, UniqueKey> stepKeys = {};

  UniqueKey getDynamicKey(int step) {
    if (stepKeys.containsKey(step)) {
      return stepKeys[step]!;
    }

    UniqueKey newKey = UniqueKey();
    stepKeys[step] = newKey;
    return newKey;
  }

  Map<String, bool> emptyFields = {};

  Future<void> getAmount() async{
    setState(() {
      _isLoading = true;
    });
    try {

      log("Calling API: POST transaction/fee?medium=CLIENT_PORTAL&type=ACCOUNT_OPENING", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "transaction/fee?medium=CLIENT_PORTAL&type=ACCOUNT_OPENING",
        baseUrl: ApiConfig.baseUrlTransactionService,
        method: "GET",
      );

      log("Response from transaction/fee?medium=CLIENT_PORTAL&type=ACCOUNT_OPENING API: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
        setState(() {
          amount = "450";
        });
      }else{
         setState(() {
           amount = response.content ?? "450";
         });
      }
    } catch (e) {
      showCustomNotification(context, e.toString(), Colors.red);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "BO Account Opening",
        titleColor: Colors.white,
        onLeadingButtonPressed: () {
          Navigator.pop(context);
        },
        showBackButton: true, // You can make this dynamic
      ),
      body: GradientBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text(stepTitles[currentStep], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.secondaryBackgroundColor),)),
                  SizedBox(height: 8),
                  // Use the CustomProgressBar
                  CustomProgressBar.buildStepProgressBar(
                    6, // Total steps
                    currentStep, // Current step
                    onStepTap, // Callback function
                  ),
                  SizedBox(height: 4),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Step 1: NID Image Upload
                        if (currentStep == 0) ...[
                          NidImagePickerSlider(
                              key: getDynamicKey(0),  // Generate a key for step 0
                              headings: ['NID Front Side', 'NID Back Side', 'Capture a Selfie',],
                              photos: nidPhotos,
                              onImagesSelected: _handleImagesSelected
                          ),
                          SizedBox(height: 10),
                          CustomButton(
                            text: "Next",
                            onPressed: () async {
                              // List of required fields to check, focusing only on images
                              List<Map<String, dynamic>> requiredFields = [
                                {"label": "NID Front", "value": nidFront},
                                {"label": "NID Back", "value": nidBack},
                                {"label": "Capture a Selfie", "value": photo},
                              ];

                              // Find the first empty field or image
                              var firstEmptyField = requiredFields.firstWhere(
                                    (field) => field["value"] == null,
                                orElse: () => {},
                              );

                              // If an empty field or image is found, show a message
                              if (firstEmptyField.isNotEmpty) {
                                showCustomNotification(context, "${firstEmptyField["label"]} is required!", Colors.red);
                              } else {
                                // Call to save Documents and Photo
                                _uploadNidImages();
                              }
                            },
                            backgroundColor: AppColors.buttonColor,
                            textColor: AppColors.secondaryBackgroundColor,
                          ),
                        ],

                        // Step 2: Personal Information
                        if (currentStep == 1) ...[
                          CustomTextField(
                            label: "Name",
                            value: name,
                            onChanged: (value) {
                              setState(() {
                                name = value;
                                emptyFields["name"] = false; // Clear error when typing
                              });
                            },
                            isError: emptyFields["name"] ?? false,
                          ),

                          CustomTextField(
                            label: "Father Name",
                            value: fathersName,
                            onChanged: (value) {
                              setState(() {
                                fathersName = value;
                                emptyFields["fathersName"] = false; // Clear error when typing
                              });
                            },
                            isError: emptyFields["fathersName"] ?? false,
                          ),

                          CustomTextField(
                            label: "Mother Name",
                            value: mothersName,
                            onChanged: (value) {
                              setState(() {
                                mothersName = value;
                                emptyFields["mothersName"] = false; // Clear error when typing
                              });
                            },
                            isError: emptyFields["mothersName"] ?? false,
                          ),

                          CustomTextField(
                            label: "Date of Birth",
                            value: dateOfBirth,
                            onChanged: (value) {
                              setState(() {
                                dateOfBirth = value;
                                emptyFields["dateOfBirth"] = false; // Clear error when typing
                              });
                            },
                            isError: emptyFields["dateOfBirth"] ?? false,
                          ),

                          CustomTextField(
                            label: "NID No.",
                            value: nid,
                            onChanged: (value) {
                              setState(() {
                                nid = value;
                                emptyFields["nid"] = false; // Clear error when typing
                              });
                            },
                            isError: emptyFields["nid"] ?? false,
                          ),

                          CustomDropdown(
                            label: "Gender",
                            options: genderList,
                            selectedValue: gender,
                            onChanged: (value) {
                              setState(() {
                                gender = value;
                                emptyFields["gender"] = false;
                              });
                            },
                            isError: emptyFields["gender"] ?? false,
                          ),

                          CustomDropdown(
                            label: "Residency",
                            options: residentList,
                            selectedValue: residency,
                            onChanged: (value) {
                              setState(() {
                                residency = value;
                                emptyFields["residency"] = false; // Remove error when value is selected
                              });
                            },
                            isError: emptyFields["residency"] ?? false,
                          ),

                          CustomButton(
                            text: "Next",
                            onPressed: () {
                              setState(() {
                                emptyFields.clear();

                                if(name == null || name!.isEmpty){
                                  emptyFields["name"] = true;
                                }
                                if(fathersName == null || fathersName!.isEmpty){
                                  emptyFields["fathersName"] = true;
                                }
                                if(mothersName == null || mothersName!.isEmpty){
                                  emptyFields["mothersName"] = true;
                                }
                                if(dateOfBirth == null || dateOfBirth!.isEmpty){
                                  emptyFields["dateOfBirth"] = true;
                                }
                                if(nid == null || nid!.isEmpty){
                                  emptyFields["nid"] = true;
                                }
                                if(gender == null || gender!.isEmpty){
                                  emptyFields["gender"] = true;
                                }
                                if(residency == null || residency!.isEmpty){
                                  emptyFields["residency"] = true;
                                }
                                print(emptyFields);
                                // If every feilds have value finally submit
                                if (emptyFields.isEmpty) {
                                  _savePersonalInfo();
                                }
                              });
                            },
                            backgroundColor: AppColors.buttonColor,
                            textColor: AppColors.secondaryBackgroundColor,
                          ),
                        ],


                        // Step 2: Address
                        if (currentStep == 2) ...[
                          CustomTextField(
                            label: "Address Line 1",
                            value: addressLine1,
                            onChanged: (value) {
                              setState(() {
                                addressLine1 = value;
                                emptyFields["addressLine1"] = false; // Clear error when typing
                              });
                            },
                            isError: emptyFields["addressLine1"] ?? false,
                          ),

                          CustomTextField(
                            label: "City",
                            value: city,
                            onChanged: (value) {
                              setState(() {
                                city = value;
                                emptyFields["city"] = false; // Clear error when typing
                              });
                            },
                            isError: emptyFields["city"] ?? false,
                          ),

                          CustomTextField(
                            label: "Zip Code",
                            value: zipCode,
                            onChanged: (value) {
                              setState(() {
                                zipCode = value;
                                emptyFields["zipCode"] = false; // Clear error when typing
                              });
                            },
                            isError: emptyFields["zipCode"] ?? false,
                          ),

                          CustomTextField(
                            label: "State",
                            value: state,
                            onChanged: (value) {
                              setState(() {
                                state = value;
                                emptyFields["state"] = false; // Clear error when typing
                              });
                            },
                            isError: emptyFields["state"] ?? false,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              initialValue: "Bangladesh",
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "Country",
                                labelStyle: TextStyle(color: AppColors.secondaryBackgroundColor),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),

                          CustomButton(
                            text: "Next",
                            onPressed: () {
                              setState(() {
                                emptyFields.clear();
                                if(addressLine1 == null || addressLine1!.isEmpty){
                                  emptyFields["addressLine1"] = true;
                                }
                                if(city == null || city!.isEmpty){
                                  emptyFields["city"] = true;
                                }
                                if(zipCode == null || zipCode!.isEmpty){
                                  emptyFields["zipCode"] = true;
                                }
                                if(state == null || state!.isEmpty){
                                  emptyFields["state"] = true;
                                }

                                if(emptyFields.isEmpty){
                                  // call to save address
                                  _saveAddressInfo();
                                }
                              });
                            },
                            backgroundColor: AppColors.buttonColor,
                            textColor: AppColors.secondaryBackgroundColor,
                          ),

                        ],

                        // Step 4: Bank Information
                        if (currentStep == 3) ...[
                          CustomDropdown(
                            label: "Bank Name",
                            options: bankList,
                            selectedValue: bankName,
                            onChanged: (value) {
                              setState(() {
                                selectedBranch = null;
                                branchName = null;
                                routingNumber = null;
                                bankName = value;
                                emptyFields["bankName"] = false; // Remove error when value is selected
                              });
                            },
                            isError: emptyFields["bankName"] ?? false,
                          ),
                          if (bankName != null)
                            CustomDropdown(
                              label: "Branch Name",
                              options: branchList[bankName]!,
                              selectedValue: selectedBranch,
                              onChanged: (value) {
                                setState(() {
                                  selectedBranch = value;
                                  emptyFields["selectedBranch"] = false;
                                });
                              },
                              isError: emptyFields["selectedBranch"] ?? false,
                            ),


                          CustomTextField(
                            label: "Bank Account Number",
                            value: accountNo,
                            onChanged: (value) {
                              setState(() {
                                accountNo = value;
                                emptyFields["accountNo"] = false; // Clear error when typing
                              });
                            },
                            isError: emptyFields["accountNo"] ?? false,
                          ),

                          CustomDropdown(
                            label: "BO Type",
                            options: boTypeList,
                            selectedValue: boType,
                            onChanged: (value) {
                              setState(() {
                                boType = value;
                                emptyFields["boType"] = false;
                              });
                            },
                            isError: emptyFields["boType"] ?? false,
                          ),

                          if(boType == "JOINT")...[
                            CustomTextField(
                              label: "Joint Holder Name",
                              value: joinName,
                              onChanged: (value) {
                                setState(() {
                                  joinName = value;
                                  emptyFields["joinName"] = false; // Clear error when typing
                                });
                              },
                              isError: emptyFields["joinName"] ?? false,
                            ),
                            CustomTextField(
                              label: "Joint Holder Email",
                              value: jointEmail,
                              onChanged: (value) {
                                setState(() {
                                  jointEmail = value;
                                  emptyFields["jointEmail"] = false; // Clear error when typing
                                });
                              },
                              isError: emptyFields["jointEmail"] ?? false,
                            ),
                            CustomTextField(
                              label: "Joint Holder Address",
                              value: jointAddress,
                              onChanged: (value) {
                                setState(() {
                                  jointAddress = value;
                                  emptyFields["jointAddress"] = false; // Clear error when typing
                                });
                              },
                              isError: emptyFields["jointAddress"] ?? false,
                            ),
                          ],
                          CustomCheckbox(
                            label: "BO Link",
                            value: boLinked,
                            onChanged: (value) {
                              setState(() {
                                boLinked = value ?? false;
                              });
                            },
                          ),
                          if (boLinked) ...[
                            CustomTextField(
                              label: "BO Number",
                              value: boNumber,
                              onChanged: (value) {
                                setState(() {
                                  boNumber = value;
                                  emptyFields["boNumber"] = false; // Clear error when typing
                                });
                              },
                              isError: emptyFields["boNumber"] ?? false,
                            ),
                          ],
                          SizedBox(height: 10),
                          CustomButton(
                            text: "Next",
                            onPressed: () async {
                              setState(() {
                                emptyFields.clear();
                                if(bankName == null || bankName!.isEmpty){
                                  emptyFields["bankName"] = true;
                                }
                                if(accountNo == null || accountNo!.isEmpty){
                                  emptyFields["accountNo"] = true;
                                }
                                if(boType == null || boType!.isEmpty){
                                  emptyFields["boType"] = true;
                                }
                                if(branchName == null || branchName!.isEmpty){
                                  emptyFields["branchName"] = true;
                                }

                                // If "BO Link" is checked, BO fields are required
                                if (boLinked) {
                                  if(boNumber == null || boNumber!.isEmpty){
                                    emptyFields["boNumber"] = true;
                                  }
                                }
                                if(boType == "JOINT"){
                                  if(joinName == null || joinName!.isEmpty){
                                    emptyFields["joinName"] = true;
                                  }
                                  if(jointEmail == null || jointEmail!.isEmpty){
                                    emptyFields["jointEmail"] = true;
                                  }
                                  if(jointAddress == null || jointAddress!.isEmpty){
                                    emptyFields["jointAddress"] = true;
                                  }
                                }
                                if(selectedBranch == null || selectedBranch!.isEmpty){
                                  emptyFields["selectedBranch"] = true;
                                  return;
                                }
                                separateBranchNameAndNumber(selectedBranch!);
                                print(emptyFields);
                                if(emptyFields.isEmpty){
                                  // Call to save bank info
                                  _saveBankInfo();
                                }
                              });
                            },
                            backgroundColor: AppColors.buttonColor,
                            textColor: AppColors.secondaryBackgroundColor,
                          ),
                        ],

                        // Step 5: Documents & Images
                        if (currentStep == 4) ...[
                          DynamicImagePickerSlider(
                              key: getDynamicKey(4),  // Generate a key for step 4
                              headings: headerList,
                              photos: documentPhotos,
                              onImagesSelected: _handleDocumentImagesSelected
                          ),
                          SizedBox(height: 10.0,),
                          CustomButton(
                            text: "Next",
                            onPressed: () async {
                              // List of required fields to check, focusing only on images
                              List<Map<String, dynamic>> requiredFields = [
                                {"label": "Signature", "value": signature},
                                {"label": "Check Leaf", "value": chequeLeaf},
                              ];
                              if (boLinked) {
                                requiredFields.addAll([
                                  {"label": "BO Attachment", "value": boAttachment},
                                ]);
                              }
                              if (boType == "JOINT") {
                                requiredFields.addAll([
                                  {"label": "Joint holder photo", "value": jointPicture},
                                  {"label": "Joint holder signature", "value": jointSignature},
                                  {"label": "Joint holder NID front", "value": jointNidFront},
                                  {"label": "Joint holder NID back", "value": jointNidBack},
                                ]);
                              }
                              // Find the first empty field or image
                              var firstEmptyField = requiredFields.firstWhere(
                                    (field) => field["value"] == null,
                                orElse: () => {},
                              );

                              // If an empty field or image is found, show a message
                              if (firstEmptyField.isNotEmpty) {
                                showCustomNotification(context, "${firstEmptyField["label"]} is required!", Colors.red);
                              } else {
                                // Call to save Documents and Photo
                                _saveDocuments();
                              }
                            },
                            backgroundColor: AppColors.buttonColor,
                            textColor: AppColors.secondaryBackgroundColor,
                          )
                        ],

                        // Step 6: Confirm Details
                        if(currentStep == 5)...[
                          buildExpansionTile(0, "Personal Details", Icons.person, [
                            _buildInfoRow(Icons.person, "Name", name?.toString() ?? ""),
                            _buildInfoRow(Icons.man, "Father's Name", fathersName?.toString() ?? ""),
                            _buildInfoRow(Icons.woman, "Mother's Name", mothersName?.toString() ?? ""),
                            _buildInfoRow(Icons.cake, "Date of Birth", dateOfBirth?.toString() ?? ""),
                            _buildInfoRow(Icons.person_pin, "NID No.", nid?.toString() ?? ""),
                            _buildInfoRow(Icons.person_pin, "Gender", gender?.toString() ?? ""),
                            _buildInfoRow(Icons.person_pin, "Residency", residency?.toString() ?? ""),
                          ], () {
                            setState(() => currentStep = 1);
                          }),

                          // Divider(),

                          buildExpansionTile(1, "Address", Icons.home, [
                            _buildInfoRow(Icons.home, "Address Line 1", addressLine1?.toString() ?? ""),
                            _buildInfoRow(Icons.location_city, "City", city?.toString() ?? ""),
                            _buildInfoRow(Icons.pin_drop, "Zip Code", zipCode?.toString() ?? ""),
                            _buildInfoRow(Icons.map, "State", state?.toString() ?? ""),
                            _buildInfoRow(Icons.public, "Country", country.toString() ?? ""),
                          ], () {
                            setState(() => currentStep = 2);
                          }),

                          // Divider(),

                          buildExpansionTile(2, "Bank Details", Icons.account_balance, [
                            _buildInfoRow(Icons.account_balance, "Bank Name", bankName?.toString() ?? ""),
                            _buildInfoRow(Icons.location_on, "Branch Name", branchName?.toString() ?? ""),
                            _buildInfoRow(Icons.numbers, "Routing Number", routingNumber?.toString() ?? ""),
                            _buildInfoRow(Icons.credit_card, "Account Number", accountNo?.toString() ?? ""),
                          ], () {
                            setState(() => currentStep = 3);
                          }),
                          //
                          // Divider(),
                          //
                          // buildExpansionTile(3, "Contact Details", Icons.contact_mail, [
                          //   _buildInfoRow(Icons.email, "Email", SessionManager.getEmail()?.toString() ?? ""),
                          //   _buildInfoRow(Icons.phone, "Phone", SessionManager.getMobileNumber()?.toString() ?? ""),
                          // ], () {
                          //   setState(() => currentStep = 4);
                          // }),

                          SizedBox(height: 20,),
                          CustomButton(
                            text: "Pay $amount BDT",
                            onPressed: () async {
                              // Final Submit
                              _openAccount();
                            },
                            backgroundColor: AppColors.buttonColor,
                            textColor: AppColors.secondaryBackgroundColor,
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4), // Space between icon and text
                              Text(
                                "$amount BDT BO account opening fee set by CDBL.",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
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
  Widget buildExpansionTile(
      int index,
      String title,
      IconData icon,
      List<Widget> children,
      VoidCallback onEdit,
      ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white),
          title: _buildSectionTitle(title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (expandedIndex == index) // Show edit button only when expanded
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: onEdit, // Calls the function when edit is clicked
                )
              else // Show dropdown icon only when collapsed
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      expandedIndex = (expandedIndex == index ? null : index)!; // Toggle expansion
                    });
                  },
                ),
            ],
          ),
          onTap: () {
            setState(() {
              expandedIndex = (expandedIndex == index ? null : index)!; // Toggle expansion on tap
            });
          },
        ),
        if (expandedIndex == index) ...children, // Show children only if expanded
      ],
    );
  }
}


Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white, // White text for section titles
    ),
  );
}

Widget _buildInfoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(left: 18.0, top: 4.0),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.white), // White icon color
        SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), // White text for labels
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.white), // White text for values
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}