/* import 'package:catapp/providers/auth_provider.dart';
import 'package:catapp/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Report')),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedMonth,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() => _selectedMonth = pickedDate);
                transactionProvider.fetchTransactions(
                  authProvider.user!.id,
                  startDate: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
                  endDate: DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0),
                );
              }
            },
            child: Text('Select Month: ${DateFormat.yMMM().format(_selectedMonth)}'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactionProvider.transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactionProvider.transactions[index];
                return ListTile(
                  title: Text(transaction.description),
                  subtitle: Text('${transaction.type} - ${transaction.category} - ${DateFormat.yMMMd().format(transaction.date)}'),
                  trailing: Text('\$${transaction.amount.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} */