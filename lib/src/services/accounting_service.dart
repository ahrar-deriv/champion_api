import '../models/balance.dart';

/// Service for account balance operations
class AccountingService {
  final dynamic _apiClient;

  /// Creates a new accounting service
  AccountingService(this._apiClient);

  /// Get current account balance
  ///
  /// Calls: GET /v1/accounting/balance
  Future<Balance> getBalance() async {
    final response = await _apiClient.get('/accounting/balance');

    if (response.containsKey('data')) {
      return Balance.fromJson(response['data'] as Map<String, dynamic>);
    }

    return Balance.fromJson(response);
  }

  /// Stream real-time balance updates
  ///
  /// Calls: GET /v1/accounting/balance/stream
  Stream<Balance> streamBalance() async* {
    await for (final data
        in _apiClient.getStream('/accounting/balance/stream')) {
      // Handle the response structure: {"data":{...}}
      if (data.containsKey('data')) {
        yield Balance.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        yield Balance.fromJson(data);
      }
    }
  }

  /// Reset balance to default value
  ///
  /// Calls: POST /v1/accounting/balance/reset
  Future<Balance> resetBalance() async {
    final response = await _apiClient.post('/accounting/balance/reset');

    if (response.containsKey('data')) {
      return Balance.fromJson(response['data'] as Map<String, dynamic>);
    }

    return Balance.fromJson(response);
  }
}
