/// Price tick data
class Tick {
  /// Ask price
  final String? ask;

  /// Bid price
  final String? bid;

  /// Current price
  final String price;

  /// Timestamp in milliseconds since epoch
  final int epochMs;

  /// Display value for tick (used in some contexts)
  final String? tickDisplayValue;

  const Tick({
    this.ask,
    this.bid,
    required this.price,
    required this.epochMs,
    this.tickDisplayValue,
  });

  factory Tick.fromJson(Map<String, dynamic> json) {
    return Tick(
      ask: json['ask'] as String?,
      bid: json['bid'] as String?,
      price: json['price'] as String? ?? json['tick'] as String,
      epochMs: json['epoch_ms'] as int? ?? json['epoch'] as int,
      tickDisplayValue: json['tick_display_value'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ask != null) 'ask': ask,
      if (bid != null) 'bid': bid,
      'price': price,
      'epoch_ms': epochMs,
      if (tickDisplayValue != null) 'tick_display_value': tickDisplayValue,
    };
  }

  @override
  String toString() {
    return 'Tick(price: $price, epochMs: $epochMs, ask: $ask, bid: $bid)';
  }
}

/// Tick history request parameters
class TickHistoryRequest {
  /// Instrument identifier
  final String instrumentId;

  /// Start time in milliseconds since epoch
  final int fromEpochMs;

  /// End time in milliseconds since epoch
  final int toEpochMs;

  /// Maximum number of ticks to return
  final int count;

  const TickHistoryRequest({
    required this.instrumentId,
    required this.fromEpochMs,
    required this.toEpochMs,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'instrument_id': instrumentId,
      'from_epoch_ms': fromEpochMs,
      'to_epoch_ms': toEpochMs,
      'count': count,
    };
  }
}

/// Tick history response
class TickHistory {
  /// List of price ticks
  final List<Tick> ticks;

  const TickHistory({
    required this.ticks,
  });

  factory TickHistory.fromJson(Map<String, dynamic> json) {
    return TickHistory(
      ticks: (json['ticks'] as List<dynamic>)
          .map((e) => Tick.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticks': ticks.map((e) => e.toJson()).toList(),
    };
  }
}
