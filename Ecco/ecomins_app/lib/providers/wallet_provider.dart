import 'package:flutter/foundation.dart';

class WalletTransaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit;
  final DateTime date;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.date,
  });
}

class WalletProvider extends ChangeNotifier {
  double _balance = 2450.0;
  final List<WalletTransaction> _transactions = [
    WalletTransaction(
      id: 'tx_1',
      title: 'Plumbing Service',
      subtitle: 'Booking #84920',
      amount: 450.0,
      isCredit: false,
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    WalletTransaction(
      id: 'tx_2',
      title: 'Top Up',
      subtitle: 'Credit Card •••• 4242',
      amount: 1000.0,
      isCredit: true,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    WalletTransaction(
      id: 'tx_3',
      title: 'Eco Points Reward',
      subtitle: 'For using electric vehicle service',
      amount: 50.0,
      isCredit: true,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  double get balance => _balance;
  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);

  void addFunds(double amount, {String title = 'Top Up', String subtitle = 'Added via Payment'}) {
    _balance += amount;
    _transactions.insert(
      0,
      WalletTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subtitle: subtitle,
        amount: amount,
        isCredit: true,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  bool deductFunds(double amount, {required String title, required String subtitle}) {
    if (_balance >= amount) {
      _balance -= amount;
      _transactions.insert(
        0,
        WalletTransaction(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          subtitle: subtitle,
          amount: amount,
          isCredit: false,
          date: DateTime.now(),
        ),
      );
      notifyListeners();
      return true;
    }
    return false;
  }
}
