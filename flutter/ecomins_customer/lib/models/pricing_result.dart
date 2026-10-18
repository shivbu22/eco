class PricingResult {
  final double base;
  final double tax;
  final double surcharge;
  final double total;

  const PricingResult({
    required this.base,
    required this.tax,
    required this.surcharge,
    required this.total,
  });

  factory PricingResult.fromJson(Map<String, dynamic> json) {
    return PricingResult(
      base: (json['base'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      surcharge: (json['surcharge'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 500,
    );
  }
}
