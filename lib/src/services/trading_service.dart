import '../models/contract.dart';
import '../models/proposal.dart';
import 'dart:convert';

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
      final data = response['data'];
      if (data.containsKey('contracts')) {
        contractsData = data['contracts'] as List<dynamic>;
      } else if (data is List) {
        contractsData = data;
      } else {
        // Single contract returned
        contractsData = [data];
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
      final data = response['data'];
      if (data.containsKey('contracts')) {
        contractsData = data['contracts'] as List<dynamic>;
      } else if (data is List) {
        contractsData = data;
      } else {
        contractsData = [data];
      }
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
  Stream<List<Contract>> streamOpenContracts() async* {
    await for (final data
        in _apiClient.getStream('/trading/contracts/open/stream')) {
      List<dynamic> contractsData;
      if (data.containsKey('data')) {
        final responseData = data['data'];
        if (responseData.containsKey('contracts')) {
          contractsData = responseData['contracts'] as List<dynamic>;
        } else if (responseData is List) {
          contractsData = responseData;
        } else {
          contractsData = [responseData];
        }
      } else if (data is List) {
        contractsData = data;
      } else {
        contractsData = [data];
      }

      yield contractsData
          .map((e) => Contract.fromJson(e as Map<String, dynamic>))
          .toList();
    }
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
    required String
        tradeType, // 'up' or 'down' -> maps to variant MULTUP/MULTDOWN
    double? stopLoss,
    double? takeProfit,
    int? cancellation,
    String? idempotencyKey,
  }) async {
    final Map<String, dynamic> proposalDetails = {
      'instrument_id': instrumentId,
      'stake': amount.toString(), // API expects string
      'multiplier': multiplier, // API expects number
      'variant': tradeType.toUpperCase() == 'UP' ? 'MULTUP' : 'MULTDOWN',
    };

    final Map<String, dynamic> limitOrder = {};
    if (stopLoss != null) {
      limitOrder['stop_loss'] = stopLoss; // API expects number
    }
    if (takeProfit != null) {
      limitOrder['take_profit'] = takeProfit; // API expects number
    }

    if (limitOrder.isNotEmpty) {
      proposalDetails['limit_order'] = limitOrder;
    }

    if (cancellation != null) {
      proposalDetails['cancellation'] = cancellation; // API expects number
    }

    return _buyContract(
      productId: 'multipliers',
      proposalDetails: proposalDetails,
      idempotencyKey: idempotencyKey,
    );
  }

  /// Buy an accumulator contract
  Future<Contract> buyAccumulatorContract({
    required String instrumentId,
    required double amount,
    required double growthRate,
    double? takeProfit,
    String? idempotencyKey,
  }) async {
    final Map<String, dynamic> proposalDetails = {
      'instrument_id': instrumentId,
      'stake': amount.toString(), // API expects string
      'growth_rate': growthRate, // API expects number
    };

    if (takeProfit != null) {
      proposalDetails['limit_order'] = {
        'take_profit': takeProfit, // API expects number
      };
    }

    return _buyContract(
      productId: 'accumulators',
      proposalDetails: proposalDetails,
      idempotencyKey: idempotencyKey,
    );
  }

  /// Buy a rise/fall contract
  /// NOTE: The Champion API documentation for buying Rise/Fall via HTTP POST is unclear.
  /// This implementation attempts to match a plausible structure based on other product types
  /// and common fields from WebSocket specifications.
  /// This might be the source of the "instrument_id is required" error if the server
  /// expects a different format for product_id: 'rise_fall'.
  Future<Contract> buyRiseFallContract({
    required String instrumentId,
    required double amount,
    required int duration, // in seconds, typically
    required String
        tradeType, // 'rise' or 'fall' -> maps to contract_type CALL/PUT
    String durationUnit = 's', // Default to seconds
    String basis = 'stake', // Default to stake
    String? idempotencyKey,
  }) async {
    final String contractType;
    if (tradeType.toLowerCase() == 'rise') {
      contractType = 'CALL';
    } else if (tradeType.toLowerCase() == 'fall') {
      contractType = 'PUT';
    } else {
      // Potentially support other types if Champion API expands
      // For now, use tradeType directly if not rise/fall, though this might be incorrect.
      contractType = tradeType.toUpperCase();
    }

    final Map<String, dynamic> proposalDetails = {
      'instrument_id': instrumentId, // Mapping to 'symbol' in some API docs
      'stake': amount
          .toString(), // API expects string, maps to 'amount' in some docs
      'contract_type': contractType,
      'duration': duration, // API expects number
      'duration_unit': durationUnit,
      'basis': basis,
      // No direct equivalent for 'price' (max buy price) from WS spec in this structure
    };

    return _buyContract(
      productId:
          'rise_fall', // Or should this be based on contractType for some APIs?
      proposalDetails: proposalDetails,
      idempotencyKey: idempotencyKey,
    );
  }

  /// Generic buy contract method - now simplified
  Future<Contract> _buyContract({
    required String productId,
    required Map<String, dynamic>
        proposalDetails, // This is now pre-formed by the caller
    String? idempotencyKey,
  }) async {
    final String effectiveIdempotencyKey =
        idempotencyKey ?? DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, dynamic> body = {
      'idempotency_key': effectiveIdempotencyKey,
      'product_id': productId,
      'proposal_details': proposalDetails, // Use as is
    };

    final response =
        await _apiClient.post('/trading/contracts/buy', body: body);

    if (response.containsKey('data')) {
      return Contract.fromJson(response['data'] as Map<String, dynamic>);
    }

    return Contract.fromJson(response);
  }

  /// Sell an existing contract
  ///
  /// Calls: POST /v1/trading/contracts/sell
  Future<Map<String, dynamic>> sellContract(
      {required String contractId}) async {
    final response = await _apiClient.post(
      '/trading/contracts/sell',
      body: {
        'contract_id': contractId
      }, // Pass as a Map, client handles encoding
    );

    return response;
  }

  /// Cancel a contract (multipliers only)
  ///
  /// Calls: POST /v1/trading/contracts/cancel
  Future<Map<String, dynamic>> cancelContract(
      {required String contractId}) async {
    final response = await _apiClient.post(
      '/trading/contracts/cancel',
      body: {'contract_id': contractId},
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

  /// Get a trading proposal for a multiplier contract
  ///
  /// Calls: POST /v1/trading/proposal
  Future<Proposal> getMultiplierProposal({
    required String instrumentId,
    required double amount,
    required int multiplier,
    double? stopLoss,
    double? takeProfit,
    int? cancellation,
  }) async {
    final request = MultiplierProposalRequest(
      productId: 'multipliers',
      instrumentId: instrumentId,
      amount: amount, // Will be converted to 'stake' in toJson
      multiplier: multiplier,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      cancellation: cancellation,
    );

    return getProposal(request);
  }

  /// Get a trading proposal for an accumulator contract
  ///
  /// Calls: POST /v1/trading/proposal
  Future<Proposal> getAccumulatorProposal({
    required String instrumentId,
    required double amount,
    required double growthRate,
    double? takeProfit,
  }) async {
    final request = AccumulatorProposalRequest(
      productId: 'accumulators',
      instrumentId: instrumentId,
      amount: amount, // Will be converted to 'stake' in toJson
      growthRate: growthRate,
      takeProfit: takeProfit,
    );

    return getProposal(request);
  }

  /// Get a trading proposal for a rise/fall contract
  ///
  /// Calls: POST /v1/trading/proposal
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

  /// Stream proposal updates for a potential trade
  ///
  /// Calls: GET /v1/trading/proposal/stream
  Stream<Proposal> streamProposal({
    required String productId,
    required String instrumentId,
    required double amount, // This will be used as 'stake' in the query
    Map<String, dynamic> additionalParams = const {},
  }) async* {
    final queryParams = {
      'product_id': productId,
      'instrument_id': instrumentId,
      'stake': amount.toString(), // API expects 'stake'
      ...additionalParams.map((key, value) {
        // Ensure complex objects like limit_order are JSON strings if required by API
        if (value is Map || value is List) {
          return MapEntry(key, jsonEncode(value));
        }
        return MapEntry(key, value.toString());
      }),
    };

    final stream = _apiClient.getStream('/trading/proposal/stream',
        queryParams: queryParams);

    await for (final data in stream) {
      // Handle the response structure: {"data":{...}}
      if (data.containsKey('data')) {
        yield Proposal.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        yield Proposal.fromJson(data);
      }
    }
  }
}
