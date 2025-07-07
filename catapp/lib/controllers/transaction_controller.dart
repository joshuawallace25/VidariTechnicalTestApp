/* import 'package:catapp/models/transaction.dart';
import 'package:catapp/services/database_service.dart';


class TransactionController {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> addTransaction(Transaction transaction) async {
    await _databaseService.insertTransaction(transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _databaseService.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _databaseService.deleteTransaction(id);
  }

  Future<List<Transaction>> getTransactions(String userId, {String? category, DateTime? startDate, DateTime? endDate, double? minAmount, double? maxAmount}) async {
    return await _databaseService.getTransactions(userId, category: category, startDate: startDate, endDate: endDate, minAmount: minAmount, maxAmount: maxAmount);
  }

  Future<Map<String, double>> getSummary(String userId) async {
    final transactions = await _databaseService.getTransactions(userId);
    double income = 0;
    double expense = 0;
    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }
    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }
} */