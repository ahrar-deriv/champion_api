import 'dart:convert';
import 'package:http/http.dart' as http;

import 'services/accounting_service.dart';
import 'services/market_service.dart';
import 'services/trading_service.dart';
import 'services/admin_service.dart';
import 'exceptions/champion_api_exception.dart';

/// Main API client for Champion API
class ChampionApi {
  /// Base URL for the API
  final String baseUrl;

  /// HTTP client instance
  final http.Client _client;

  /// Accounting service instance
  late final AccountingService accounting;

  /// Market service instance
  late final MarketService market;

  /// Trading service instance
  late final TradingService trading;

  /// Admin service instance
  late final AdminService admin;

  /// Creates a new Champion API client
  ChampionApi({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client() {
    // Initialize service instances
    accounting = AccountingService(this);
    market = MarketService(this);
    trading = TradingService(this);
    admin = AdminService(this);
  }

  /// Disposes of the HTTP client
  void dispose() {
    _client.close();
  }

  /// Makes a GET request to the API
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams);

    try {
      final response = await _client.get(
        uri,
        headers: _getHeaders(),
      );

      return _handleResponse(response, endpoint);
    } catch (e) {
      throw ChampionApiException(
        code: 'network_error',
        message: 'Failed to make GET request: $e',
        statusCode: 0,
        endpoint: endpoint,
      );
    }
  }

  /// Makes a POST request to the API
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams);

    try {
      final response = await _client.post(
        uri,
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response, endpoint);
    } catch (e) {
      throw ChampionApiException(
        code: 'network_error',
        message: 'Failed to make POST request: $e',
        statusCode: 0,
        endpoint: endpoint,
      );
    }
  }

  /// Makes a streaming GET request for Server-Sent Events
  Stream<Map<String, dynamic>> getStream(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async* {
    final uri = _buildUri(endpoint, queryParams);

    try {
      final request = http.Request('GET', uri);
      request.headers.addAll(_getHeaders());
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      final streamedResponse = await _client.send(request);

      if (streamedResponse.statusCode != 200) {
        throw ChampionApiException(
          code: 'http_error',
          message: 'Stream request failed',
          statusCode: streamedResponse.statusCode,
          endpoint: endpoint,
        );
      }

      await for (final chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonData = line.substring(6).trim();
            if (jsonData.isNotEmpty && jsonData != '[DONE]') {
              try {
                final data = jsonDecode(jsonData) as Map<String, dynamic>;
                yield data;
              } catch (e) {
                // Skip malformed JSON
                continue;
              }
            }
          }
        }
      }
    } catch (e) {
      throw ChampionApiException(
        code: 'stream_error',
        message: 'Failed to establish stream: $e',
        statusCode: 0,
        endpoint: endpoint,
      );
    }
  }

  /// Builds URI with query parameters
  Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    final url = '$baseUrl$endpoint';
    final uri = Uri.parse(url);

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }

    return uri;
  }

  /// Gets default headers for requests
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Handles HTTP response and error checking
  Map<String, dynamic> _handleResponse(
      http.Response response, String endpoint) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }

      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw ChampionApiException(
          code: 'parse_error',
          message: 'Failed to parse response JSON: $e',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    }

    // Handle error responses
    Map<String, dynamic>? errorData;
    try {
      if (response.body.isNotEmpty) {
        errorData = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // If we can't parse the error response, create a generic error
    }

    if (errorData != null) {
      throw ChampionApiException.fromResponse(
        response: errorData,
        statusCode: response.statusCode,
        endpoint: endpoint,
      );
    }

    throw ChampionApiException(
      code: 'http_error',
      message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      statusCode: response.statusCode,
      endpoint: endpoint,
    );
  }
}
