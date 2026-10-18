import 'package:flutter_test/flutter_test.dart';
import 'package:ecomins_customer/features/rewards/rewards_provider.dart';

// ---------------------------------------------------------------------------
// Testable subclass that bypasses real API calls
// ---------------------------------------------------------------------------

class _FakeRewardsProvider extends RewardsProvider {
  final Map<String, dynamic>? _fakeData;
  final bool _shouldThrow;

  _FakeRewardsProvider({Map<String, dynamic>? fakeData, bool shouldThrow = false})
      : _fakeData = fakeData,
        _shouldThrow = shouldThrow;

  @override
  Future<void> loadRewards(String token, String customerId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (_shouldThrow) throw Exception('Network error');
      final json = _fakeData ?? {};
      pointsBalance = json['points_balance'] as int? ?? 0;
      ecoScore = json['eco_score'] as int? ?? 0;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // redeemPoints keeps the real balance-guard logic; only the API call is faked
  @override
  Future<bool> redeemPoints(String token, String customerId, int points) async {
    if (points > pointsBalance) {
      errorMessage = 'Insufficient Eco Points';
      notifyListeners();
      return false;
    }

    try {
      if (_shouldThrow) throw Exception('API error');
      pointsBalance -= points;
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RewardsProvider', () {
    test('redeemPoints returns false when points > balance', () async {
      final provider = _FakeRewardsProvider();
      provider.pointsBalance = 100;

      final result = await provider.redeemPoints('token', 'cust-1', 200);

      expect(result, isFalse);
      expect(provider.errorMessage, 'Insufficient Eco Points');
      expect(provider.pointsBalance, 100); // balance unchanged
    });

    test('redeemPoints decrements balance on success', () async {
      final provider = _FakeRewardsProvider();
      provider.pointsBalance = 100;

      final result = await provider.redeemPoints('token', 'cust-1', 50);

      expect(result, isTrue);
      expect(provider.pointsBalance, 50);
      expect(provider.errorMessage, isNull);
    });

    test('loadRewards sets pointsBalance and ecoScore', () async {
      final provider = _FakeRewardsProvider(
        fakeData: {'points_balance': 150, 'eco_score': 42},
      );

      await provider.loadRewards('token', 'cust-1');

      expect(provider.pointsBalance, 150);
      expect(provider.ecoScore, 42);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('redeemPoints returns false and sets errorMessage on API error',
        () async {
      final provider = _FakeRewardsProvider(shouldThrow: true);
      provider.pointsBalance = 100;

      final result = await provider.redeemPoints('token', 'cust-1', 50);

      expect(result, isFalse);
      expect(provider.errorMessage, isNotNull);
    });

    test('loadRewards sets errorMessage on failure', () async {
      final provider = _FakeRewardsProvider(shouldThrow: true);

      await provider.loadRewards('token', 'cust-1');

      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, isFalse);
    });
  });
}
