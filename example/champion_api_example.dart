import 'package:champion_api/champion_api.dart';

void main() async {
  // Initialize the API client
  final api = ChampionApi(baseUrl: 'http://localhost:3000/v1');

  try {
    print('Champion API Example\n');

    // 1. Get account balance
    print('1. Getting account balance...');
    final balance = await api.accounting.getBalance();
    print('   Current balance: ${balance.balance} ${balance.currency}\n');

    // 2. List available instruments
    print('2. Listing available instruments...');
    final instruments = await api.market.getInstruments();
    print('   Found ${instruments.instruments.length} instruments');
    if (instruments.instruments.isNotEmpty) {
      final firstInstrument = instruments.instruments.first;
      print(
          '   First instrument: ${firstInstrument.displayName} (${firstInstrument.id})');
      print('   Market open: ${firstInstrument.isMarketOpen}\n');
    }

    // 3. Get trading products
    print('3. Getting trading products...');
    final products = await api.market.getProducts();
    print(
        '   Available products: ${products.products.map((p) => p.id).join(', ')}\n');

    // 4. Get a multiplier proposal
    if (instruments.instruments.isNotEmpty) {
      print('4. Getting multiplier proposal...');
      final instrumentId = instruments.instruments.first.id;
      try {
        final proposal = await api.trading.getMultiplierProposal(
          instrumentId: instrumentId,
          amount: 10.0,
          multiplier: 100,
          stopLoss: 5.0,
          takeProfit: 20.0,
        );
        final proposalVariant = proposal.variants?.firstWhere(
            (v) => v.variant == 'MULTUP' || v.variant == 'MULTDOWN',
            orElse: () => throw StateError('No suitable variant found'));
        if (proposalVariant == null) {
          print('   Could not find a suitable proposal variant.');
        } else {
          print(
              '   Proposal bid price: ${proposalVariant.contractDetails.bidPrice}');
          print(
              '   Potential payout: ${proposalVariant.contractDetails.potentialPayout}');
        }
        print('');
      } catch (e) {
        print('   Error getting proposal: $e\n');
      }
    }

    // 5. Get historical tick data
    if (instruments.instruments.isNotEmpty) {
      print('5. Getting historical tick data...');
      final instrumentId = instruments.instruments.first.id;
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));

      try {
        final tickHistory = await api.market.getTickHistory(
          TickHistoryRequest(
            instrumentId: instrumentId,
            fromEpochMs: oneHourAgo.millisecondsSinceEpoch,
            toEpochMs: now.millisecondsSinceEpoch,
            count: 10,
          ),
        );
        print('   Retrieved ${tickHistory.ticks.length} ticks');
        if (tickHistory.ticks.isNotEmpty) {
          final latestTick = tickHistory.ticks.last;
          print(
              '   Latest tick: ${latestTick.price} at ${DateTime.fromMillisecondsSinceEpoch(latestTick.epochMs)}');
        }
        print('');
      } catch (e) {
        print('   Error getting tick history: $e\n');
      }
    }

    // 6. Stream balance updates (for a few seconds)
    print('6. Streaming balance updates for 5 seconds...');
    try {
      await for (final balanceUpdate
          in api.accounting.streamBalance().take(3)) {
        print(
            '   Balance update: ${balanceUpdate.balance} ${balanceUpdate.currency}');
        if (balanceUpdate.change != null) {
          print('   Change: ${balanceUpdate.change}');
        }
      }
    } catch (e) {
      print('   Error streaming balance: $e');
    }

    print('\nExample completed successfully!');
  } on ChampionApiException catch (e) {
    print('API Error: ${e.message} (${e.code})');
    print('Status Code: ${e.statusCode}');
    if (e.endpoint != null) {
      print('Endpoint: ${e.endpoint}');
    }
  } catch (e) {
    print('Unexpected error: $e');
  } finally {
    // Clean up
    api.dispose();
  }
}
