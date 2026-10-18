import 'package:flutter/material.dart';
import '../../core/api.dart';

class RewardsProvider extends ChangeNotifier {
  int pointsBalance = 0;
  int ecoScore = 0;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadRewards(String token, String customerId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final json = await Api.getRewards(token, customerId);
      pointsBalance = json['points_balance'] as int? ?? 0;
      ecoScore = json['eco_score'] as int? ?? 0;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> redeemPoints(
      String token, String customerId, int points) async {
    // CLIENT-SIDE GUARD
    if (points > pointsBalance) {
      errorMessage = 'Insufficient Eco Points';
      notifyListeners();
      return false;
    }

    try {
      await Api.redeemPoints(token, customerId, points);
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
