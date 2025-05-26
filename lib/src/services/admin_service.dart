/// Service for administrative operations
class AdminService {
  final dynamic _apiClient;

  /// Creates a new admin service
  AdminService(this._apiClient);

  /// Reset entire mock state
  ///
  /// Calls: POST /v1/admin/reset
  Future<Map<String, dynamic>> resetState() async {
    final response = await _apiClient.post('/admin/reset');
    return response;
  }
}
