/// Trading instrument information
class Instrument {
  /// Unique instrument identifier
  final String id;

  /// Human-readable display name
  final String displayName;

  /// Categories this instrument belongs to
  final List<String> categories;

  /// Pip size for price precision
  final int pipSize;

  /// Whether the market is currently open
  final bool isMarketOpen;

  /// Market opening time in milliseconds since epoch
  final int opensAt;

  /// Market closing time in milliseconds since epoch
  final int closesAt;

  const Instrument({
    required this.id,
    required this.displayName,
    required this.categories,
    required this.pipSize,
    required this.isMarketOpen,
    required this.opensAt,
    required this.closesAt,
  });

  factory Instrument.fromJson(Map<String, dynamic> json) {
    return Instrument(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      categories: (json['categories'] as List<dynamic>).cast<String>(),
      pipSize: json['pip_size'] as int,
      isMarketOpen: json['is_market_open'] as bool,
      opensAt: json['opens_at'] as int,
      closesAt: json['closes_at'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'categories': categories,
      'pip_size': pipSize,
      'is_market_open': isMarketOpen,
      'opens_at': opensAt,
      'closes_at': closesAt,
    };
  }

  @override
  String toString() {
    return 'Instrument(id: $id, displayName: $displayName, isMarketOpen: $isMarketOpen)';
  }
}

/// List of instruments response
class InstrumentsList {
  /// List of instruments
  final List<Instrument> instruments;

  const InstrumentsList({
    required this.instruments,
  });

  factory InstrumentsList.fromJson(Map<String, dynamic> json) {
    return InstrumentsList(
      instruments: (json['instruments'] as List<dynamic>)
          .map((e) => Instrument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instruments': instruments.map((e) => e.toJson()).toList(),
    };
  }
}
