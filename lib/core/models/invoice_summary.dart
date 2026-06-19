class InvoiceSummary {
  final double cashlessWithVat;
  final double invoicesTotal;
  final double balance;

  InvoiceSummary({
    required this.cashlessWithVat,
    required this.invoicesTotal,
    required this.balance,
  });

  factory InvoiceSummary.fromJson(Map<String, dynamic> json) {
    return InvoiceSummary(
      cashlessWithVat: (json['cashlessWithVat'] as num).toDouble(),
      invoicesTotal: (json['invoicesTotal'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
    );
  }
}