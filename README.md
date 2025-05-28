<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# Champion API

A Dart library for mocking Deriv trading API responses, designed for testing and development purposes.

## Overview

Champion API provides a complete mock implementation of the Deriv trading API, allowing developers to:
- Test trading applications without connecting to live services
- Develop and prototype trading features
- Generate realistic mock data for various trading scenarios
- Practice with different trading products (Multipliers, Accumulators, Rise/Fall)

## Features

### 🏦 Account Management
- Balance tracking and updates
- Real-time balance streaming
- Balance reset functionality

### 📈 Market Data
- Instrument listings with metadata
- Historical OHLC candle data
- Real-time price tick streaming
- Product configurations

### 💼 Trading Operations
- Contract buying and selling
- Position management
- Proposal generation (specific to product types)
- Real-time contract streaming

### 🔧 Admin Features
- Complete state reset
- Mock data generation
- Configurable responses

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  champion_api: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:champion_api/champion_api.dart';

void main() async {
  // Initialize the API client
  final api = ChampionApi(baseUrl: 'http://localhost:3000/v1');
  
  // Get account balance
  final balance = await api.accounting.getBalance();
  print('Current balance: ${balance.balance} ${balance.currency}');
  
  // List available instruments
  final instruments = await api.market.getInstruments();
  print('Available instruments: ${instruments.instruments.length}');
  
  // Get a trading proposal for Multipliers
  try {
    final proposal = await api.trading.getMultiplierProposal(
      instrumentId: instruments.instruments.first.id, // Use a valid instrument ID
      amount: 10.0,
      multiplier: 100,
      // stopLoss and takeProfit are optional
    );
    // The proposal object structure depends on the product.
    // For Multipliers, it usually contains variants.
    if (proposal.variants != null && proposal.variants!.isNotEmpty) {
       final firstVariant = proposal.variants!.first.contractDetails;
      print('Multiplier Proposal: Spot ${firstVariant.marketSpotPrice.price}, Stake ${firstVariant.stake}');
    } else {
      print('Received a proposal structure not primarily based on variants (e.g. Rise/Fall direct details).');
    }
  } on ChampionApiException catch (e) {
    print('Error getting proposal: ${e.message}');
  } finally {
    api.dispose();
  }
}
```

## API Endpoints

### Accounting
- `GET /v1/accounting/balance` - Get current balance
- `GET /v1/accounting/balance/stream` - Stream balance updates
- `POST /v1/accounting/balance/reset` - Reset balance

### Market Data
- `GET /v1/market/instruments` - List instruments
- `POST /v1/market/instruments/candles/history` - Historical OHLC data
- `GET /v1/market/instruments/candles/stream` - Stream OHLC data
- `POST /v1/market/instruments/ticks/history` - Historical tick data
- `GET /v1/market/instruments/ticks/stream` - Stream tick data
- `GET /v1/market/products` - List products
- `GET /v1/market/products/config` - Product configuration

### Trading
- `GET /v1/trading/contracts/open` - Get open contracts
- `GET /v1/trading/contracts/close` - Get closed contracts
- `POST /v1/trading/contracts/buy` - Buy a contract (uses product-specific helper methods)
- `POST /v1/trading/contracts/sell` - Sell a contract
- `POST /v1/trading/contracts/cancel` - Cancel a contract (Note: API might not support this for all products)
- `POST /v1/trading/proposal` - Get trading proposal (uses product-specific helper methods)
- `GET /v1/trading/proposal/stream` - Stream proposals

### Admin
- `POST /v1/admin/reset` - Reset mock state

## Trading Products

### Multipliers
Leveraged trading with configurable multipliers and optional stop loss/take profit.

```dart
// Get a proposal
final proposal = await api.trading.getMultiplierProposal(
  instrumentId: 'frxUSDJPY', // Example instrument ID
  amount: 10.0,
  multiplier: 100,
  stopLoss: 5.0,
  takeProfit: 20.0,
  cancellation: 5, // Optional: 5 minutes cancellation window
);

// Buy a contract based on the proposal (simplified - actual buy needs idempotency etc)
if (proposal.variants != null && proposal.variants!.isNotEmpty) {
  // Assuming user chooses the first variant
  // In a real app, you'd use details from the chosen variant for the buy request.
  final buyDetails = proposal.variants!.first;
  
  final contract = await api.trading.buyMultiplierContract(
    instrumentId: 'frxUSDJPY',
    amount: double.tryParse(buyDetails.contractDetails.stake) ?? 10.0,
    multiplier: buyDetails.contractDetails.multiplier ?? 100,
    tradeType: buyDetails.variant == 'MULTUP' ? 'up' : 'down',
    stopLoss: 5.0, // These might come from user input or defaults
    takeProfit: 20.0,
    cancellation: 5,
  );
  print('Bought Multiplier Contract ID: ${contract.contractId}');
}
```

### Accumulators
Accumulation-based products with barrier levels.

```dart
// Get a proposal
final proposal = await api.trading.getAccumulatorProposal(
  instrumentId: 'R_50', // Example instrument ID
  amount: 1.0,
  growthRate: 0.01,
  takeProfit: 100.0, // Optional take profit for accumulator proposal
);

// Buy a contract (simplified)
if (proposal.variants != null && proposal.variants!.isNotEmpty) {
  final buyDetails = proposal.variants!.first.contractDetails;
  final contract = await api.trading.buyAccumulatorContract(
    instrumentId: 'R_50',
    amount: double.tryParse(buyDetails.stake) ?? 1.0,
    growthRate: buyDetails.growthRate ?? 0.01,
    takeProfit: 100.0, // From user input or defaults
  );
  print('Bought Accumulator Contract ID: ${contract.contractId}');
}
```

### Rise/Fall
Binary options for directional trading.

```dart
// Get a proposal
// Note: Rise/Fall proposal structure is different, might not have variants.
final proposal = await api.trading.getRiseFallProposal(
  instrumentId: 'frxEURUSD', // Example instrument ID
  amount: 5.0,
  duration: 60, // seconds
  tradeType: 'rise',
);

// Buy a contract (simplified)
// The proposal.contractDetails for Rise/Fall contains the main fields directly
if (proposal.contractDetails != null) {
  // For Rise/Fall, the parameters for buying are often simpler or might use
  // a proposal ID from the `proposal.contractDetails['id']` if the API supports it.
  // The current buyRiseFallContract helper constructs the body.
  final contract = await api.trading.buyRiseFallContract(
    instrumentId: 'frxEURUSD',
    amount: 5.0, // From user input
    duration: 60,
    tradeType: 'rise', // 'rise' or 'fall'
  );
  print('Bought Rise/Fall Contract ID: ${contract.contractId}');
}

```

## Streaming

The library supports Server-Sent Events (SSE) for real-time data:

```dart
// Stream balance updates
api.accounting.streamBalance().listen((balance) {
  print('Balance updated: ${balance.balance}');
});

// Stream price ticks
// Note: streamTicks and streamOHLC now require startEpochMs and granularity
final now = DateTime.now().millisecondsSinceEpoch;
api.market.streamTicks(
  instrumentId: 'frxUSDJPY',
  startEpochMs: now,
  granularity: 60, // Or appropriate value for ticks
).listen((tick) {
  print('New tick: ${tick.price} at ${DateTime.fromMillisecondsSinceEpoch(tick.epochMs)}');
});

// Stream open contracts
api.trading.streamOpenContracts().listen((contracts) {
  print('Open contracts updated: ${contracts.length}');
});
```

## Error Handling

The library provides structured error handling:

```dart
try {
  final balance = await api.accounting.getBalance();
  print('Balance: ${balance.balance}');
} on ChampionApiException catch (e) {
  print('API Error: ${e.message} (${e.code}) Status: ${e.statusCode}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Development

To run the example:

```bash
cd champion_api
dart run example/champion_api_example.dart
```

To run tests:

```bash
dart test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run `dart analyze` and `dart test`
6. Submit a pull request

## License

MIT License - see LICENSE file for details.
