/// Trading proposal information
class Proposal {
  /// Ask price for the proposal
  final String askPrice;

  /// Proposal ID
  final String? id;

  /// Payout amount
  final String? payout;

  /// Spot price at proposal time
  final String? spot;

  /// Spot time
  final int? spotTime;

  const Proposal({
    required this.askPrice,
    this.id,
    this.payout,
    this.spot,
    this.spotTime,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      askPrice: json['ask_price'] as String,
      id: json['id'] as String?,
      payout: json['payout'] as String?,
      spot: json['spot'] as String?,
      spotTime: json['spot_time'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ask_price': askPrice,
      if (id != null) 'id': id,
      if (payout != null) 'payout': payout,
      if (spot != null) 'spot': spot,
      if (spotTime != null) 'spot_time': spotTime,
    };
  }

  @override
  String toString() {
    return 'Proposal(askPrice: $askPrice, id: $id, payout: $payout)';
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
