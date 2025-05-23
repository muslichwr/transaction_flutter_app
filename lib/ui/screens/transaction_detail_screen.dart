import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_theme.dart';
import '../../data/models/transaction.dart';
import '../../data/providers/app_provider.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String transactionId =
        ModalRoute.of(context)!.settings.arguments as String;
    final appProvider = Provider.of<AppProvider>(context);
    final transaction = appProvider.getTransactionById(transactionId);

    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Details')),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final customer = appProvider.getCustomerById(transaction.customerId);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

    final isDebit = transaction.type == TransactionType.debit;
    final transactionColor = isDebit ? AppColors.debit : AppColors.credit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context, transaction, appProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: transactionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: transactionColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  // Transaction icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: transactionColor.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                      color: transactionColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Transaction amount
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: transactionColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Transaction type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isDebit ? 'Debit' : 'Credit',
                      style: TextStyle(
                        color: transactionColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transaction details
            Text(
              'Transaction Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Customer info
            _buildDetailItem(
              context,
              'Customer',
              customer?.name ?? 'Unknown Customer',
              Icons.person,
            ),

            // Date
            _buildDetailItem(
              context,
              'Date & Time',
              dateFormat.format(transaction.date),
              Icons.calendar_today,
            ),

            // Transaction ID
            _buildDetailItem(
              context,
              'Transaction ID',
              transaction.id,
              Icons.tag,
            ),

            // Description
            _buildDetailItem(
              context,
              'Description',
              transaction.description,
              Icons.description,
            ),

            // Transaction impact
            _buildDetailItem(
              context,
              'Impact on Balance',
              isDebit
                  ? 'Increases customer debt by ${currencyFormat.format(transaction.amount)}'
                  : 'Decreases customer debt by ${currencyFormat.format(transaction.amount)}',
              Icons.account_balance_wallet,
              isDebit ? AppColors.debit : AppColors.credit,
            ),

            const SizedBox(height: 32),

            // Customer info card
            if (customer != null) ...[
              Text(
                'Customer Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Customer avatar
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              customer.name.isNotEmpty
                                  ? customer.name[0].toUpperCase()
                                  : '?',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Customer info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                customer.phone,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),

                        // Current debt
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Current Debt',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(customer.totalDebt),
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color:
                                    customer.totalDebt > 0
                                        ? AppColors.debit
                                        : AppColors.credit,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, [
    Color? iconColor,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TransactionModel transaction,
    AppProvider appProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text(
              'Are you sure you want to delete this transaction? This will update the customer\'s debt balance.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await appProvider.deleteTransaction(transaction.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction has been deleted'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
