class AccountCompletion {
  String? mobileNumber;
  bool? personalDetails;
  bool? bankDetails;
  bool? nomineeDetails;

  AccountCompletion(
      {this.mobileNumber,
        this.personalDetails,
        this.bankDetails,
        this.nomineeDetails});

  AccountCompletion.fromJson(Map<String, dynamic> json) {
    mobileNumber = json['mobileNumber'];
    personalDetails = json['personalDetails'];
    bankDetails = json['bankDetails'];
    nomineeDetails = json['nomineeDetails'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mobileNumber'] = this.mobileNumber;
    data['personalDetails'] = this.personalDetails;
    data['bankDetails'] = this.bankDetails;
    data['nomineeDetails'] = this.nomineeDetails;
    return data;
  }
}