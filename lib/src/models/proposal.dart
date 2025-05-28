/// Trading proposal information
class Proposal {
  /// List of contract variants (for multipliers/accumulators)
  final List<ProposalVariant>? variants;

  /// Direct contract details (for rise/fall)
  final Map<String, dynamic>? contractDetails;

  /// Pricing tick ID (primarily for accumulators, may be at root of proposal data)
  final int? pricingTickId;

  const Proposal({
    this.variants,
    this.contractDetails,
    this.pricingTickId,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    final int? pricingTickId = json['pricing_tick_id'] as int?;

    if (json.containsKey('variants')) {
      // Multipliers/Accumulators structure
      return Proposal(
        variants: (json['variants'] as List<dynamic>)
            .map((e) => ProposalVariant.fromJson(e as Map<String, dynamic>))
            .toList(),
        pricingTickId: pricingTickId,
      );
    } else if (json.containsKey('contract_details')) {
      // Rise/Fall structure
      // For Rise/Fall, the contract_details are typically nested further,
      // e.g., response.proposal.contract_details
      // The service layer is responsible for passing the correct map here.
      return Proposal(
        contractDetails: json['contract_details'] as Map<String, dynamic>,
        pricingTickId:
            pricingTickId, // Might not be applicable but parse if present
      );
    } else {
      // Check if it's a Rise/Fall like structure where 'proposal' is the key
      // and contract_details might be inside it.
      // This case is more complex and usually handled by the service before calling Proposal.fromJson
      // For now, if only pricingTickId is present with no variants/contract_details, create with that.
      if (pricingTickId != null) {
        return Proposal(pricingTickId: pricingTickId);
      }
      throw ArgumentError(
          'Invalid proposal structure: missing variants or contract_details, or not a recognized structure.');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (variants != null) {
      json['variants'] = variants!.map((e) => e.toJson()).toList();
    }
    if (contractDetails != null) {
      json['contract_details'] = contractDetails;
    }
    if (pricingTickId != null) {
      json['pricing_tick_id'] = pricingTickId;
    }
    if (json.isEmpty) {
      throw StateError(
          'Proposal must have at least one field (variants, contractDetails, or pricingTickId)');
    }
    return json;
  }

  @override
  String toString() {
    final parts = <String>[];
    if (variants != null) {
      parts.add('variants: ${variants!.length}');
    }
    if (contractDetails != null) {
      parts.add('contractDetails: ${contractDetails?.keys.length} fields');
    }
    if (pricingTickId != null) {
      parts.add('pricingTickId: $pricingTickId');
    }
    return 'Proposal(${parts.join(', ')})';
  }
}

/// Proposal variant for different trade types
class ProposalVariant {
  /// Variant name (e.g., MULTUP, MULTDOWN)
  final String variant;

  /// Contract details
  final ProposalContractDetails contractDetails;

  const ProposalVariant({
    required this.variant,
    required this.contractDetails,
  });

  factory ProposalVariant.fromJson(Map<String, dynamic> json) {
    return ProposalVariant(
      variant: json['variant'] as String,
      contractDetails: ProposalContractDetails.fromJson(
          json['contract_details'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variant': variant,
      'contract_details': contractDetails.toJson(),
    };
  }

  @override
  String toString() {
    return 'ProposalVariant(variant: $variant, stake: ${contractDetails.stake})';
  }
}

/// Contract details within a proposal
class ProposalContractDetails {
  /// Bid price
  final String bidPrice;

  /// Bid price currency
  final String bidPriceCurrency;

  /// Commission (optional)
  final String? commission;

  /// Whether the contract is expired
  final bool isExpired;

  /// Whether the contract is sold
  final bool isSold;

  /// Whether valid to sell
  final bool isValidToSell;

  /// Market spot price information
  final ProposalMarketSpotPrice marketSpotPrice;

  /// Multiplier value (if applicable)
  final int? multiplier;

  /// Potential payout
  final String potentialPayout;

  /// Stake amount
  final String stake;

  /// Start time
  final int startTime;

  /// Contract status
  final String status;

  /// Growth rate (for accumulators)
  final double? growthRate;

  /// High barrier (for accumulators)
  final String? highBarrier;

  /// Low barrier (for accumulators)
  final String? lowBarrier;

  /// Maximum payout (for accumulators)
  final String? maximumPayout;

  /// Barrier spot distance (for accumulators)
  final String? barrierSpotDistance;

  /// Tick size barrier percentage (for accumulators)
  final String? tickSizeBarrierPercentage;

  /// Current payout (for accumulators)
  final String? currentPayout;

  /// Maximum ticks (for accumulators)
  final int? maximumTicks;

  /// Ticks stayed in (for accumulators)
  final List<int>? ticksStayedIn;

  /// Tick count (for accumulators and potentially others)
  final int? tickCount;

  /// Ticks passed (for accumulators and potentially others)
  final int? tickPassed;

  /// Cancellation details (for multipliers)
  final ProposalCancellation? cancellation;

  /// Limit order details (for multipliers, accumulators)
  final ProposalLimitOrder? limitOrder;

  /// Validation parameters (for multipliers, accumulators)
  final ProposalValidationParams? validationParams;

  /// Additional fields for different product types
  final Map<String, dynamic>? additionalFields;

  const ProposalContractDetails({
    required this.bidPrice,
    required this.bidPriceCurrency,
    this.commission,
    required this.isExpired,
    required this.isSold,
    required this.isValidToSell,
    required this.marketSpotPrice,
    this.multiplier,
    required this.potentialPayout,
    required this.stake,
    required this.startTime,
    required this.status,
    this.growthRate,
    this.highBarrier,
    this.lowBarrier,
    this.maximumPayout,
    this.barrierSpotDistance,
    this.tickSizeBarrierPercentage,
    this.currentPayout,
    this.maximumTicks,
    this.ticksStayedIn,
    this.tickCount,
    this.tickPassed,
    this.cancellation,
    this.limitOrder,
    this.validationParams,
    this.additionalFields,
  });

  factory ProposalContractDetails.fromJson(Map<String, dynamic> json) {
    return ProposalContractDetails(
      bidPrice: json['bid_price'] as String,
      bidPriceCurrency: json['bid_price_currency'] as String,
      commission: json['commission'] as String?,
      isExpired: json['is_expired'] as bool,
      isSold: json['is_sold'] as bool,
      isValidToSell: json['is_valid_to_sell'] as bool,
      marketSpotPrice: ProposalMarketSpotPrice.fromJson(
          json['market_spot_price'] as Map<String, dynamic>),
      multiplier: json['multiplier'] as int?,
      potentialPayout: json['potential_payout'] as String,
      stake: json['stake'] as String,
      startTime: json['start_time'] as int,
      status: json['status'] as String,
      growthRate: (json['growth_rate'] as num?)?.toDouble(),
      highBarrier: json['high_barrier'] as String?,
      lowBarrier: json['low_barrier'] as String?,
      maximumPayout: json['maximum_payout'] as String?,
      barrierSpotDistance: json['barrier_spot_distance'] as String?,
      tickSizeBarrierPercentage:
          json['tick_size_barrier_percentage'] as String?,
      currentPayout: json['current_payout'] as String?,
      maximumTicks: json['maximum_ticks'] as int?,
      ticksStayedIn: (json['ticks_stayed_in'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      tickCount: json['tick_count'] as int?,
      tickPassed: json['tick_passed'] as int?,
      cancellation: json.containsKey('cancellation')
          ? ProposalCancellation.fromJson(
              json['cancellation'] as Map<String, dynamic>)
          : null,
      limitOrder: json.containsKey('limit_order')
          ? ProposalLimitOrder.fromJson(
              json['limit_order'] as Map<String, dynamic>)
          : null,
      validationParams: json.containsKey('validation_params')
          ? ProposalValidationParams.fromJson(
              json['validation_params'] as Map<String, dynamic>)
          : null,
      additionalFields: Map<String, dynamic>.from(json)
        ..removeWhere((key, value) => [
              'bid_price',
              'bid_price_currency',
              'commission',
              'is_expired',
              'is_sold',
              'is_valid_to_sell',
              'market_spot_price',
              'multiplier',
              'potential_payout',
              'stake',
              'start_time',
              'status',
              'growth_rate',
              'high_barrier',
              'low_barrier',
              'maximum_payout',
              'barrier_spot_distance',
              'tick_size_barrier_percentage',
              'current_payout',
              'maximum_ticks',
              'ticks_stayed_in',
              'tick_count',
              'tick_passed',
              'cancellation',
              'limit_order',
              'validation_params',
            ].contains(key)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bid_price': bidPrice,
      'bid_price_currency': bidPriceCurrency,
      if (commission != null) 'commission': commission,
      'is_expired': isExpired,
      'is_sold': isSold,
      'is_valid_to_sell': isValidToSell,
      'market_spot_price': marketSpotPrice.toJson(),
      if (multiplier != null) 'multiplier': multiplier,
      'potential_payout': potentialPayout,
      'stake': stake,
      'start_time': startTime,
      'status': status,
      if (growthRate != null) 'growth_rate': growthRate,
      if (highBarrier != null) 'high_barrier': highBarrier,
      if (lowBarrier != null) 'low_barrier': lowBarrier,
      if (maximumPayout != null) 'maximum_payout': maximumPayout,
      if (barrierSpotDistance != null)
        'barrier_spot_distance': barrierSpotDistance,
      if (tickSizeBarrierPercentage != null)
        'tick_size_barrier_percentage': tickSizeBarrierPercentage,
      if (currentPayout != null) 'current_payout': currentPayout,
      if (maximumTicks != null) 'maximum_ticks': maximumTicks,
      if (ticksStayedIn != null) 'ticks_stayed_in': ticksStayedIn,
      if (tickCount != null) 'tick_count': tickCount,
      if (tickPassed != null) 'tick_passed': tickPassed,
      if (cancellation != null) 'cancellation': cancellation!.toJson(),
      if (limitOrder != null) 'limit_order': limitOrder!.toJson(),
      if (validationParams != null)
        'validation_params': validationParams!.toJson(),
      ...?additionalFields,
    };
  }
}

/// Market spot price information
class ProposalMarketSpotPrice {
  /// Epoch timestamp
  final int epoch;

  /// Price value
  final String price;

  const ProposalMarketSpotPrice({
    required this.epoch,
    required this.price,
  });

  factory ProposalMarketSpotPrice.fromJson(Map<String, dynamic> json) {
    return ProposalMarketSpotPrice(
      epoch: json['epoch'] as int,
      price: json['price'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'epoch': epoch,
      'price': price,
    };
  }

  @override
  String toString() {
    return 'ProposalMarketSpotPrice(price: $price, epoch: $epoch)';
  }
}

/// Proposal request for different product types
abstract class ProposalRequest {
  /// Product identifier
  final String productId;

  /// Instrument identifier
  final String instrumentId;

  /// Stake amount
  final double amount;

  const ProposalRequest({
    required this.productId,
    required this.instrumentId,
    required this.amount,
  });

  Map<String, dynamic> toJson();
}

/// Multiplier proposal request
class MultiplierProposalRequest extends ProposalRequest {
  /// Multiplier value
  final int multiplier;

  /// Stop loss amount (optional)
  final double? stopLoss;

  /// Take profit amount (optional)
  final double? takeProfit;

  /// Cancellation duration in minutes (optional)
  final int? cancellation;

  const MultiplierProposalRequest({
    required this.multiplier,
    this.stopLoss,
    this.takeProfit,
    this.cancellation,
    required super.productId,
    required super.instrumentId,
    required super.amount,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'product_id': productId,
      'instrument_id': instrumentId,
      'stake': amount.toString(), // API expects 'stake' for amount as string
      'multiplier': multiplier,
    };

    final Map<String, dynamic> limitOrder = {};
    if (stopLoss != null) {
      limitOrder['stop_loss'] = stopLoss;
    }
    if (takeProfit != null) {
      limitOrder['take_profit'] = takeProfit;
    }

    if (limitOrder.isNotEmpty) {
      json['limit_order'] = limitOrder;
    }

    if (cancellation != null) {
      json['cancellation'] = cancellation;
    }
    return json;
  }
}

/// Accumulator proposal request
class AccumulatorProposalRequest extends ProposalRequest {
  /// Growth rate
  final double growthRate;

  /// Take profit amount (optional)
  final double? takeProfit;

  const AccumulatorProposalRequest({
    required this.growthRate,
    this.takeProfit,
    required super.productId,
    required super.instrumentId,
    required super.amount,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'product_id': productId,
      'instrument_id': instrumentId,
      'stake': amount.toString(), // API expects 'stake' for amount as string
      'growth_rate': growthRate,
    };

    if (takeProfit != null) {
      json['limit_order'] = {'take_profit': takeProfit};
    }
    return json;
  }
}

/// Rise/Fall proposal request
class RiseFallProposalRequest extends ProposalRequest {
  /// Duration in seconds
  final int duration;

  /// Trade direction (rise/fall)
  final String tradeType;

  const RiseFallProposalRequest({
    required this.duration,
    required this.tradeType,
    required super.productId,
    required super.instrumentId,
    required super.amount,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'instrument_id': instrumentId,
      'amount': amount,
      'duration': duration,
      'trade_type': tradeType,
    };
  }
}

/// Cancellation details for a proposal (typically Multipliers)
class ProposalCancellation {
  /// Ask price for cancellation
  final String askPrice;

  /// Expiry timestamp for cancellation
  final int expiry;

  const ProposalCancellation({required this.askPrice, required this.expiry});

  factory ProposalCancellation.fromJson(Map<String, dynamic> json) {
    return ProposalCancellation(
      askPrice: json['ask_price'] as String,
      expiry: json['expiry'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ask_price': askPrice,
      'expiry': expiry,
    };
  }
}

/// Limit order details for a proposal
class ProposalLimitOrder {
  /// Take profit order details
  final ProposalOrderDetails? takeProfit;

  /// Stop loss order details
  final ProposalOrderDetails? stopLoss;

  /// Stop out order details (usually for Multipliers)
  final ProposalOrderDetails? stopOut;

  const ProposalLimitOrder({this.takeProfit, this.stopLoss, this.stopOut});

  factory ProposalLimitOrder.fromJson(Map<String, dynamic> json) {
    return ProposalLimitOrder(
      takeProfit: json.containsKey('take_profit')
          ? ProposalOrderDetails.fromJson(
              json['take_profit'] as Map<String, dynamic>)
          : null,
      stopLoss: json.containsKey('stop_loss')
          ? ProposalOrderDetails.fromJson(
              json['stop_loss'] as Map<String, dynamic>)
          : null,
      stopOut: json.containsKey('stop_out')
          ? ProposalOrderDetails.fromJson(
              json['stop_out'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (takeProfit != null) json['take_profit'] = takeProfit!.toJson();
    if (stopLoss != null) json['stop_loss'] = stopLoss!.toJson();
    if (stopOut != null) json['stop_out'] = stopOut!.toJson();
    return json;
  }
}

/// Details for a specific order type (take_profit, stop_loss, stop_out)
class ProposalOrderDetails {
  /// Display name for the order
  final String displayName;

  /// Order amount for display
  final String displayOrderAmount;

  /// Actual order amount
  final num orderAmount; // API shows 0.5 (num) for Multipliers

  /// Date of the order (epoch)
  final int orderDate;

  const ProposalOrderDetails({
    required this.displayName,
    required this.displayOrderAmount,
    required this.orderAmount,
    required this.orderDate,
  });

  factory ProposalOrderDetails.fromJson(Map<String, dynamic> json) {
    return ProposalOrderDetails(
      displayName: json['display_name'] as String,
      displayOrderAmount: json['display_order_amount'] as String,
      orderAmount: json['order_amount'] as num,
      orderDate: json['order_date'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'display_order_amount': displayOrderAmount,
      'order_amount': orderAmount,
      'order_date': orderDate,
    };
  }
}

/// Validation parameters for a proposal
class ProposalValidationParams {
  /// Stake validation rules
  final ProposalValidationRule? stake;

  /// Take profit validation rules
  final ProposalValidationRule? takeProfit;

  /// Stop loss validation rules
  final ProposalValidationRule? stopLoss;

  /// Max payout (for accumulators)
  final String? maxPayout;

  /// Max ticks (for accumulators)
  final int? maxTicks;

  const ProposalValidationParams({
    this.stake,
    this.takeProfit,
    this.stopLoss,
    this.maxPayout,
    this.maxTicks,
  });

  factory ProposalValidationParams.fromJson(Map<String, dynamic> json) {
    return ProposalValidationParams(
      stake: json.containsKey('stake')
          ? ProposalValidationRule.fromJson(
              json['stake'] as Map<String, dynamic>)
          : null,
      takeProfit: json.containsKey('take_profit')
          ? ProposalValidationRule.fromJson(
              json['take_profit'] as Map<String, dynamic>)
          : null,
      stopLoss: json.containsKey('stop_loss')
          ? ProposalValidationRule.fromJson(
              json['stop_loss'] as Map<String, dynamic>)
          : null,
      maxPayout: json['max_payout'] as String?,
      maxTicks: json['max_ticks'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (stake != null) json['stake'] = stake!.toJson();
    if (takeProfit != null) json['take_profit'] = takeProfit!.toJson();
    if (stopLoss != null) json['stop_loss'] = stopLoss!.toJson();
    if (maxPayout != null) json['max_payout'] = maxPayout;
    if (maxTicks != null) json['max_ticks'] = maxTicks;
    return json;
  }
}

/// Min/Max validation rule
class ProposalValidationRule {
  /// Minimum value (can be num or String based on API docs)
  final dynamic min;

  /// Maximum value (can be num or String based on API docs)
  final dynamic max;

  /// Options for multipliers
  final List<int>? options;

  const ProposalValidationRule({this.min, this.max, this.options});

  factory ProposalValidationRule.fromJson(Map<String, dynamic> json) {
    return ProposalValidationRule(
      min: json['min'], // Keep as dynamic since it can be num or String
      max: json['max'], // Keep as dynamic
      options:
          (json['options'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {};
    if (min != null) jsonMap['min'] = min;
    if (max != null) jsonMap['max'] = max;
    if (options != null) jsonMap['options'] = options;
    return jsonMap;
  }
}
