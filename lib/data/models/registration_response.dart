
class RegistrationResponse {
  final String email;
  final String? investorCode;
  final String? password;
  final String mobileNumber;
  final String tempPassword;
  final DateTime tempPasswordExpiryTime;
  final bool tempPasswordActive;

  RegistrationResponse({
    required this.email,
    this.investorCode,
    this.password,
    required this.mobileNumber,
    required this.tempPassword,
    required this.tempPasswordExpiryTime,
    required this.tempPasswordActive,
  });

  // Factory constructor to create RegistrationResponse instance from JSON
  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      email: json['email'] ?? '',
      investorCode: json['investorCode'],
      password: json['password'],
      mobileNumber: json['mobileNumber'] ?? '',
      tempPassword: json['tempPassword'] ?? '',
      tempPasswordExpiryTime: DateTime.parse(json['tempPasswordExpiryTime']),
      tempPasswordActive: json['tempPasswordActive'] ?? false,
    );
  }

  // Method to convert RegistrationResponse instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'investorCode': investorCode,
      'password': password,
      'mobileNumber': mobileNumber,
      'tempPassword': tempPassword,
      'tempPasswordExpiryTime': tempPasswordExpiryTime.toIso8601String(),
      'tempPasswordActive': tempPasswordActive,
    };
  }
}
