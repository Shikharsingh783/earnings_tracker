class EarningsData {
  final String pricedate;
  final String ticker;
  final double? actualEps;
  final double? estimatedEps;
  final double? actualRevenue;
  final double? estimatedRevenue;

  EarningsData({
    required this.pricedate,
    required this.ticker,
    this.actualEps,
    this.estimatedEps,
    this.actualRevenue,
    this.estimatedRevenue,
    required priceDate,
  });

  factory EarningsData.fromJson(Map<String, dynamic> json) {
    return EarningsData(
        pricedate: json['pricedate'],
        ticker: json['ticker'],
        actualEps: json['actual_eps'] != null
            ? (json['actual_eps'] as num).toDouble()
            : null,
        estimatedEps: (json['estimated_eps'] as num).toDouble(),
        actualRevenue: json['actual_revenue'] != null
            ? (json['actual_revenue'] as num).toDouble()
            : null,
        estimatedRevenue: (json['estimated_revenue'] as num).toDouble(),
        priceDate: json['pricedate']);
  }
}
