import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

// Models
class User {
  final String id;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final DateTime createdOn;

  const User({
    required this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.createdOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'created_on': createdOn.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      createdOn: DateTime.parse(map['created_on']),
    );
  }
}

class Transaction {
  final String id;
  final String userId;
  final String type;
  final String category;
  final double amount;
  final DateTime date;
  final String description;

  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['user_id'],
      type: map['type'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }
}

// Database Helper
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB('expense_tracker.db');
      print('Database initialized successfully');
      return _database!;
    } catch (e) {
      print('Error initializing database: $e');
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
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
          FOREIGN KEY (user_id) REFERENCES users(id)
        )
      ''');
      print('Database tables created successfully');
    } catch (e) {
      print('Error creating database tables: $e');
      throw Exception('Failed to create tables: $e');
    }
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    try {
      await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.fail);
    } catch (e) {
      throw Exception('Failed to insert user: $e');
    }
  }

  Future<User?> getUser(String email, String password) async {
    final db = await database;
    try {
      final maps = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      return maps.isNotEmpty ? User.fromMap(maps.first) : null;
    } catch (e) {
      throw Exception('Failed to retrieve user: $e');
    }
  }

  Future<void> insertTransaction(Transaction transaction) async {
    final db = await database;
    try {
      await db.insert('transactions', transaction.toMap());
    } catch (e) {
      throw Exception('Failed to insert transaction: $e');
    }
  }

  Future<List<Transaction>> getTransactions(String userId) async {
    final db = await database;
    try {
      final maps = await db.query(
        'transactions',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return maps.map((e) => Transaction.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to retrieve transactions: $e');
    }
  }

  Future<List<Transaction>> filterTransactions(String userId, {String? category, DateTime? startDate, DateTime? endDate, double? minAmount, String? keyword}) async {
    final db = await database;
    try {
      String where = 'user_id = ?';
      List<dynamic> args = [userId];
      if (category != null) {
        where += ' AND category = ?';
        args.add(category);
      }
      if (startDate != null) {
        where += ' AND date >= ?';
        args.add(startDate.toIso8601String());
      }
      if (endDate != null) {
        where += ' AND date <= ?';
        args.add(endDate.toIso8601String());
      }
      if (minAmount != null) {
        where += ' AND amount >= ?';
        args.add(minAmount);
      }
      if (keyword != null) {
        where += ' AND description LIKE ?';
        args.add('%$keyword%');
      }
      final maps = await db.query('transactions', where: where, whereArgs: args);
      return maps.map((e) => Transaction.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to filter transactions: $e');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await database;
    try {
      await db.update(
        'transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    try {
      await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }
}

// Providers
class AuthProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      print('Login failed: Empty email or password');
      return false;
    }
    try {
      final user = await DatabaseHelper.instance.getUser(email, password);
      if (user != null) {
        _user = user;
        notifyListeners();
        print('Login successful for email: $email');
        return true;
      }
      print('Login failed: No user found for email: $email');
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(String email, String password, String firstName, String lastName) async {
    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      print('Signup failed: Empty fields');
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      print('Signup failed: Invalid email format');
      return false;
    }
    try {
      if (await DatabaseHelper.instance.emailExists(email)) {
        print('Signup failed: Email already exists: $email');
        return false;
      }
      final user = User(
        id: const Uuid().v4(),
        email: email,
        password: password, // In production, hash the password
        firstName: firstName,
        lastName: lastName,
        createdOn: DateTime.now(),
      );
      await DatabaseHelper.instance.insertUser(user);
      _user = user;
      notifyListeners();
      print('Signup successful for email: $email');
      return true;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
    print('User logged out');
  }
}

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      _transactions = await DatabaseHelper.instance.getTransactions(userId);
      _isLoading = false;
      notifyListeners();
      print('Transactions loaded for user: $userId');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading transactions: $e');
    }
  }

  Future<void> addTransaction(String userId, String type, String category, double amount, String description) async {
    try {
      final transaction = Transaction(
        id: const Uuid().v4(),
        userId: userId,
        type: type,
        category: category,
        amount: amount,
        date: DateTime.now(),
        description: description,
      );
      await DatabaseHelper.instance.insertTransaction(transaction);
      _transactions.add(transaction);
      notifyListeners();
      print('Transaction added: $type, $category, $amount');
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await DatabaseHelper.instance.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
        print('Transaction updated: ${transaction.id}');
      }
    } catch (e) {
      print('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
      print('Transaction deleted: $id');
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  Future<List<Transaction>> searchTransactions(String userId, String keyword) async {
    try {
      final transactions = await DatabaseHelper.instance.filterTransactions(userId, keyword: keyword);
      print('Search completed for keyword: $keyword');
      return transactions;
    } catch (e) {
      print('Error searching transactions: $e');
      return [];
    }
  }

  Future<List<Transaction>> filterTransactionsByCriteria(String userId, {String? category, DateTime? startDate, DateTime? endDate, double? minAmount}) async {
    try {
      final transactions = await DatabaseHelper.instance.filterTransactions(userId, category: category, startDate: startDate, endDate: endDate, minAmount: minAmount);
      print('Filtered transactions for user: $userId');
      return transactions;
    } catch (e) {
      print('Error filtering transactions: $e');
      return [];
    }
  }

  double getTotalIncome() => _transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, t) => sum + t.amount);

  double getTotalExpenses() => _transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);

  double getBalance() => getTotalIncome() - getTotalExpenses();

  List<Transaction> filterTransactions({String? category, DateTime? startDate, DateTime? endDate, double? minAmount}) {
    return _transactions.where((t) {
      bool matches = true;
      if (category != null) matches = matches && t.category == category;
      if (startDate != null) matches = matches && t.date.isAfter(startDate);
      if (endDate != null) matches = matches && t.date.isBefore(endDate);
      if (minAmount != null) matches = matches && t.amount >= minAmount;
      return matches;
    }).toList();
  }
}

// Screens
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isSignup = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade200, Colors.blue.shade600],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isSignup ? 'Create Account' : 'Welcome Back',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                        ),
                        const SizedBox(height: 24),
                        if (_isSignup) ...[
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              errorText: _firstNameController.text.isEmpty && _isSignup ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              errorText: _lastNameController.text.isEmpty && _isSignup ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            errorText: _emailController.text.isEmpty ? 'Required' : null,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            errorText: _passwordController.text.isEmpty ? 'Required' : null,
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            setState(() {}); // Trigger validation
                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            bool success;
                            if (_isSignup) {
                              if (_firstNameController.text.isEmpty ||
                                  _lastNameController.text.isEmpty ||
                                  _emailController.text.isEmpty ||
                                  _passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all fields')),
                                );
                                return;
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Invalid email format')),
                                );
                                return;
                              }
                              success = await auth.signup(
                                _emailController.text,
                                _passwordController.text,
                                _firstNameController.text,
                                _lastNameController.text,
                              );
                              if (!success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Signup failed: Email may already exist or database error')),
                                );
                              }
                            } else {
                              if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter email and password')),
                                );
                                return;
                              }
                              success = await auth.login(_emailController.text, _passwordController.text);
                              if (!success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Invalid credentials')),
                                );
                              }
                            }
                            if (success) {
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          },
                          child: Text(_isSignup ? 'Sign Up' : 'Login'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignup = !_isSignup;
                              _emailController.clear();
                              _passwordController.clear();
                              _firstNameController.clear();
                              _lastNameController.clear();
                              _animationController.forward(from: 0);
                            });
                          },
                          child: Text(
                            _isSignup ? 'Have an account? Login' : 'Need an account? Sign Up',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    if (authProvider.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: transactionProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          'Balance: \$${transactionProvider.getBalance().toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Income: \$${transactionProvider.getTotalIncome().toStringAsFixed(2)} | '
                            'Expenses: \$${transactionProvider.getTotalExpenses().toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(context, 'Add Transaction', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionScreen()))),
                        _buildActionButton(context, 'Reports', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen()))),
                        _buildActionButton(context, 'Search', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
                        _buildActionButton(context, 'Filter', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen()))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: transactionProvider.transactions.isEmpty
                        ? const Center(child: Text('No transactions yet', style: TextStyle(fontSize: 16)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: transactionProvider.transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactionProvider.transactions[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: transaction.type == 'income' ? Colors.green.shade100 : Colors.red.shade100,
                                    child: Icon(
                                      transaction.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: transaction.type == 'income' ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  title: Text(
                                    '${transaction.category}: \$${transaction.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    '${transaction.type.toUpperCase()} | ${DateFormat('MMM dd, yyyy').format(transaction.date)} | ${transaction.description}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => TransactionScreen(transaction: transaction)),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _confirmDelete(context, transactionProvider, transaction.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, VoidCallback onPressed) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
          ),
          onPressed: onPressed,
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TransactionProvider provider, String transactionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await provider.deleteTransaction(transactionId);
    }
  }
}

class TransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const TransactionScreen({super.key, this.transaction});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'expense';
  String? _selectedCategory;
  final List<String> _categories = ['Groceries', 'Utilities', 'Entertainment', 'Transport', 'Dining', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _categoryController.text = widget.transaction!.category;
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description;
      _type = widget.transaction!.type;
      _selectedCategory = _categories.contains(widget.transaction!.category) ? widget.transaction!.category : 'Other';
    } else {
      _selectedCategory = _categories[0];
      _categoryController.text = _categories[0];
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.swap_vert),
                    ),
                    items: ['income', 'expense'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type.toUpperCase()));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                        _categoryController.text = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'Custom Category (if Other)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.edit),
                      errorText: _categoryController.text.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money),
                      errorText: _amountController.text.isEmpty ? 'Required' : null,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Notes (e.g., Coffee at Starbucks)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      setState(() {}); // Trigger validation
                      if (_categoryController.text.isEmpty || _amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill category and amount')),
                        );
                        return;
                      }
                      try {
                        final amount = double.parse(_amountController.text);
                        if (amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Amount must be positive')),
                          );
                          return;
                        }
                        if (widget.transaction == null) {
                          await transactionProvider.addTransaction(
                            authProvider.user!.id,
                            _type,
                            _categoryController.text,
                            amount,
                            _descriptionController.text,
                          );
                        } else {
                          await transactionProvider.updateTransaction(
                            Transaction(
                              id: widget.transaction!.id,
                              userId: widget.transaction!.userId,
                              type: _type,
                              category: _categoryController.text,
                              amount: amount,
                              date: widget.transaction!.date,
                              description: _descriptionController.text,
                            ),
                          );
                        }
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid amount format')),
                        );
                      }
                    },
                    child: Text(widget.transaction == null ? 'Add' : 'Update'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthlyTransactions = transactionProvider.filterTransactions(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    final categories = monthlyTransactions.map((t) => t.category).toSet().toList();
    final categoryTotals = <String, double>{};
    for (var category in categories) {
      categoryTotals[category] = monthlyTransactions
          .where((t) => t.category == category && t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  'Monthly Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Income: \$${transactionProvider.getTotalIncome().toStringAsFixed(2)}\n'
                    'Expenses: \$${transactionProvider.getTotalExpenses().toStringAsFixed(2)}\n'
                    'Balance: \$${transactionProvider.getBalance().toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...categoryTotals.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Transaction> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Transactions'),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by notes (e.g., Coffee)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                      });
                    },
                  ),
                ),
                onFieldSubmitted: (value) async {
                  if (value.isNotEmpty && authProvider.user != null) {
                    final results = await transactionProvider.searchTransactions(
                      authProvider.user!.id,
                      value,
                    );
                    setState(() {
                      _searchResults = results;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a search keyword')),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _searchResults.isEmpty
                    ? const Center(child: Text('No results found', style: TextStyle(fontSize: 16)))
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final transaction = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transaction.type == 'income' ? Colors.green.shade100 : Colors.red.shade100,
                                child: Icon(
                                  transaction.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: transaction.type == 'income' ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(
                                '${transaction.category}: \$${transaction.amount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${transaction.type.toUpperCase()} | ${DateFormat('MMM dd, yyyy').format(transaction.date)} | ${transaction.description}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => TransactionScreen(transaction: transaction)),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDelete(context, transactionProvider, transaction.id).then((_) {
                                      setState(() {
                                        _searchResults.removeWhere((t) => t.id == transaction.id);
                                      });
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TransactionProvider provider, String transactionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await provider.deleteTransaction(transactionId);
    }
  }
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _minAmountController = TextEditingController();
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Transaction> _filteredTransactions = [];
  final List<String> _categories = ['Groceries', 'Utilities', 'Entertainment', 'Transport', 'Dining', 'Other'];

  @override
  void dispose() {
    _minAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Transactions'),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: [null, ..._categories].map((category) {
                      return DropdownMenuItem(value: category, child: Text(category ?? 'All Categories'));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: _startDate == null ? 'Select Start Date' : 'Start: ${DateFormat('MMM dd, yyyy').format(_startDate!)}',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _startDate = date;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: _endDate == null ? 'Select End Date' : 'End: ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _endDate = date;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _minAmountController,
                    decoration: InputDecoration(
                      labelText: 'Minimum Amount',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (authProvider.user != null) {
                        double? minAmount;
                        if (_minAmountController.text.isNotEmpty) {
                          try {
                            minAmount = double.parse(_minAmountController.text);
                            if (minAmount < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Minimum amount cannot be negative')),
                              );
                              return;
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid amount format')),
                            );
                            return;
                          }
                        }
                        final results = await transactionProvider.filterTransactionsByCriteria(
                          authProvider.user!.id,
                          category: _selectedCategory,
                          startDate: _startDate,
                          endDate: _endDate,
                          minAmount: minAmount,
                        );
                        setState(() {
                          _filteredTransactions = results;
                        });
                      }
                    },
                    child: const Text('Apply Filter'),
                  ),
                  const SizedBox(height: 16),
                  _filteredTransactions.isEmpty
                      ? const Center(child: Text('No transactions match the filter', style: TextStyle(fontSize: 16)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _filteredTransactions[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: transaction.type == 'income' ? Colors.green.shade100 : Colors.red.shade100,
                                  child: Icon(
                                    transaction.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: transaction.type == 'income' ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  '${transaction.category}: \$${transaction.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${transaction.type.toUpperCase()} | ${DateFormat('MMM dd, yyyy').format(transaction.date)} | ${transaction.description}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => TransactionScreen(transaction: transaction)),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDelete(context, transactionProvider, transaction.id).then((_) {
                                        setState(() {
                                          _filteredTransactions.removeWhere((t) => t.id == transaction.id);
                                        });
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TransactionProvider provider, String transactionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await provider.deleteTransaction(transactionId);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.blue.shade50,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme:  CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}