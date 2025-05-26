/// Trading contract information
class Contract {
  /// Unique contract identifier
  final String contractId;

  /// Product type (multipliers, accumulators, rise_fall)
  final String productId;

  /// Contract details specific to the product type
  final ContractDetails contractDetails;

  const Contract({
    required this.contractId,
    required this.productId,
    required this.contractDetails,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      contractId: json['contract_id'] as String,
      productId: json['product_id'] as String,
      contractDetails: ContractDetails.fromJson(
        json['contract_details'] as Map<String, dynamic>,
        json['product_id'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contract_id': contractId,
      'product_id': productId,
      'contract_details': contractDetails.toJson(),
    };
  }
}

/// Contract details base class
abstract class ContractDetails {
  /// Instrument identifier
  final String? instrumentId;

  /// Instrument name
  final String? instrumentName;

  /// Stake amount
  final String stake;

  /// Current bid price
  final String bidPrice;

  /// Bid price currency
  final String? bidPriceCurrency;

  /// Whether the contract is expired
  final bool isExpired;

  /// Whether the contract is valid to sell
  final bool isValidToSell;

  /// Whether the contract has been sold
  final bool isSold;

  /// Contract status
  final String? status;

  const ContractDetails({
    this.instrumentId,
    this.instrumentName,
    required this.stake,
    required this.bidPrice,
    this.bidPriceCurrency,
    required this.isExpired,
    required this.isValidToSell,
    required this.isSold,
    this.status,
  });

  factory ContractDetails.fromJson(
    Map<String, dynamic> json,
    String productId,
  ) {
    switch (productId) {
      case 'multipliers':
        return MultiplierContractDetails.fromJson(json);
      case 'accumulators':
        return AccumulatorContractDetails.fromJson(json);
      default:
        return RiseFallContractDetails.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

/// Multiplier contract details
class MultiplierContractDetails extends ContractDetails {
  /// Multiplier value
  final int multiplier;

  /// Commission amount
  final String commission;

  /// Cancellation information
  final Cancellation? cancellation;

  /// Trade variant (up/down)
  final String? variant;

  /// Current market spot price
  final MarketSpotPrice? marketSpotPrice;

  /// Entry spot price
  final String? entrySpot;

  /// Limit order information
  final LimitOrder? limitOrder;

  const MultiplierContractDetails({
    required this.multiplier,
    required this.commission,
    this.cancellation,
    this.variant,
    this.marketSpotPrice,
    this.entrySpot,
    this.limitOrder,
    required super.stake,
    required super.bidPrice,
    super.bidPriceCurrency,
    required super.isExpired,
    required super.isValidToSell,
    required super.isSold,
    super.instrumentId,
    super.instrumentName,
    super.status,
  });

  factory MultiplierContractDetails.fromJson(Map<String, dynamic> json) {
    return MultiplierContractDetails(
      multiplier: json['multiplier'] as int,
      commission: json['commission'] as String,
      cancellation: json['cancellation'] != null
          ? Cancellation.fromJson(json['cancellation'] as Map<String, dynamic>)
          : null,
      variant: json['variant'] as String?,
      marketSpotPrice: json['market_spot_price'] != null
          ? MarketSpotPrice.fromJson(
              json['market_spot_price'] as Map<String, dynamic>)
          : null,
      entrySpot: json['entry_spot'] as String?,
      limitOrder: json['limit_order'] != null
          ? LimitOrder.fromJson(json['limit_order'] as Map<String, dynamic>)
          : null,
      stake: json['stake'] as String,
      bidPrice: json['bid_price'] as String,
      bidPriceCurrency: json['bid_price_currency'] as String?,
      isExpired: json['is_expired'] as bool,
      isValidToSell: json['is_valid_to_sell'] as bool,
      isSold: json['is_sold'] as bool,
      instrumentId: json['instrument_id'] as String?,
      instrumentName: json['instrument_name'] as String?,
      status: json['status'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'multiplier': multiplier,
      'commission': commission,
      if (cancellation != null) 'cancellation': cancellation!.toJson(),
      if (variant != null) 'variant': variant,
      if (marketSpotPrice != null)
        'market_spot_price': marketSpotPrice!.toJson(),
      if (entrySpot != null) 'entry_spot': entrySpot,
      if (limitOrder != null) 'limit_order': limitOrder!.toJson(),
      'stake': stake,
      'bid_price': bidPrice,
      if (bidPriceCurrency != null) 'bid_price_currency': bidPriceCurrency,
      'is_expired': isExpired,
      'is_valid_to_sell': isValidToSell,
      'is_sold': isSold,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (instrumentName != null) 'instrument_name': instrumentName,
      if (status != null) 'status': status,
    };
  }
}

/// Accumulator contract details
class AccumulatorContractDetails extends ContractDetails {
  /// Growth rate
  final String? growthRate;

  /// High barrier
  final String? highBarrier;

  /// Low barrier
  final String? lowBarrier;

  /// Entry spot price
  final String? entrySpot;

  /// Tick count
  final int? tickCount;

  /// Ticks passed
  final int? tickPassed;

  const AccumulatorContractDetails({
    this.growthRate,
    this.highBarrier,
    this.lowBarrier,
    this.entrySpot,
    this.tickCount,
    this.tickPassed,
    required super.stake,
    required super.bidPrice,
    super.bidPriceCurrency,
    required super.isExpired,
    required super.isValidToSell,
    required super.isSold,
    super.instrumentId,
    super.instrumentName,
    super.status,
  });

  factory AccumulatorContractDetails.fromJson(Map<String, dynamic> json) {
    return AccumulatorContractDetails(
      growthRate: json['growth_rate'] as String?,
      highBarrier: json['high_barrier'] as String?,
      lowBarrier: json['low_barrier'] as String?,
      entrySpot: json['entry_spot'] as String?,
      tickCount: json['tick_count'] as int?,
      tickPassed: json['tick_passed'] as int?,
      stake: json['stake'] as String,
      bidPrice: json['bid_price'] as String,
      bidPriceCurrency: json['bid_price_currency'] as String?,
      isExpired: json['is_expired'] as bool,
      isValidToSell: json['is_valid_to_sell'] as bool,
      isSold: json['is_sold'] as bool,
      instrumentId: json['instrument_id'] as String?,
      instrumentName: json['instrument_name'] as String?,
      status: json['status'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (growthRate != null) 'growth_rate': growthRate,
      if (highBarrier != null) 'high_barrier': highBarrier,
      if (lowBarrier != null) 'low_barrier': lowBarrier,
      if (entrySpot != null) 'entry_spot': entrySpot,
      if (tickCount != null) 'tick_count': tickCount,
      if (tickPassed != null) 'tick_passed': tickPassed,
      'stake': stake,
      'bid_price': bidPrice,
      if (bidPriceCurrency != null) 'bid_price_currency': bidPriceCurrency,
      'is_expired': isExpired,
      'is_valid_to_sell': isValidToSell,
      'is_sold': isSold,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (instrumentName != null) 'instrument_name': instrumentName,
      if (status != null) 'status': status,
    };
  }
}

/// Rise/Fall contract details
class RiseFallContractDetails extends ContractDetails {
  /// Contract barrier
  final String? barrier;

  /// Entry spot price
  final String? entrySpot;

  /// Exit spot price
  final String? exitSpot;

  /// Trade variant (rise/fall)
  final String? variant;

  const RiseFallContractDetails({
    this.barrier,
    this.entrySpot,
    this.exitSpot,
    this.variant,
    required super.stake,
    required super.bidPrice,
    super.bidPriceCurrency,
    required super.isExpired,
    required super.isValidToSell,
    required super.isSold,
    super.instrumentId,
    super.instrumentName,
    super.status,
  });

  factory RiseFallContractDetails.fromJson(Map<String, dynamic> json) {
    return RiseFallContractDetails(
      barrier: json['barrier'] as String?,
      entrySpot: json['entry_spot'] as String?,
      exitSpot: json['exit_spot'] as String?,
      variant: json['variant'] as String?,
      stake: json['stake'] as String,
      bidPrice: json['bid_price'] as String,
      bidPriceCurrency: json['bid_price_currency'] as String?,
      isExpired: json['is_expired'] as bool,
      isValidToSell: json['is_valid_to_sell'] as bool,
      isSold: json['is_sold'] as bool,
      instrumentId: json['instrument_id'] as String?,
      instrumentName: json['instrument_name'] as String?,
      status: json['status'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (barrier != null) 'barrier': barrier,
      if (entrySpot != null) 'entry_spot': entrySpot,
      if (exitSpot != null) 'exit_spot': exitSpot,
      if (variant != null) 'variant': variant,
      'stake': stake,
      'bid_price': bidPrice,
      if (bidPriceCurrency != null) 'bid_price_currency': bidPriceCurrency,
      'is_expired': isExpired,
      'is_valid_to_sell': isValidToSell,
      'is_sold': isSold,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (instrumentName != null) 'instrument_name': instrumentName,
      if (status != null) 'status': status,
    };
  }
}

/// Supporting models

/// Cancellation information for multiplier contracts
class Cancellation {
  /// Cancellation ask price
  final String? askPrice;

  /// Cancellation expiry time
  final int? expiry;

  const Cancellation({
    this.askPrice,
    this.expiry,
  });

  factory Cancellation.fromJson(Map<String, dynamic> json) {
    return Cancellation(
      askPrice: json['ask_price'] as String?,
      expiry: json['expiry'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (askPrice != null) 'ask_price': askPrice,
      if (expiry != null) 'expiry': expiry,
    };
  }
}

/// Market spot price information
class MarketSpotPrice {
  /// Price epoch timestamp
  final int epoch;

  /// Current price
  final String price;

  const MarketSpotPrice({
    required this.epoch,
    required this.price,
  });

  factory MarketSpotPrice.fromJson(Map<String, dynamic> json) {
    return MarketSpotPrice(
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
}

/// Limit order information
class LimitOrder {
  /// Stop loss value
  final String? stopLoss;

  /// Take profit value
  final String? takeProfit;

  const LimitOrder({
    this.stopLoss,
    this.takeProfit,
  });

  factory LimitOrder.fromJson(Map<String, dynamic> json) {
    return LimitOrder(
      stopLoss: json['stop_loss'] as String?,
      takeProfit: json['take_profit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (stopLoss != null) 'stop_loss': stopLoss,
      if (takeProfit != null) 'take_profit': takeProfit,
    };
  }
}
