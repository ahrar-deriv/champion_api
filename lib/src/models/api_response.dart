/// Base API response wrapper that contains data and metadata
class ApiResponse<T> {
  /// The response data
  final T data;

  /// Response metadata
  final ApiMeta meta;

  const ApiResponse({
    required this.data,
    required this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return ApiResponse(
      data: fromJsonT(json['data'] as Map<String, dynamic>),
      meta: ApiMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T value) toJsonT) {
    return {
      'data': toJsonT(data),
      'meta': meta.toJson(),
    };
  }
}

/// API response metadata
class ApiMeta {
  /// The endpoint that was called
  final String endpoint;

  /// HTTP method used
  final String method;

  /// Response timing in milliseconds
  final int timing;

  const ApiMeta({
    required this.endpoint,
    required this.method,
    required this.timing,
  });

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      endpoint: json['endpoint'] as String,
      method: json['method'] as String,
      timing: json['timing'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'method': method,
      'timing': timing,
    };
  }
}
