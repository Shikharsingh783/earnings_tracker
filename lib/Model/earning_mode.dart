class EarningsData {
  final String pricedate;
  final String ticker;
  final double actualEps;
  final double estimatedEps;
  final double actualRevenue;
  final double estimatedRevenue;

  EarningsData({
    required this.pricedate,
    required this.ticker,
    required this.actualEps,
    required this.estimatedEps,
    required this.actualRevenue,
    required this.estimatedRevenue,
  });

  factory EarningsData.fromJson(Map<String, dynamic> json) {
    return EarningsData(
      pricedate: json['pricedate'],
      ticker: json['ticker'],
      actualEps: json['actual_eps'].toDouble(),
      estimatedEps: json['estimated_eps'].toDouble(),
      actualRevenue: json['actual_revenue'].toDouble(),
      estimatedRevenue: json['estimated_revenue'].toDouble(),
    );
  }
}
