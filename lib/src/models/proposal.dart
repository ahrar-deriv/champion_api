/// Trading proposal information
class Proposal {
  /// List of contract variants (for multipliers/accumulators)
  final List<ProposalVariant>? variants;

  /// Direct contract details (for rise/fall)
  final Map<String, dynamic>? contractDetails;

  const Proposal({
    this.variants,
    this.contractDetails,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('variants')) {
      // Multipliers/Accumulators structure
      return Proposal(
        variants: (json['variants'] as List<dynamic>)
            .map((e) => ProposalVariant.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (json.containsKey('contract_details')) {
      // Rise/Fall structure
      return Proposal(
        contractDetails: json['contract_details'] as Map<String, dynamic>,
      );
    } else {
      throw ArgumentError(
          'Invalid proposal structure: missing variants or contract_details');
    }
  }

  Map<String, dynamic> toJson() {
    if (variants != null) {
      return {
        'variants': variants!.map((e) => e.toJson()).toList(),
      };
    } else if (contractDetails != null) {
      return {
        'contract_details': contractDetails,
      };
    } else {
      throw StateError('Proposal must have either variants or contractDetails');
    }
  }

  @override
  String toString() {
    if (variants != null) {
      return 'Proposal(variants: ${variants!.length})';
    } else {
      return 'Proposal(contractDetails: ${contractDetails?.keys.length} fields)';
    }
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
              'maximum_payout'
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

  /// Trade direction (up/down)
  final String tradeType;

  /// Stop loss amount (optional)
  final double? stopLoss;

  /// Take profit amount (optional)
  final double? takeProfit;

  const MultiplierProposalRequest({
    required this.multiplier,
    required this.tradeType,
    this.stopLoss,
    this.takeProfit,
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
      'multiplier': multiplier,
      'trade_type': tradeType,
      if (stopLoss != null) 'stop_loss': stopLoss,
      if (takeProfit != null) 'take_profit': takeProfit,
    };
  }
}

/// Accumulator proposal request
class AccumulatorProposalRequest extends ProposalRequest {
  /// Growth rate
  final double growthRate;

  const AccumulatorProposalRequest({
    required this.growthRate,
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
      'growth_rate': growthRate,
    };
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
