class DashboardStats {
  final int totalCustomers;
  final int totalProducts;
  final int totalInvoices;
  final int totalCharges;
  final int totalSubscriptions;
  
  // Métricas financeiras
  final double todayChargesValue;
  final int todayChargesCount;
  final double monthChargesValue;
  final int monthChargesCount;
  final double averageTicket;
  
  // Volume Total de Pagamento (TPV)
  final Map<String, double> tpvByDate;
  
  // Bandeiras de cartão
  final Map<String, int> cardBrands;
  
  // Formas de pagamento
  final Map<String, int> paymentMethods;

  DashboardStats({
    this.totalCustomers = 0,
    this.totalProducts = 0,
    this.totalInvoices = 0,
    this.totalCharges = 0,
    this.totalSubscriptions = 0,
    this.todayChargesValue = 0.0,
    this.todayChargesCount = 0,
    this.monthChargesValue = 0.0,
    this.monthChargesCount = 0,
    this.averageTicket = 0.0,
    this.tpvByDate = const {},
    this.cardBrands = const {},
    this.paymentMethods = const {},
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalCustomers: json['totalCustomers'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalInvoices: json['totalInvoices'] ?? 0,
      totalCharges: json['totalCharges'] ?? 0,
      totalSubscriptions: json['totalSubscriptions'] ?? 0,
      todayChargesValue: (json['todayChargesValue'] ?? 0).toDouble(),
      todayChargesCount: json['todayChargesCount'] ?? 0,
      monthChargesValue: (json['monthChargesValue'] ?? 0).toDouble(),
      monthChargesCount: json['monthChargesCount'] ?? 0,
      averageTicket: (json['averageTicket'] ?? 0).toDouble(),
      tpvByDate: Map<String, double>.from(json['tpvByDate'] ?? {}),
      cardBrands: Map<String, int>.from(json['cardBrands'] ?? {}),
      paymentMethods: Map<String, int>.from(json['paymentMethods'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCustomers': totalCustomers,
      'totalProducts': totalProducts,
      'totalInvoices': totalInvoices,
      'totalCharges': totalCharges,
      'totalSubscriptions': totalSubscriptions,
      'todayChargesValue': todayChargesValue,
      'todayChargesCount': todayChargesCount,
      'monthChargesValue': monthChargesValue,
      'monthChargesCount': monthChargesCount,
      'averageTicket': averageTicket,
      'tpvByDate': tpvByDate,
      'cardBrands': cardBrands,
      'paymentMethods': paymentMethods,
    };
  }
}
