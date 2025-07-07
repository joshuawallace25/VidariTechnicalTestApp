/* import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:expense_tracker/models/user.dart';
import 'package:expense_tracker/models/transaction.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  Future<void> initializeDatabase() async {
    final path = join(await getDatabasesPath(), 'expense_tracker.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE,
            password TEXT,
            first_name TEXT,
            last_name TEXT,
            created_on TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            type TEXT,
            category TEXT,
            amount REAL,
            date TEXT,
            description TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
      },
    );
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertTransaction(Transaction transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await database;
    await db.update('transactions', transaction.toMap(), where: 'id = ?', whereArgs: [transaction.id]);
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Transaction>> getTransactions(String userId, {String? category, DateTime? startDate, DateTime? endDate, double? minAmount, double? maxAmount}) async {
    final db = await database;
    String whereString = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (category != null) {
      whereString += ' AND category = ?';
      whereArgs.add(category);
    }
    if (startDate != null) {
      whereString += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereString += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    if (minAmount != null) {
      whereString += ' AND amount >= ?';
      whereArgs.add(minAmount);
    }
    if (maxAmount != null) {
      whereString += ' AND amount <= ?';
      whereArgs.add(maxAmount);
    }

    final maps = await db.query('transactions', where: whereString, whereArgs: whereArgs);
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }
} */