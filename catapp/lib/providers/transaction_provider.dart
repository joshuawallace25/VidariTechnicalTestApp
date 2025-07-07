/* import 'package:catapp/controllers/transaction_controller.dart';
import 'package:catapp/models/transaction.dart';
import 'package:flutter/material.dart';


class TransactionProvider extends ChangeNotifier {
  final TransactionController _transactionController = TransactionController();
  List<Transaction> _transactions = [];
  Map<String, double> _summary = {'income': 0, 'expense': 0, 'balance': 0};
  final Map<String, double> _budgetLimits = {
    'Groceries': 100.0,
    'Utilities': 200.0,
    'Entertainment': 50.0,
    'Salary': 10000.0,
    'Other': 100.0,
  };

  List<Transaction> get transactions => _transactions;
  Map<String, double> get summary => _summary;

  Future<void> addTransaction(Transaction transaction, {BuildContext? context}) async {
    await _transactionController.addTransaction(transaction);
    await fetchTransactions(transaction.userId);
    if (transaction.type == 'expense' && context != null) {
      _checkBudgetLimit(transaction, context);
    }
  }

  Future<void> updateTransaction(Transaction transaction, {BuildContext? context}) async {
    await _transactionController.updateTransaction(transaction);
    await fetchTransactions(transaction.userId);
    if (transaction.type == 'expense' && context != null) {
      _checkBudgetLimit(transaction, context);
    }
  }

  Future<void> deleteTransaction(String id, String userId) async {
    await _transactionController.deleteTransaction(id);
    await fetchTransactions(userId);
  }

  Future<void> fetchTransactions(String userId, {String? category, DateTime? startDate, DateTime? endDate, double? minAmount, double? maxAmount}) async {
    _transactions = await _transactionController.getTransactions(userId, category: category, startDate: startDate, endDate: endDate, minAmount: minAmount, maxAmount: maxAmount);
    _summary = await _transactionController.getSummary(userId);
    notifyListeners();
  }

  void _checkBudgetLimit(Transaction transaction, BuildContext context) {
    final categoryLimit = _budgetLimits[transaction.category] ?? 100.0;
    final transactions = _transactions.where((t) => t.category == transaction.category && t.type == 'expense').toList();
    final totalCategoryExpense = transactions.fold<double>(0, (sum, t) => sum + t.amount);
    if (totalCategoryExpense > categoryLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Warning: ${transaction.category} expenses exceed budget of \$${categoryLimit.toStringAsFixed(2)}')),
      );
    }
  }
} */