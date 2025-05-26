/// Integration test for Champion API
///
/// This test requires the Go mock server to be running on localhost:3000
/// Run: dart test test/integration_test.dart
///
/// To start the Go mock server:
/// cd your-mock-server-directory
/// go run cmd/service/main.go --debug

import 'package:test/test.dart';
import 'package:champion_api/champion_api.dart';

void main() {
  group('Champion API Integration Tests', () {
    late ChampionApi api;

    setUpAll(() {
      api = ChampionApi(baseUrl: 'http://localhost:3000/v1');
    });

    tearDownAll(() {
      api.dispose();
    });

    group('Accounting Service', () {
      test('should get account balance', () async {
        final balance = await api.accounting.getBalance();
        expect(balance.balance, isNotNull);
        expect(balance.currency, isNotNull);
        print('Balance: ${balance.balance} ${balance.currency}');
      }, skip: 'Requires mock server');

      test('should reset account balance', () async {
        final balance = await api.accounting.resetBalance();
        expect(balance.balance, isNotNull);
        expect(balance.currency, isNotNull);
        print('Reset balance: ${balance.balance} ${balance.currency}');
      }, skip: 'Requires mock server');
    });

    group('Market Service', () {
      test('should list instruments', () async {
        final instruments = await api.market.getInstruments();
        expect(instruments.instruments, isNotEmpty);
        print('Found ${instruments.instruments.length} instruments');

        final firstInstrument = instruments.instruments.first;
        print(
            'First instrument: ${firstInstrument.displayName} (${firstInstrument.id})');
      }, skip: 'Requires mock server');

      test('should get products', () async {
        final products = await api.market.getProducts();
        expect(products.products, isNotEmpty);
        print(
            'Available products: ${products.products.map((p) => p.id).join(', ')}');
      }, skip: 'Requires mock server');

      test('should get tick history', () async {
        // First get instruments to use one for history
        final instruments = await api.market.getInstruments();
        expect(instruments.instruments, isNotEmpty);

        final instrumentId = instruments.instruments.first.id;
        final now = DateTime.now();
        final oneHourAgo = now.subtract(const Duration(hours: 1));

        final tickHistory = await api.market.getTickHistory(
          TickHistoryRequest(
            instrumentId: instrumentId,
            fromEpochMs: oneHourAgo.millisecondsSinceEpoch,
            toEpochMs: now.millisecondsSinceEpoch,
            count: 10,
          ),
        );

        expect(tickHistory.ticks, isNotNull);
        print('Retrieved ${tickHistory.ticks.length} ticks for $instrumentId');

        if (tickHistory.ticks.isNotEmpty) {
          final latestTick = tickHistory.ticks.last;
          print(
              'Latest tick: ${latestTick.price} at ${DateTime.fromMillisecondsSinceEpoch(latestTick.epochMs)}');
        }
      }, skip: 'Requires mock server');
    });

    group('Trading Service', () {
      test('should get multiplier proposal', () async {
        // First get instruments
        final instruments = await api.market.getInstruments();
        expect(instruments.instruments, isNotEmpty);

        final instrumentId = instruments.instruments.first.id;

        final proposal = await api.trading.getMultiplierProposal(
          instrumentId: instrumentId,
          amount: 10.0,
          multiplier: 100,
          tradeType: 'up',
          stopLoss: 5.0,
          takeProfit: 20.0,
        );

        expect(proposal.askPrice, isNotNull);
        print('Multiplier proposal for $instrumentId: ${proposal.askPrice}');
        if (proposal.payout != null) {
          print('Potential payout: ${proposal.payout}');
        }
      }, skip: 'Requires mock server');

      test('should get open contracts', () async {
        final contracts = await api.trading.getOpenContracts();
        expect(contracts, isNotNull);
        print('Open contracts: ${contracts.length}');

        for (final contract in contracts) {
          print('Contract ${contract.contractId}: ${contract.productId}');
        }
      }, skip: 'Requires mock server');

      test('should buy and sell multiplier contract', () async {
        // Get instruments first
        final instruments = await api.market.getInstruments();
        expect(instruments.instruments, isNotEmpty);

        final instrumentId = instruments.instruments.first.id;

        // Buy a contract
        final contract = await api.trading.buyMultiplierContract(
          instrumentId: instrumentId,
          amount: 10.0,
          multiplier: 100,
          tradeType: 'up',
        );

        expect(contract.contractId, isNotNull);
        print('Bought contract: ${contract.contractId}');

        // Wait a moment
        await Future.delayed(const Duration(seconds: 1));

        // Sell the contract
        final sellResult =
            await api.trading.sellContract(contractId: contract.contractId);
        expect(sellResult, isNotNull);
        print('Sold contract: $sellResult');
      }, skip: 'Requires mock server');
    });

    group('Admin Service', () {
      test('should reset state', () async {
        final result = await api.admin.resetState();
        expect(result, isNotNull);
        print('State reset result: $result');
      }, skip: 'Requires mock server');
    });

    group('Streaming Tests', () {
      test('should stream balance updates', () async {
        var updateCount = 0;
        const maxUpdates = 3;

        await for (final balance
            in api.accounting.streamBalance().take(maxUpdates)) {
          updateCount++;
          expect(balance.balance, isNotNull);
          print(
              'Balance update $updateCount: ${balance.balance} ${balance.currency}');

          if (balance.change != null) {
            print('  Change: ${balance.change}');
          }
        }

        expect(updateCount, maxUpdates);
      }, skip: 'Requires mock server');

      test('should stream tick data', () async {
        // Get an instrument first
        final instruments = await api.market.getInstruments();
        expect(instruments.instruments, isNotEmpty);

        final instrumentId = instruments.instruments.first.id;
        var tickCount = 0;
        const maxTicks = 3;

        await for (final tick in api.market
            .streamTicks(instrumentId: instrumentId)
            .take(maxTicks)) {
          tickCount++;
          expect(tick.price, isNotNull);
          print(
              'Tick $tickCount for $instrumentId: ${tick.price} at ${DateTime.fromMillisecondsSinceEpoch(tick.epochMs)}');
        }

        expect(tickCount, maxTicks);
      }, skip: 'Requires mock server');
    });
  });
}

/// Helper to run integration tests when server is available
void runIntegrationTests() {
  // Remove skip from tests above and run:
  // dart test test/integration_test.dart
}
