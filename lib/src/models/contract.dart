/// Represents a trading contract
class Contract {
  /// Unique contract identifier
  final String contractId;

  /// Product identifier (e.g., multipliers, accumulators)
  final String productId;

  /// Price at which the contract was bought
  final String? buyPrice; // API often returns as string, can be null in streams

  /// Epoch timestamp of when the contract was bought
  final int? buyTime; // Can be null in streams if contract data is partial

  /// Idempotency key used for the buy request
  final String? idempotencyKey; // Present in buy response

  // Fields from sell response
  /// Price at which the contract was sold (optional)
  final String? sellPrice; // API often returns as string

  /// Profit/Loss of the contract after selling (optional)
  final String? profit; // API often returns as string

  /// Epoch timestamp of when the contract was sold (optional)
  final int? sellTime;

  /// Detailed information about the contract
  final ContractDetails contractDetails;

  const Contract({
    required this.contractId,
    required this.productId,
    this.buyPrice,
    this.buyTime,
    this.idempotencyKey,
    this.sellPrice,
    this.profit,
    this.sellTime,
    required this.contractDetails,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      contractId: json['contract_id'] as String,
      productId: json['product_id'] as String,
      buyPrice: json['buy_price'] as String?,
      buyTime: json['buy_time'] as int?,
      idempotencyKey: json['idempotency_key'] as String?,
      sellPrice: json['sell_price'] as String?,
      profit: json['profit'] as String?,
      sellTime: json['sell_time'] as int?,
      contractDetails: ContractDetails.fromJson(
          json['contract_details'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contract_id': contractId,
      'product_id': productId,
      if (buyPrice != null) 'buy_price': buyPrice,
      if (buyTime != null) 'buy_time': buyTime,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (sellPrice != null) 'sell_price': sellPrice,
      if (profit != null) 'profit': profit,
      if (sellTime != null) 'sell_time': sellTime,
      'contract_details': contractDetails.toJson(),
    };
  }

  @override
  String toString() {
    return 'Contract(id: $contractId, product: $productId, buyPrice: $buyPrice)';
  }
}

/// Detailed information about a contract
class ContractDetails {
  /// Instrument ID (from open/closed contracts)
  final String? instrumentId;

  /// Instrument display name (from open/closed contracts)
  final String? instrumentName;

  /// Profit or loss of the contract (from open/closed contracts, often a string with +/-)
  final String? profitLoss;

  /// Reference ID for the contract (from open/closed contracts)
  final String? referenceId;

  /// Start time of the contract (epoch)
  final int? contractStartTime;

  /// Entry tick time (epoch)
  final int? entryTickTime;

  /// Entry spot price
  final String? entrySpot; // API often returns as string

  /// Exit spot price (for closed contracts)
  final String? exitSpot;

  /// Exit tick time (for closed contracts)
  final int? exitTickTime;

  /// Contract variant (e.g., MULTUP, MULTDOWN)
  final String? variant;

  /// Multiplier value (if applicable)
  final int? multiplier;

  /// Commission charged
  final String? commission; // API often returns as string

  /// Stake amount
  final String? stake; // API often returns as string

  /// Current bid price
  final String? bidPrice; // API often returns as string

  /// Currency of the bid price
  final String? bidPriceCurrency;

  /// Whether the contract has expired
  final bool? isExpired;

  /// Whether the contract is valid to be sold
  final bool? isValidToSell;

  /// Whether the contract has been sold
  final bool? isSold;

  /// Potential payout of the contract
  final String? potentialPayout; // API often returns as string

  /// Cancellation details (if applicable)
  final CancellationDetails? cancellation;

  /// Limit order details (if applicable)
  final LimitOrderDetails? limitOrder;

  /// Current status of the contract (e.g., open, sold, won, lost)
  final String? status;

  /// Stream of ticks for the contract (if applicable)
  final List<TickInStream>? tickStream;

  /// Validation parameters (from buy response)
  final Map<String, dynamic>? validationParams; // Keep as map for flexibility

  /// Market Spot Price (can be part of some contract details)
  final MarketSpotPrice? marketSpotPrice;

  /// Additional fields not explicitly typed
  final Map<String, dynamic> additionalFields;

  const ContractDetails({
    this.instrumentId,
    this.instrumentName,
    this.profitLoss,
    this.referenceId,
    this.contractStartTime,
    this.entryTickTime,
    this.entrySpot,
    this.exitSpot,
    this.exitTickTime,
    this.variant,
    this.multiplier,
    this.commission,
    this.stake,
    this.bidPrice,
    this.bidPriceCurrency,
    this.isExpired,
    this.isValidToSell,
    this.isSold,
    this.potentialPayout,
    this.cancellation,
    this.limitOrder,
    this.status,
    this.tickStream,
    this.validationParams,
    this.marketSpotPrice,
    this.additionalFields = const {},
  });

  factory ContractDetails.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> remainingFields = Map.from(json);

    T? extract<T>(String key) {
      final value = remainingFields.remove(key);
      // Allow type casting for basic types, handle nulls
      if (value == null) return null;
      if (T == String) return value.toString() as T?;
      if (T == int && value is num) return value.toInt() as T?;
      if (T == double && value is num) return value.toDouble() as T?;
      if (T == bool) return value as T?;
      return value as T?;
    }

    List<TickInStream>? parseTickStream(dynamic data) {
      if (data is List) {
        return data
            .map((item) => TickInStream.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return null;
    }

    return ContractDetails(
      instrumentId: extract<String>('instrument_id'),
      instrumentName: extract<String>('instrument_name'),
      profitLoss: extract<String>('profit_loss'),
      referenceId: extract<String>('reference_id'),
      contractStartTime: extract<int>('contract_start_time'),
      entryTickTime: extract<int>('entry_tick_time'),
      entrySpot: extract<String>('entry_spot'),
      exitSpot: extract<String>('exit_spot'),
      exitTickTime: extract<int>('exit_tick_time'),
      variant: extract<String>('variant'),
      multiplier: extract<int>('multiplier'),
      commission: extract<String>('commission'),
      stake: extract<String>('stake'),
      bidPrice: extract<String>('bid_price'),
      bidPriceCurrency: extract<String>('bid_price_currency'),
      isExpired: extract<bool>('is_expired'),
      isValidToSell: extract<bool>('is_valid_to_sell'),
      isSold: extract<bool>('is_sold'),
      potentialPayout: extract<String>('potential_payout'),
      cancellation: remainingFields.containsKey('cancellation')
          ? CancellationDetails.fromJson(
              remainingFields.remove('cancellation') as Map<String, dynamic>)
          : null,
      limitOrder: remainingFields.containsKey('limit_order')
          ? LimitOrderDetails.fromJson(
              remainingFields.remove('limit_order') as Map<String, dynamic>)
          : null,
      status: extract<String>('status'),
      tickStream: parseTickStream(remainingFields.remove('tick_stream')),
      validationParams:
          remainingFields.remove('validation_params') as Map<String, dynamic>?,
      marketSpotPrice: remainingFields.containsKey('market_spot_price')
          ? MarketSpotPrice.fromJson(remainingFields.remove('market_spot_price')
              as Map<String, dynamic>)
          : null,
      additionalFields: remainingFields,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {...additionalFields};
    if (instrumentId != null) {
      json['instrument_id'] = instrumentId;
    }
    if (instrumentName != null) {
      json['instrument_name'] = instrumentName;
    }
    if (profitLoss != null) {
      json['profit_loss'] = profitLoss;
    }
    if (referenceId != null) {
      json['reference_id'] = referenceId;
    }
    if (contractStartTime != null) {
      json['contract_start_time'] = contractStartTime;
    }
    if (entryTickTime != null) {
      json['entry_tick_time'] = entryTickTime;
    }
    if (entrySpot != null) {
      json['entry_spot'] = entrySpot;
    }
    if (exitSpot != null) {
      json['exit_spot'] = exitSpot;
    }
    if (exitTickTime != null) {
      json['exit_tick_time'] = exitTickTime;
    }
    if (variant != null) {
      json['variant'] = variant;
    }
    if (multiplier != null) {
      json['multiplier'] = multiplier;
    }
    if (commission != null) {
      json['commission'] = commission;
    }
    if (stake != null) {
      json['stake'] = stake;
    }
    if (bidPrice != null) {
      json['bid_price'] = bidPrice;
    }
    if (bidPriceCurrency != null) {
      json['bid_price_currency'] = bidPriceCurrency;
    }
    if (isExpired != null) {
      json['is_expired'] = isExpired;
    }
    if (isValidToSell != null) {
      json['is_valid_to_sell'] = isValidToSell;
    }
    if (isSold != null) {
      json['is_sold'] = isSold;
    }
    if (potentialPayout != null) {
      json['potential_payout'] = potentialPayout;
    }
    if (cancellation != null) {
      json['cancellation'] = cancellation?.toJson();
    }
    if (limitOrder != null) {
      json['limit_order'] = limitOrder?.toJson();
    }
    if (status != null) {
      json['status'] = status;
    }
    if (tickStream != null) {
      json['tick_stream'] = tickStream?.map((e) => e.toJson()).toList();
    }
    if (validationParams != null) {
      json['validation_params'] = validationParams;
    }
    if (marketSpotPrice != null) {
      json['market_spot_price'] = marketSpotPrice?.toJson();
    }
    return json;
  }
}

/// Cancellation information for contracts
class CancellationDetails {
  final String? askPrice;
  final int? expiry;

  const CancellationDetails({this.askPrice, this.expiry});

  factory CancellationDetails.fromJson(Map<String, dynamic> json) {
    return CancellationDetails(
      askPrice: json['ask_price'] as String?,
      expiry: json['expiry'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (askPrice != null) {
      data['ask_price'] = askPrice;
    }
    if (expiry != null) {
      data['expiry'] = expiry;
    }
    return data;
  }
}

/// Limit order information for contracts
class LimitOrderDetails {
  final OrderDetails? takeProfit;
  final OrderDetails? stopLoss;
  final OrderDetails? stopOut; // Specific to some products like Multipliers

  const LimitOrderDetails({this.takeProfit, this.stopLoss, this.stopOut});

  factory LimitOrderDetails.fromJson(Map<String, dynamic> json) {
    return LimitOrderDetails(
      takeProfit: json['take_profit'] != null
          ? OrderDetails.fromJson(json['take_profit'] as Map<String, dynamic>)
          : null,
      stopLoss: json['stop_loss'] != null
          ? OrderDetails.fromJson(json['stop_loss'] as Map<String, dynamic>)
          : null,
      stopOut: json['stop_out'] != null
          ? OrderDetails.fromJson(json['stop_out'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (takeProfit != null) {
      data['take_profit'] = takeProfit?.toJson();
    }
    if (stopLoss != null) {
      data['stop_loss'] = stopLoss?.toJson();
    }
    if (stopOut != null) {
      data['stop_out'] = stopOut?.toJson();
    }
    return data;
  }
}

/// Details for a specific order type (take_profit, stop_loss, stop_out)
class OrderDetails {
  final String? displayName;
  final String? displayOrderAmount;
  final num? orderAmount; // API can send string or number, num is safer
  final int? orderDate;

  const OrderDetails({
    this.displayName,
    this.displayOrderAmount,
    this.orderAmount,
    this.orderDate,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      displayName: json['display_name'] as String?,
      displayOrderAmount: json['display_order_amount'] as String?,
      orderAmount: json['order_amount'] as num?,
      orderDate: json['order_date'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (displayName != null) {
      data['display_name'] = displayName;
    }
    if (displayOrderAmount != null) {
      data['display_order_amount'] = displayOrderAmount;
    }
    if (orderAmount != null) {
      data['order_amount'] = orderAmount;
    }
    if (orderDate != null) {
      data['order_date'] = orderDate;
    }
    return data;
  }
}

/// Market spot price (can be nested in contract details)
class MarketSpotPrice {
  final int epoch;
  final String price; // API shows string

  const MarketSpotPrice({required this.epoch, required this.price});

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

/// Tick data within a contract's tick stream
class TickInStream {
  final int epoch;
  final String tick; // Tick value, API shows number but often safer as string
  final String? tickDisplayValue;

  const TickInStream({
    required this.epoch,
    required this.tick,
    this.tickDisplayValue,
  });

  factory TickInStream.fromJson(Map<String, dynamic> json) {
    return TickInStream(
      // Ensure 'tick' is parsed robustly, defaulting to '0' if not convertible.
      tick: (json['tick'] ?? 0).toString(),
      epoch: json['epoch'] as int,
      tickDisplayValue: json['tick_display_value'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'epoch': epoch,
      'tick': tick,
      if (tickDisplayValue != null) 'tick_display_value': tickDisplayValue,
    };
  }
}
