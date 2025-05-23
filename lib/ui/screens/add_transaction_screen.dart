import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_theme.dart';
import '../../data/models/customer.dart';
import '../../data/models/transaction.dart';
import '../../data/providers/app_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCustomerId;
  TransactionType _transactionType = TransactionType.debit;
  DateTime _transactionDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Check if customer ID was passed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args != null) {
        if (args is String) {
          // Just the customer ID was passed
          setState(() {
            _selectedCustomerId = args;
          });
        } else if (args is Map<String, dynamic>) {
          // Customer ID and transaction type were passed
          setState(() {
            _selectedCustomerId = args['customerId'] as String;
            if (args['type'] != null) {
              _transactionType = args['type'] as TransactionType;
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final customers = appProvider.customers;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Form header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'New Transaction',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Record a new transaction for a customer',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Customer dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCustomerId,
                  decoration: const InputDecoration(
                    labelText: 'Select Customer',
                    prefixIcon: Icon(Icons.person),
                  ),
                  items:
                      customers.map((customer) {
                        return DropdownMenuItem<String>(
                          value: customer.id,
                          child: Text(customer.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCustomerId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a customer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Transaction type
                const Text('Transaction Type'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeSelectionTile(
                        title: 'Debit',
                        subtitle: 'Customer owes money',
                        icon: Icons.arrow_upward,
                        color: AppColors.debit,
                        isSelected: _transactionType == TransactionType.debit,
                        onTap: () {
                          setState(() {
                            _transactionType = TransactionType.debit;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTypeSelectionTile(
                        title: 'Credit',
                        subtitle: 'Customer pays money',
                        icon: Icons.arrow_downward,
                        color: AppColors.credit,
                        isSelected: _transactionType == TransactionType.credit,
                        onTap: () {
                          setState(() {
                            _transactionType = TransactionType.credit;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount field
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (Rp)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }

                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date picker
                InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _transactionDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _transactionDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          _transactionDate.hour,
                          _transactionDate.minute,
                        );
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Transaction Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('dd MMMM yyyy').format(_transactionDate),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _submitForm(appProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _transactionType == TransactionType.debit
                              ? AppColors.debit
                              : AppColors.credit,
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              _transactionType == TransactionType.debit
                                  ? 'Add Debit Transaction'
                                  : 'Add Credit Transaction',
                            ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelectionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppColors.textHint.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm(AppProvider appProvider) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final amount = double.parse(_amountController.text.trim());

        final transaction = TransactionModel(
          customerId: _selectedCustomerId!,
          type: _transactionType,
          amount: amount,
          description: _descriptionController.text.trim(),
          date: _transactionDate,
        );

        await appProvider.addTransaction(transaction);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_transactionType == TransactionType.debit ? 'Debit' : 'Credit'} transaction added successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
