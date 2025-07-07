/* import 'package:catapp/models/transaction.dart';
import 'package:catapp/providers/auth_provider.dart';
import 'package:catapp/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  _TransactionFormScreenState createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'expense';
  String _category = 'Groceries';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ['Groceries', 'Utilities', 'Entertainment', 'Salary', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description;
      _type = widget.transaction!.type;
      _category = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: ['income', 'expense'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _type = value!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => setState(() => _category = value!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter an amount' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Enter a description' : null,
              ),
              TextButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedDate = pickedDate);
                  }
                },
                child: Text('Date: ${DateFormat.yMMMd().format(_selectedDate)}'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final transaction = Transaction(
                      id: widget.transaction?.id,
                      userId: authProvider.user!.id,
                      type: _type,
                      category: _category,
                      amount: double.parse(_amountController.text),
                      date: _selectedDate,
                      description: _descriptionController.text,
                    );
                    if (widget.transaction == null) {
                      transactionProvider.addTransaction(transaction, context: context);
                    } else {
                      transactionProvider.updateTransaction(transaction, context: context);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.transaction == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} */