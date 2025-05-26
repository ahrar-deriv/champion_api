/// Account balance information
class Balance {
  /// Current balance amount
  final String balance;

  /// Currency code (e.g., USD, EUR)
  final String currency;

  /// Timestamp of the balance update (for streaming)
  final String? timestamp;

  /// Balance change amount (for streaming)
  final String? change;

  /// Associated contract ID (for streaming)
  final String? contractId;

  const Balance({
    required this.balance,
    required this.currency,
    this.timestamp,
    this.change,
    this.contractId,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      balance: json['balance'] as String,
      currency: json['currency'] as String,
      timestamp: json['timestamp'] as String?,
      change: json['change'] as String?,
      contractId: json['contract_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'currency': currency,
      if (timestamp != null) 'timestamp': timestamp,
      if (change != null) 'change': change,
      if (contractId != null) 'contract_id': contractId,
    };
  }

  @override
  String toString() {
    return 'Balance(balance: $balance, currency: $currency)';
  }
}
