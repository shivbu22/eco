class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool phoneVerified;
  final String? avatarUrl;
  final String tier;
  final double walletBalance;
  final int ecoPoints;
  final double totalCo2Saved;
  final int totalBookings;
  final int treesEquivalent;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    this.email = '',
    this.phone = '',
    this.phoneVerified = false,
    this.avatarUrl,
    this.tier = 'Eco Member',
    this.walletBalance = 0,
    this.ecoPoints = 0,
    this.totalCo2Saved = 0,
    this.totalBookings = 0,
    this.treesEquivalent = 0,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      tier: json['tier'] as String? ?? 'Eco Member',
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0,
      ecoPoints: json['ecoPoints'] as int? ?? 0,
      totalCo2Saved: (json['totalCo2Saved'] as num?)?.toDouble() ?? 0,
      totalBookings: json['totalBookings'] as int? ?? 0,
      treesEquivalent: json['treesEquivalent'] as int? ?? 0,
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    double? walletBalance,
    int? ecoPoints,
    double? totalCo2Saved,
    int? totalBookings,
    String? tier,
    int? treesEquivalent,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified,
      avatarUrl: avatarUrl,
      tier: tier ?? this.tier,
      walletBalance: walletBalance ?? this.walletBalance,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      totalCo2Saved: totalCo2Saved ?? this.totalCo2Saved,
      totalBookings: totalBookings ?? this.totalBookings,
      treesEquivalent: treesEquivalent ?? this.treesEquivalent,
      createdAt: createdAt,
    );
  }
}
