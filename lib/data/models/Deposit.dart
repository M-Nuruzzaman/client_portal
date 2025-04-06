import 'package:intl/intl.dart';

class Deposit {
  final String id;
  final String transactionId;
  final String customerMobileNumber;
  final double totalAmount;
  final String status;
  final String initiatedOn; // Already formatted!
  final String updatedAt;
  final bool duplicateDeposit;
  final List<String>? duplicateDepositIds;
  final String paymentMethod;
  final String paymentChannel;
  final String? specificChannel;
  final String? offlineDocument;
  final int approvalLevel;
  final bool checked;
  final dynamic approverDetails;

  Deposit({
    required this.id,
    required this.transactionId,
    required this.customerMobileNumber,
    required this.totalAmount,
    required this.status,
    required this.initiatedOn,
    required this.updatedAt,
    required this.duplicateDeposit,
    required this.duplicateDepositIds,
    required this.paymentMethod,
    required this.paymentChannel,
    required this.specificChannel,
    required this.offlineDocument,
    required this.approvalLevel,
    required this.checked,
    required this.approverDetails,
  });

  factory Deposit.fromJson(Map<String, dynamic> json) {
    // Parse initiatedOn and format accordingly
    String rawInitiatedOn = json['initiatedOn'] as String;
    DateTime dateTime = DateTime.parse(rawInitiatedOn);
    DateTime today = DateTime.now();

    String formattedInitiatedOn = DateFormat('HH:mm:ss dd-MM-yyyy').format(dateTime);

    return Deposit(
      id: json['id'] as String,
      transactionId: json['transactionId'] as String,
      customerMobileNumber: json['customerMobileNumber'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      initiatedOn: formattedInitiatedOn, // 🟢 Already formatted
      updatedAt: json['updatedAt'] as String,
      duplicateDeposit: json['duplicateDeposit'] as bool,
      duplicateDepositIds: json['duplicateDepositIds'] != null
          ? List<String>.from(json['duplicateDepositIds'])
          : null,
      paymentMethod: json['paymentMethod'] as String,
      paymentChannel: json['paymentChannel'] as String,
      specificChannel: json['specificChannel'] as String?,
      offlineDocument: json['offlineDocument'] as String?,
      approvalLevel: json['approvalLevel'] as int,
      checked: json['checked'] as bool,
      approverDetails: json['approverDetails'],
    );
  }
}
