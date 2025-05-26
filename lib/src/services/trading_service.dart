import '../models/contract.dart';
import '../models/proposal.dart';

/// Service for trading operations
class TradingService {
  final dynamic _apiClient;

  /// Creates a new trading service
  TradingService(this._apiClient);

  /// Get open contracts
  ///
  /// Calls: GET /v1/trading/contracts/open
  Future<List<Contract>> getOpenContracts({String? contractId}) async {
    final queryParams = <String, String>{};
    if (contractId != null) {
      queryParams['contract_id'] = contractId;
    }

    final response = await _apiClient.get('/trading/contracts/open',
        queryParams: queryParams);

    List<dynamic> contractsData;
    if (response.containsKey('data')) {
      if (response['data'] is List) {
        contractsData = response['data'] as List<dynamic>;
      } else {
        // Single contract returned
        contractsData = [response['data']];
      }
    } else if (response is List) {
      contractsData = response;
    } else {
      // Single contract returned
      contractsData = [response];
    }

    return contractsData
        .map((e) => Contract.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get closed contracts
  ///
  /// Calls: GET /v1/trading/contracts/close
  Future<List<Contract>> getClosedContracts({
    String? dateFrom,
    String? dateTo,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, String>{};
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _apiClient.get('/trading/contracts/close',
        queryParams: queryParams);

    List<dynamic> contractsData;
    if (response.containsKey('data')) {
      contractsData = response['data'] as List<dynamic>;
    } else {
      contractsData = response as List<dynamic>;
    }

    return contractsData
        .map((e) => Contract.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Stream open contracts updates
  ///
  /// Calls: GET /v1/trading/contracts/open/stream
  Stream<List<Contract>> streamOpenContracts() {
    return _apiClient.getStream('/trading/contracts/open/stream').map((data) {
      List<dynamic> contractsData;
      if (data.containsKey('data')) {
        contractsData = data['data'] as List<dynamic>;
      } else {
        contractsData = data as List<dynamic>;
      }

      return contractsData
          .map((e) => Contract.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Stream closed contracts updates
  ///
  /// Calls: GET /v1/trading/contracts/close/stream
  Stream<List<Contract>> streamClosedContracts() {
    return _apiClient.getStream('/trading/contracts/close/stream').map((data) {
      List<dynamic> contractsData;
      if (data.containsKey('data')) {
        contractsData = data['data'] as List<dynamic>;
      } else {
        contractsData = data as List<dynamic>;
      }

      return contractsData
          .map((e) => Contract.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Buy a new contract
  ///
  /// Calls: POST /v1/trading/contracts/buy
  Future<Contract> buyContract(Map<String, dynamic> contractRequest) async {
    final response = await _apiClient.post(
      '/trading/contracts/buy',
      body: contractRequest,
    );

    if (response.containsKey('data')) {
      return Contract.fromJson(response['data'] as Map<String, dynamic>);
    }

    return Contract.fromJson(response);
  }

  /// Buy a multiplier contract
  Future<Contract> buyMultiplierContract({
    required String instrumentId,
    required double amount,
    required int multiplier,
    required String tradeType, // 'up' or 'down'
    double? stopLoss,
    double? takeProfit,
  }) {
    final request = {
      'product_id': 'multipliers',
      'instrument_id': instrumentId,
      'amount': amount,
      'multiplier': multiplier,
      'trade_type': tradeType,
      if (stopLoss != null) 'stop_loss': stopLoss,
      if (takeProfit != null) 'take_profit': takeProfit,
    };

    return buyContract(request);
  }

  /// Buy an accumulator contract
  Future<Contract> buyAccumulatorContract({
    required String instrumentId,
    required double amount,
    required double growthRate,
  }) {
    final request = {
      'product_id': 'accumulators',
      'instrument_id': instrumentId,
      'amount': amount,
      'growth_rate': growthRate,
    };

    return buyContract(request);
  }

  /// Buy a rise/fall contract
  Future<Contract> buyRiseFallContract({
    required String instrumentId,
    required double amount,
    required int duration,
    required String tradeType, // 'rise' or 'fall'
  }) {
    final request = {
      'product_id': 'rise_fall',
      'instrument_id': instrumentId,
      'amount': amount,
      'duration': duration,
      'trade_type': tradeType,
    };

    return buyContract(request);
  }

  /// Sell an existing contract
  ///
  /// Calls: POST /v1/trading/contracts/sell
  Future<Map<String, dynamic>> sellContract(
      {required String contractId}) async {
    final response = await _apiClient.post(
      '/trading/contracts/sell',
      body: {'contract_id': contractId},
    );

    return response;
  }

  /// Cancel a contract (multipliers only)
  ///
  /// Calls: POST /v1/trading/contracts/cancel
  Future<Map<String, dynamic>> cancelContract(
      {required String contractId}) async {
    final queryParams = {'contract_id': contractId};

    final response = await _apiClient.post(
      '/trading/contracts/cancel',
      queryParams: queryParams,
    );

    return response;
  }

  /// Get a trading proposal
  ///
  /// Calls: POST /v1/trading/proposal
  Future<Proposal> getProposal(ProposalRequest request) async {
    final response = await _apiClient.post(
      '/trading/proposal',
      body: request.toJson(),
    );

    if (response.containsKey('data')) {
      return Proposal.fromJson(response['data'] as Map<String, dynamic>);
    }

    return Proposal.fromJson(response);
  }

  /// Get a multiplier proposal
  Future<Proposal> getMultiplierProposal({
    required String instrumentId,
    required double amount,
    required int multiplier,
    required String tradeType,
    double? stopLoss,
    double? takeProfit,
  }) {
    final request = MultiplierProposalRequest(
      productId: 'multipliers',
      instrumentId: instrumentId,
      amount: amount,
      multiplier: multiplier,
      tradeType: tradeType,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
    );

    return getProposal(request);
  }

  /// Get an accumulator proposal
  Future<Proposal> getAccumulatorProposal({
    required String instrumentId,
    required double amount,
    required double growthRate,
  }) {
    final request = AccumulatorProposalRequest(
      productId: 'accumulators',
      instrumentId: instrumentId,
      amount: amount,
      growthRate: growthRate,
    );

    return getProposal(request);
  }

  /// Get a rise/fall proposal
  Future<Proposal> getRiseFallProposal({
    required String instrumentId,
    required double amount,
    required int duration,
    required String tradeType,
  }) {
    final request = RiseFallProposalRequest(
      productId: 'rise_fall',
      instrumentId: instrumentId,
      amount: amount,
      duration: duration,
      tradeType: tradeType,
    );

    return getProposal(request);
  }

  /// Stream real-time proposals
  ///
  /// Calls: GET /v1/trading/proposal/stream
  Stream<Proposal> streamProposal({
    required String productId,
    required String instrumentId,
    required double amount,
    Map<String, dynamic>? additionalParams,
  }) {
    final queryParams = {
      'product_id': productId,
      'instrument_id': instrumentId,
      'amount': amount.toString(),
      ...?additionalParams
          ?.map((key, value) => MapEntry(key, value.toString())),
    };

    return _apiClient
        .getStream('/trading/proposal/stream', queryParams: queryParams)
        .map((data) {
      if (data.containsKey('data')) {
        return Proposal.fromJson(data['data'] as Map<String, dynamic>);
      }
      return Proposal.fromJson(data);
    });
  }
}
