import 'dart:convert';
import 'package:client_portal/data/models/service_response.dart';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio(BaseOptions(
    validateStatus: (status) {
      // Allow status codes 200-299 and 428
      return (status! >= 200 && status < 300) || status == 428;
    },
  ));

  Future<ServiceResponse> apiCall({
    required String endpoint,
    required String baseUrl,
    required String method, // GET, POST, DELETE, PUT
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      String url = '$baseUrl$endpoint';
      Response response;

      headers = {
        "Content-Type": "application/json",
        ...?headers,
      };

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(url, options: Options(headers: headers));
          break;
        case 'POST':
          response = await _dio.post(
            url,
            options: Options(headers: headers),
            data: json.encode(data),
          );
          break;
        case 'PUT':
          response = await _dio.put(
            url,
            options: Options(headers: headers),
            data: json.encode(data),
          );
          break;
        case 'DELETE':
          response = await _dio.delete(url, options: Options(headers: headers));
          break;
        default:
          throw Exception("Invalid HTTP method: $method");
      }

      if (response.statusCode == 428) {
        // If OTP is required (status code 428), return a special ServiceResponse
        return ServiceResponse(
          hasError: false,
          message: "OTP Required",
          content: null,
        );
      } else if (response.statusCode == 200) {
        // If successful, map the response data to ServiceResponse
        return ServiceResponse.fromJson(response.data);
      } else {
        // If there's an error, return an error message with the status code
        return ServiceResponse(
          hasError: true,
          message: "Error: ${response.statusMessage}",
        );
      }
    } catch (e) {
      // Handle exceptions and return an error response
      return ServiceResponse(
        hasError: true,
        message: "Something went wrong",
      );
    }
  }
}
