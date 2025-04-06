import 'AccountAutoCompletionFields.dart';

class AccountCompletion {
  String? mobileNumber;
  String? email;
  bool? personalDetails;
  bool? bankDetails;
  bool? nomineeDetails;
  bool? nidPhotos;
  bool? address;
  bool? documents;
  late AccountAutoCompletionFields partialAccount;

  AccountCompletion({
    this.mobileNumber,
    this.email,
    this.personalDetails,
    this.bankDetails,
    this.nomineeDetails,
    this.nidPhotos,
    this.address,
    this.documents,
    required this.partialAccount,
  });

  AccountCompletion.fromJson(Map<String, dynamic> json) {
    mobileNumber = json['mobileNumber'];
    email = json['email'];
    personalDetails = json['personalDetails'];
    bankDetails = json['bankDetails'];
    nomineeDetails = json['nomineeDetails'];
    nidPhotos = json['nidPhotos'];
    address = json['address'];
    documents = json['documents'];

    // Parse partialAccount properly
    partialAccount = AccountAutoCompletionFields.fromJson(json['partialAccount']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['mobileNumber'] = mobileNumber;
    data['email'] = email;
    data['personalDetails'] = personalDetails;
    data['bankDetails'] = bankDetails;
    data['nomineeDetails'] = nomineeDetails;
    data['nidPhotos'] = nidPhotos;
    data['address'] = address;
    data['documents'] = documents;
    data['partialAccount'] = partialAccount.toJson(); // Convert object to JSON
    return data;
  }
}
