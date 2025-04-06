import 'package:dio/dio.dart';

import '../../data/models/service_response.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<ServiceResponse> fetchData() async {
    try {
      Response response = await _dio.get('http://your-api-endpoint.com');

      if (response.statusCode == 428) {
        return ServiceResponse(
          hasError: false,
          message: "OTP Required",
          content: null,
        );
      } else if (response.statusCode == 200) {
        // Handle successful response
        return ServiceResponse.fromJson(response.data);
      } else {
        return ServiceResponse(
          hasError: true,
          message: "Error: ${response.statusMessage}",
        );
      }
    } catch (e) {
      return ServiceResponse(
        hasError: true,
        message: "Something went wrong: $e",
      );
    }
  }
}
