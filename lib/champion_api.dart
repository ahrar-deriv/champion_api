/// Champion API - A Dart library for mocking Deriv trading API responses
///
/// This library provides a complete mock implementation of the Deriv trading API,
/// designed for testing and development purposes.
library champion_api;

// Core API client
export 'src/champion_api_client.dart';

// Services
export 'src/services/accounting_service.dart';
export 'src/services/market_service.dart';
export 'src/services/trading_service.dart';
export 'src/services/admin_service.dart';

// Models
export 'src/models/balance.dart';
export 'src/models/instrument.dart';
export 'src/models/ohlc.dart';
export 'src/models/tick.dart';
export 'src/models/contract.dart';
export 'src/models/proposal.dart';
export 'src/models/product.dart';
export 'src/models/api_response.dart';

// Exceptions
export 'src/exceptions/champion_api_exception.dart';
