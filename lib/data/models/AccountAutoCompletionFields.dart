class AccountAutoCompletionFields {
  String? id;
  String? name;
  String? gender;
  String? nid;
  String? email;
  String? mobileNumber;
  String? fathersName;
  String? mothersName;
  String? dateOfBirth;
  String? investorCode;
  String? residency;
  String? boType;
  String? addressLine1;
  String? city;
  String? country;
  String? state;
  String? zipCode;
  String? bankName;
  String? branchName;
  String? routingNumber;
  String? accountNo;

  // New fields for joint account
  String? jointAccountName;
  String? jointAccountMobileNumber;
  String? jointAccountEmail;
  String? jointAccountAddress;

  bool? active;
  String? transactionStatus;

  AccountAutoCompletionFields({
    this.id,
    this.name,
    this.gender,
    this.nid,
    this.email,
    this.mobileNumber,
    this.fathersName,
    this.mothersName,
    this.dateOfBirth,
    this.investorCode,
    this.residency,
    this.boType,
    this.addressLine1,
    this.city,
    this.country,
    this.state,
    this.zipCode,
    this.bankName,
    this.branchName,
    this.routingNumber,
    this.accountNo,
    this.jointAccountName,
    this.jointAccountMobileNumber,
    this.jointAccountEmail,
    this.jointAccountAddress,

    this.active,
    this.transactionStatus,
  });

  AccountAutoCompletionFields.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    gender = json['gender'];
    nid = json['nid'];
    email = json['email'];
    mobileNumber = json['mobileNumber'];
    fathersName = json['fathersName'];
    mothersName = json['mothersName'];
    dateOfBirth = json['dateOfBirth'];
    investorCode = json['investorCode'];
    residency = json['residency'];
    boType = json['boType'];
    addressLine1 = json['addressLine1'];
    city = json['city'];
    country = json['country'];
    state = json['state'];
    zipCode = json['zipCode'];
    bankName = json['bankName'];
    branchName = json['branchName'];
    routingNumber = json['routingNumber'];
    accountNo = json['accountNo'];

    // Parse joint account fields
    jointAccountName = json['jointAccountName'];
    jointAccountMobileNumber = json['jointAccountMobileNumber'];
    jointAccountEmail = json['jointAccountEmail'];
    jointAccountAddress = json['jointAccountAddress'];

    active = json['active'];
    transactionStatus = json['transactionStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['gender'] = gender;
    data['nid'] = nid;
    data['email'] = email;
    data['mobileNumber'] = mobileNumber;
    data['fathersName'] = fathersName;
    data['mothersName'] = mothersName;
    data['dateOfBirth'] = dateOfBirth;
    data['investorCode'] = investorCode;
    data['residency'] = residency;
    data['boType'] = boType;
    data['addressLine1'] = addressLine1;
    data['city'] = city;
    data['country'] = country;
    data['state'] = state;
    data['zipCode'] = zipCode;
    data['bankName'] = bankName;
    data['branchName'] = branchName;
    data['routingNumber'] = routingNumber;
    data['accountNo'] = accountNo;

    // Include joint account fields
    data['jointAccountName'] = jointAccountName;
    data['jointAccountMobileNumber'] = jointAccountMobileNumber;
    data['jointAccountEmail'] = jointAccountEmail;
    data['jointAccountAddress'] = jointAccountAddress;

    data['active'] = active;
    data['transactionStatus'];

    return data;
  }
}
