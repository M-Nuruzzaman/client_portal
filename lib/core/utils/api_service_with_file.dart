import 'dart:convert';
import 'dart:io';
import 'package:client_portal/data/models/service_response.dart';
import 'package:dio/dio.dart';

class ApiServiceWithFile {
  final Dio _dio;

  ApiServiceWithFile()
      : _dio = Dio(BaseOptions(
    validateStatus: (status) {
      return (status! >= 200 && status < 300) || status == 428;
    },
  ));

  Future<ServiceResponse> apiCall({
    required String endpoint,
    required String baseUrl,
    required String method, // GET, POST, DELETE, PUT
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    Map<String, File>? files, // New parameter for file uploads
  }) async {
    try {
      String url = '$baseUrl$endpoint';
      Response response;

      headers = {
        "Content-Type": files != null && files.isNotEmpty
            ? "multipart/form-data"
            : "application/json",
        ...?headers,
      };

      dynamic requestData;

      // Handle multipart file upload
      if (files != null && files.isNotEmpty) {
        FormData formData = FormData();

        // Add text fields
        if (data != null) {
          data.forEach((key, value) {
            formData.fields.add(MapEntry(key, value.toString()));
          });
        }

        // Add file fields
        for (var entry in files.entries) {
          formData.files.add(MapEntry(
            entry.key,
            await MultipartFile.fromFile(entry.value.path, filename: entry.value.path.split('/').last),
          ));
        }

        requestData = formData;
      } else {
        requestData = json.encode(data);
      }

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(url, options: Options(headers: headers));
          break;
        case 'POST':
          response = await _dio.post(url, options: Options(headers: headers), data: requestData);
          break;
        case 'PUT':
          response = await _dio.put(url, options: Options(headers: headers), data: requestData);
          break;
        case 'DELETE':
          response = await _dio.delete(url, options: Options(headers: headers));
          break;
        default:
          throw Exception("Invalid HTTP method: $method");
      }

      if (response.statusCode == 428) {
        return ServiceResponse(hasError: false, message: "OTP Required", content: null);
      } else if (response.statusCode == 200) {
        return ServiceResponse.fromJson(response.data);
      } else {
        return ServiceResponse(hasError: true, message: "Error: ${response.statusMessage}");
      }
    } catch (e) {
      return ServiceResponse(hasError: true, message: "Something went wrong: $e");
    }
  }
}
