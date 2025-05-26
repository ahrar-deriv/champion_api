/// Exception thrown when the Champion API encounters an error
class ChampionApiException implements Exception {
  /// The error code returned by the API
  final String code;

  /// Human-readable error message
  final String message;

  /// HTTP status code
  final int statusCode;

  /// The endpoint that caused the error
  final String? endpoint;

  /// Additional error details
  final Map<String, dynamic>? details;

  const ChampionApiException({
    required this.code,
    required this.message,
    required this.statusCode,
    this.endpoint,
    this.details,
  });

  /// Creates an exception from an API error response
  factory ChampionApiException.fromResponse({
    required Map<String, dynamic> response,
    required int statusCode,
    String? endpoint,
  }) {
    final errors = response['errors'] as List<dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      final error = errors.first as Map<String, dynamic>;
      return ChampionApiException(
        code: error['code'] as String? ?? 'unknown_error',
        message: error['message'] as String? ?? 'Unknown error occurred',
        statusCode: statusCode,
        endpoint: endpoint,
        details: response,
      );
    }

    return ChampionApiException(
      code: 'unknown_error',
      message: 'Unknown error occurred',
      statusCode: statusCode,
      endpoint: endpoint,
      details: response,
    );
  }

  @override
  String toString() {
    return 'ChampionApiException(code: $code, message: $message, statusCode: $statusCode)';
  }
}
