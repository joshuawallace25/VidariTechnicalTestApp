/* import 'package:catapp/providers/auth_provider.dart';
import 'package:catapp/providers/transaction_provider.dart';
import 'package:catapp/views/transaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return FutureBuilder(
      future: transactionProvider.fetchTransactions(authProvider.user!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: transactionProvider.transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactionProvider.transactions[index];
            return ListTile(
              title: Text(transaction.description),
              subtitle: Text('${transaction.type} - ${transaction.category} - ${DateFormat.yMMMd().format(transaction.date)}'),
              trailing: Text('\$${transaction.amount.toStringAsFixed(2)}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TransactionFormScreen(transaction: transaction)),
                );
              },
              onLongPress: () {
                transactionProvider.deleteTransaction(transaction.id, authProvider.user!.id);
              },
            );
          },
        );
      },
    );
  }
} */