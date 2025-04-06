class ServiceResponse {
  final bool hasError;
  final String message;
  final String? content;

  ServiceResponse({required this.hasError, required this.message, this.content});

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      hasError: json['hasError'] ?? false,
      message: json['message'] ?? '',
      content: json['content'],
    );
  }
}
