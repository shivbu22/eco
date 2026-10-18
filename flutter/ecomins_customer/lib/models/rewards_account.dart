class RewardsAccount {
  final int pointsBalance;
  final int ecoScore;

  const RewardsAccount({required this.pointsBalance, required this.ecoScore});

  factory RewardsAccount.fromJson(Map<String, dynamic> json) {
    return RewardsAccount(
      pointsBalance: json['points_balance'] as int? ?? 0,
      ecoScore: json['eco_score'] as int? ?? 0,
    );
  }
}
