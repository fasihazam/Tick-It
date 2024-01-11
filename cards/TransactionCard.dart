import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/TransactionModel.dart';

class TransactionCard extends StatefulWidget {
  const TransactionCard({super.key, required this.transactionData});
  final Transaction transactionData;
  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          visualDensity: VisualDensity(vertical: -3),
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.transactionData.status == 1
                    ? Colors.green
                    : widget.transactionData.status == 2
                        ? Colors.amber
                        : Colors.orange),
            child: widget.transactionData.status == 1
                ? Icon(
                    Icons.done,
                    color: Colors.white,
                  )
                : widget.transactionData.status == 2
                    ? Icon(
                        Icons.undo,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
            alignment: Alignment.center,
          ),
          title: Text(
                  "Rs." + widget.transactionData.amount.toStringAsFixed(2),
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
          subtitle: Text(
            DateFormat('dd-MM-yyyy')
                .format(DateTime.parse(widget.transactionData.date)),
            style: TextStyle(fontSize: 18),
          ),
          trailing: widget.transactionData.type == 0
              ? Text('Deposit', style: TextStyle(fontSize: 17))
              : widget.transactionData.type == 1
                  ? Text('Withdrawal', style: TextStyle(fontSize: 17))
                  : widget.transactionData.type == 2
                      ? Text('Event Sponsored', style: TextStyle(fontSize: 17))
                      : widget.transactionData.type == 3
                          ? Text('Refunded', style: TextStyle(fontSize: 17))
                          : widget.transactionData.type == 4
                              ? Text('Ticket Purchased',
                                  style: TextStyle(fontSize: 17))
                              : widget.transactionData.type == 5
                                  ? Text('Ticket Sold',
                                      style: TextStyle(fontSize: 17))
                                  : null,
        ),
        Divider(
          thickness: 1,
        ),
      ],
    );
  }
}
