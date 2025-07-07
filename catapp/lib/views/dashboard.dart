/* import 'package:catapp/providers/auth_provider.dart';
import 'package:catapp/providers/transaction_provider.dart';
import 'package:catapp/views/login_views.dart';
import 'package:catapp/views/report.dart';
import 'package:catapp/views/transaction.dart';
import 'package:catapp/views/widget.dart/transactionslist.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${authProvider.user?.firstName ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Income: \$${transactionProvider.summary['income']?.toStringAsFixed(2) ?? '0.00'}'),
                    Text('Expense: \$${transactionProvider.summary['expense']?.toStringAsFixed(2) ?? '0.00'}'),
                    Text('Balance: \$${transactionProvider.summary['balance']?.toStringAsFixed(2) ?? '0.00'}'),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen()));
            },
            child: const Text('View Monthly Report'),
          ),
          const Expanded(child: TransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionFormScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} */