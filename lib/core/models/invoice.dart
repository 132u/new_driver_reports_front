class Invoice {
  final String id;
  final double amount;
  final DateTime invoiceDate;
  final String? comment;

  Invoice({
    required this.id,
    required this.amount,
    required this.invoiceDate,
    this.comment,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      invoiceDate: DateTime.parse(json['invoiceDate']),
      comment: json['comment'],
    );
  }
}