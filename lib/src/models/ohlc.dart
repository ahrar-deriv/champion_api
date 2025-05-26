/// OHLC (Open, High, Low, Close) candlestick data
class OHLC {
  /// Opening price
  final String open;

  /// Highest price during the period
  final String high;

  /// Lowest price during the period
  final String low;

  /// Closing price
  final String close;

  /// Timestamp in milliseconds since epoch
  final int epochMs;

  const OHLC({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.epochMs,
  });

  factory OHLC.fromJson(Map<String, dynamic> json) {
    return OHLC(
      open: json['open'] as String,
      high: json['high'] as String,
      low: json['low'] as String,
      close: json['close'] as String,
      epochMs: json['epoch_ms'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'epoch_ms': epochMs,
    };
  }

  @override
  String toString() {
    return 'OHLC(open: $open, high: $high, low: $low, close: $close, epochMs: $epochMs)';
  }
}

/// OHLC history request parameters
class OHLCHistoryRequest {
  /// Instrument identifier
  final String instrumentId;

  /// Start time in milliseconds since epoch
  final int fromEpochMs;

  /// End time in milliseconds since epoch
  final int toEpochMs;

  /// Granularity in seconds (e.g., 60 for 1-minute candles)
  final int granularity;

  /// Maximum number of candles to return
  final int count;

  const OHLCHistoryRequest({
    required this.instrumentId,
    required this.fromEpochMs,
    required this.toEpochMs,
    required this.granularity,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'instrument_id': instrumentId,
      'from_epoch_ms': fromEpochMs,
      'to_epoch_ms': toEpochMs,
      'granularity': granularity,
      'count': count,
    };
  }
}

/// OHLC history response
class OHLCHistory {
  /// List of OHLC candles
  final List<OHLC> candles;

  const OHLCHistory({
    required this.candles,
  });

  factory OHLCHistory.fromJson(Map<String, dynamic> json) {
    return OHLCHistory(
      candles: (json['candles'] as List<dynamic>)
          .map((e) => OHLC.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'candles': candles.map((e) => e.toJson()).toList(),
    };
  }
}
