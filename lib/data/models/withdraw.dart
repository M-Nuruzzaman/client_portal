import 'package:intl/intl.dart';

class Withdraw {
  final double totalAmount;
  final String status;
  final String initiatedOn;

  Withdraw({
    required this.totalAmount,
    required this.status,
    required this.initiatedOn,
  });

  factory Withdraw.fromJson(Map<String, dynamic> json) {
    // Parse initiatedOn and format accordingly
    String rawInitiatedOn = json['initiatedOn'] as String;
    DateTime dateTime = DateTime.parse(rawInitiatedOn);
    DateTime today = DateTime.now();

    String formattedInitiatedOn;
    if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day) {
      formattedInitiatedOn = DateFormat('HH:mm:ss').format(dateTime);
    } else {
      formattedInitiatedOn = DateFormat('yyyy-MM-dd').format(dateTime);
    }

    return Withdraw(
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      initiatedOn: formattedInitiatedOn, // Formatted initiatedOn
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'status': status,
      'initiatedOn': initiatedOn, // Formatted initiatedOn
    };
  }
}
