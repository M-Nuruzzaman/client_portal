// import 'package:flutter/cupertino.dart';
//
// class SslPaymentGateway extends StatefulWidget {
//   final String url;
//   final Widget successRedirectPage;
//   const SslPaymentGateway({super.key});
//
//   @override
//   State<SslPaymentGateway> createState() => _SslPaymentGatewayState();
// }
//
// class _SslPaymentGatewayState extends State<SslPaymentGateway> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }


// Future<void> _onSuccessPayment() async{
//   try {
//     final apiService = ApiServiceWithFile();
//     final response = await apiService.apiCall(
//       endpoint: "public/account-open-final?partialAccountId=${widget.userId}",
//       baseUrl: ApiConfig.baseUrlClientPortal,
//       method: "POST",
//     );
//     if (response.hasError) {
//       showCustomNotification(context, response.message, Colors.red);
//     }else{
//       // Map<String, dynamic> data = json.decode(response.content!);
//       Navigator.push(
//           context,
//           CustomPageRoute(page: widget.successRedirectPage)
//       );
//     }
//   } catch (e) {
//     showCustomNotification(context, e.toString(), Colors.red);
//   }
// }