class Transaction {
  final int id;
  final int wallet_id;
  final double amount;
  final int type;
  final int status;
  final String date;

  const Transaction({
    required this.id,
    required this.wallet_id,
    required this.amount,
    required this.type,
    required this.status,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      wallet_id: json['wallet_id'],
      amount: double.parse(json['amount'].toString()),
      type: int.parse(json['type'].toString()),
      status: int.parse(json['status'].toString()),
      date: json['date'],
    );
  }

}