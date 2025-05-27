import '../models/instrument.dart';
import '../models/ohlc.dart';
import '../models/tick.dart';
import '../models/product.dart';

/// Service for market data operations
class MarketService {
  final dynamic _apiClient;

  /// Creates a new market service
  MarketService(this._apiClient);

  /// List available trading instruments
  ///
  /// Calls: GET /v1/market/instruments
  Future<InstrumentsList> getInstruments({String? productId}) async {
    final queryParams = <String, String>{};
    if (productId != null) {
      queryParams['product_id'] = productId;
    }

    final response =
        await _apiClient.get('/market/instruments', queryParams: queryParams);

    if (response.containsKey('data')) {
      return InstrumentsList.fromJson(response['data'] as Map<String, dynamic>);
    }

    return InstrumentsList.fromJson(response);
  }

  /// Get historical OHLC candle data
  ///
  /// Calls: POST /v1/market/instruments/candles/history
  Future<OHLCHistory> getOHLCHistory(OHLCHistoryRequest request) async {
    final response = await _apiClient.post(
      '/market/instruments/candles/history',
      body: request.toJson(),
    );

    if (response.containsKey('data')) {
      return OHLCHistory.fromJson(response['data'] as Map<String, dynamic>);
    }

    return OHLCHistory.fromJson(response);
  }

  /// Stream real-time OHLC candle data
  ///
  /// Calls: GET /v1/market/instruments/candles/stream
  Stream<OHLC> streamOHLC({
    required String instrumentId,
    required int granularity,
  }) async* {
    final queryParams = {
      'instrument_id': instrumentId,
      'granularity': granularity.toString(),
    };

    await for (final data in _apiClient.getStream(
        '/market/instruments/candles/stream',
        queryParams: queryParams)) {
      // Handle the response structure: {"data":{"instrument_id":"...", "candles":[...]}}
      if (data.containsKey('data') && data['data'].containsKey('candles')) {
        final candles = data['data']['candles'] as List<dynamic>;
        for (final candleData in candles) {
          yield OHLC.fromJson(candleData as Map<String, dynamic>);
        }
      }
    }
  }

  /// Get historical tick data
  ///
  /// Calls: POST /v1/market/instruments/ticks/history
  Future<TickHistory> getTickHistory(TickHistoryRequest request) async {
    final response = await _apiClient.post(
      '/market/instruments/ticks/history',
      body: request.toJson(),
    );

    if (response.containsKey('data')) {
      return TickHistory.fromJson(response['data'] as Map<String, dynamic>);
    }

    return TickHistory.fromJson(response);
  }

  /// Stream real-time tick data
  ///
  /// Calls: GET /v1/market/instruments/ticks/stream
  Stream<Tick> streamTicks({required String instrumentId}) async* {
    final queryParams = {
      'instrument_id': instrumentId,
    };

    await for (final data in _apiClient.getStream(
        '/market/instruments/ticks/stream',
        queryParams: queryParams)) {
      // Handle the response structure: {"data":{"instrument_id":"R_50","ticks":[...]}}
      if (data.containsKey('data') && data['data'].containsKey('ticks')) {
        final ticks = data['data']['ticks'] as List<dynamic>;
        for (final tickData in ticks) {
          yield Tick.fromJson(tickData as Map<String, dynamic>);
        }
      }
    }
  }

  /// List available trading products
  ///
  /// Calls: GET /v1/market/products
  Future<ProductsList> getProducts() async {
    final response = await _apiClient.get('/market/products');

    if (response.containsKey('data')) {
      return ProductsList.fromJson(response['data'] as Map<String, dynamic>);
    }

    return ProductsList.fromJson(response);
  }

  /// Get product configuration details
  ///
  /// Calls: GET /v1/market/products/config
  Future<ProductConfig> getProductConfig({
    required String productId,
    required String instrumentId,
  }) async {
    final queryParams = {
      'product_id': productId,
      'instrument_id': instrumentId,
    };

    final response = await _apiClient.get('/market/products/config',
        queryParams: queryParams);

    if (response.containsKey('data')) {
      return ProductConfig.fromJson(response['data'] as Map<String, dynamic>);
    }

    return ProductConfig.fromJson(response);
  }
}
