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
- Proposal generation
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
  print('Available instruments: ${instruments.length}');
  
  // Get a trading proposal
  final proposal = await api.trading.getProposal(
    productId: 'multipliers',
    instrumentId: 'frxUSDJPY',
    amount: 10.0,
    multiplier: 100,
    tradeType: 'up',
  );
  print('Proposal price: ${proposal.askPrice}');
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
- `POST /v1/trading/contracts/buy` - Buy a contract
- `POST /v1/trading/contracts/sell` - Sell a contract
- `POST /v1/trading/contracts/cancel` - Cancel a contract
- `POST /v1/trading/proposal` - Get trading proposal
- `GET /v1/trading/proposal/stream` - Stream proposals

### Admin
- `POST /v1/admin/reset` - Reset mock state

## Trading Products

### Multipliers
Leveraged trading with configurable multipliers and optional stop loss/take profit.

```dart
final proposal = await api.trading.getProposal(
  productId: 'multipliers',
  instrumentId: 'frxUSDJPY',
  amount: 10.0,
  multiplier: 100,
  tradeType: 'up',
  stopLoss: 5.0,
  takeProfit: 20.0,
);
```

### Accumulators
Accumulation-based products with barrier levels.

```dart
final proposal = await api.trading.getProposal(
  productId: 'accumulators',
  instrumentId: 'R_50',
  amount: 1.0,
  growthRate: 0.01,
);
```

### Rise/Fall
Binary options for directional trading.

```dart
final proposal = await api.trading.getProposal(
  productId: 'rise_fall',
  instrumentId: 'frxEURUSD',
  amount: 5.0,
  duration: 60,
  tradeType: 'rise',
);
```

## Streaming

The library supports Server-Sent Events (SSE) for real-time data:

```dart
// Stream balance updates
api.accounting.streamBalance().listen((balance) {
  print('Balance updated: ${balance.balance}');
});

// Stream price ticks
api.market.streamTicks('frxUSDJPY').listen((tick) {
  print('New tick: ${tick.price} at ${tick.epochMs}');
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
  print('API Error: ${e.message} (${e.code})');
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
