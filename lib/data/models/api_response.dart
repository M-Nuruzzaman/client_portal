class ApiResponse {
  final bool hasError;
  final String message;
  final dynamic content;

  ApiResponse({
    required this.hasError,
    required this.message,
    required this.content,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      hasError: json['hasError'] ?? false,
      message: json['message'] ?? '',
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasError': hasError,
      'message': message,
      'content': content,
    };
  }
}
