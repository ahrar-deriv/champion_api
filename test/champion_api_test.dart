import 'package:test/test.dart';
import 'package:champion_api/champion_api.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

// Generate mocks for testing
@GenerateMocks([http.Client])
import 'champion_api_test.mocks.dart';

void main() {
  group('Champion API', () {
    late ChampionApi api;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      api = ChampionApi(
        baseUrl: 'http://localhost:3000/v1',
        httpClient: mockClient,
      );
    });

    tearDown(() {
      api.dispose();
    });

    group('Models', () {
      test('Balance serialization', () {
        final json = {
          'balance': '1000.00',
          'currency': 'USD',
          'timestamp': '2024-01-01T00:00:00Z',
        };

        final balance = Balance.fromJson(json);
        expect(balance.balance, '1000.00');
        expect(balance.currency, 'USD');
        expect(balance.timestamp, '2024-01-01T00:00:00Z');

        final serialized = balance.toJson();
        expect(serialized['balance'], '1000.00');
        expect(serialized['currency'], 'USD');
        expect(serialized['timestamp'], '2024-01-01T00:00:00Z');
      });

      test('Instrument serialization', () {
        final json = {
          'id': 'frxUSDJPY',
          'display_name': 'USD/JPY',
          'categories': ['forex'],
          'pip_size': 3,
          'is_market_open': true,
          'opens_at': 1640995200000,
          'closes_at': 1641081600000,
        };

        final instrument = Instrument.fromJson(json);
        expect(instrument.id, 'frxUSDJPY');
        expect(instrument.displayName, 'USD/JPY');
        expect(instrument.categories, ['forex']);
        expect(instrument.pipSize, 3);
        expect(instrument.isMarketOpen, true);

        final serialized = instrument.toJson();
        expect(serialized['id'], 'frxUSDJPY');
        expect(serialized['display_name'], 'USD/JPY');
      });

      test('OHLC serialization', () {
        final json = {
          'open': '110.123',
          'high': '110.456',
          'low': '110.000',
          'close': '110.234',
          'epoch_ms': 1640995200000,
        };

        final ohlc = OHLC.fromJson(json);
        expect(ohlc.open, '110.123');
        expect(ohlc.high, '110.456');
        expect(ohlc.low, '110.000');
        expect(ohlc.close, '110.234');
        expect(ohlc.epochMs, 1640995200000);

        final serialized = ohlc.toJson();
        expect(serialized['open'], '110.123');
        expect(serialized['epoch_ms'], 1640995200000);
      });

      test('Tick serialization', () {
        final json = {
          'price': '110.123',
          'epoch_ms': 1640995200000,
          'ask': '110.125',
          'bid': '110.121',
        };

        final tick = Tick.fromJson(json);
        expect(tick.price, '110.123');
        expect(tick.epochMs, 1640995200000);
        expect(tick.ask, '110.125');
        expect(tick.bid, '110.121');

        final serialized = tick.toJson();
        expect(serialized['price'], '110.123');
        expect(serialized['epoch_ms'], 1640995200000);
      });

      test('Proposal serialization', () {
        final json = {
          'ask_price': '10.50',
          'id': 'proposal_123',
          'payout': '21.00',
          'spot': '110.123',
          'spot_time': 1640995200,
        };

        final proposal = Proposal.fromJson(json);
        expect(proposal.askPrice, '10.50');
        expect(proposal.id, 'proposal_123');
        expect(proposal.payout, '21.00');
        expect(proposal.spot, '110.123');
        expect(proposal.spotTime, 1640995200);

        final serialized = proposal.toJson();
        expect(serialized['ask_price'], '10.50');
        expect(serialized['id'], 'proposal_123');
      });

      test('Contract with multiplier details serialization', () {
        final json = {
          'contract_id': 'contract_123',
          'product_id': 'multipliers',
          'contract_details': {
            'multiplier': 100,
            'commission': '0.50',
            'variant': 'up',
            'stake': '10.00',
            'bid_price': '15.75',
            'is_expired': false,
            'is_valid_to_sell': true,
            'is_sold': false,
            'instrument_id': 'frxUSDJPY',
            'instrument_name': 'USD/JPY',
          },
        };

        final contract = Contract.fromJson(json);
        expect(contract.contractId, 'contract_123');
        expect(contract.productId, 'multipliers');
        expect(contract.contractDetails, isA<MultiplierContractDetails>());

        final details = contract.contractDetails as MultiplierContractDetails;
        expect(details.multiplier, 100);
        expect(details.commission, '0.50');
        expect(details.variant, 'up');
        expect(details.stake, '10.00');
        expect(details.bidPrice, '15.75');

        final serialized = contract.toJson();
        expect(serialized['contract_id'], 'contract_123');
        expect(serialized['product_id'], 'multipliers');
        expect(serialized['contract_details']['multiplier'], 100);
      });
    });

    group('Request Models', () {
      test('MultiplierProposalRequest', () {
        final request = MultiplierProposalRequest(
          productId: 'multipliers',
          instrumentId: 'frxUSDJPY',
          amount: 10.0,
          multiplier: 100,
          tradeType: 'up',
          stopLoss: 5.0,
          takeProfit: 20.0,
        );

        final json = request.toJson();
        expect(json['product_id'], 'multipliers');
        expect(json['instrument_id'], 'frxUSDJPY');
        expect(json['amount'], 10.0);
        expect(json['multiplier'], 100);
        expect(json['trade_type'], 'up');
        expect(json['stop_loss'], 5.0);
        expect(json['take_profit'], 20.0);
      });

      test('OHLCHistoryRequest', () {
        final request = OHLCHistoryRequest(
          instrumentId: 'frxUSDJPY',
          fromEpochMs: 1640995200000,
          toEpochMs: 1641081600000,
          granularity: 60,
          count: 100,
        );

        final json = request.toJson();
        expect(json['instrument_id'], 'frxUSDJPY');
        expect(json['from_epoch_ms'], 1640995200000);
        expect(json['to_epoch_ms'], 1641081600000);
        expect(json['granularity'], 60);
        expect(json['count'], 100);
      });
    });

    group('Exception Handling', () {
      test('ChampionApiException creation', () {
        final exception = ChampionApiException(
          code: 'test_error',
          message: 'Test error message',
          statusCode: 400,
          endpoint: '/test',
        );

        expect(exception.code, 'test_error');
        expect(exception.message, 'Test error message');
        expect(exception.statusCode, 400);
        expect(exception.endpoint, '/test');
        expect(exception.toString(), contains('test_error'));
      });

      test('ChampionApiException from response', () {
        final response = {
          'errors': [
            {
              'code': 'validation_error',
              'message': 'Invalid parameters',
            }
          ]
        };

        final exception = ChampionApiException.fromResponse(
          response: response,
          statusCode: 400,
          endpoint: '/test',
        );

        expect(exception.code, 'validation_error');
        expect(exception.message, 'Invalid parameters');
        expect(exception.statusCode, 400);
        expect(exception.endpoint, '/test');
      });
    });
  });
}
