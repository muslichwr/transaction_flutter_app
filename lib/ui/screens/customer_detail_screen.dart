import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_theme.dart';
import '../../app/routes/routes.dart';
import '../../data/models/customer.dart';
import '../../data/models/transaction.dart';
import '../../data/providers/app_provider.dart';
import '../widgets/transaction_list_item.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String customerId =
        ModalRoute.of(context)!.settings.arguments as String;
    final appProvider = Provider.of<AppProvider>(context);
    final customer = appProvider.getCustomerById(customerId);

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Details')),
        body: const Center(child: Text('Customer not found')),
      );
    }

    final customerTransactions = appProvider.getTransactionsForCustomer(
      customerId,
    );
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit customer screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer profile card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Customer avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        customer.name.isNotEmpty
                            ? customer.name[0].toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Customer name
                  Text(
                    customer.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Customer phone
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        customer.phone,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Customer address
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        customer.address,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Debt amount
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Debt',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(customer.totalDebt),
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color:
                                customer.totalDebt > 0
                                    ? AppColors.debit
                                    : AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      Icons.add_circle,
                      'Add Debit',
                      AppColors.debit,
                      () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.addTransaction,
                          arguments: {
                            'customerId': customer.id,
                            'type': TransactionType.debit,
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      Icons.remove_circle,
                      'Add Credit',
                      AppColors.credit,
                      () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.addTransaction,
                          arguments: {
                            'customerId': customer.id,
                            'type': TransactionType.credit,
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Transaction history
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${customerTransactions.length} Transactions',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Transaction list
            if (customerTransactions.isEmpty) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a transaction to get started',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: customerTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = customerTransactions[index];
                  return TransactionListItem(
                    transaction: transaction,
                    customerName: customer.name,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.transactionDetail,
                        arguments: transaction.id,
                      );
                    },
                    onDelete: () {
                      _showDeleteTransactionConfirmation(
                        context,
                        transaction,
                        appProvider,
                      );
                    },
                  );
                },
              ),
            ],

            // Add some bottom padding
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addTransaction,
            arguments: customer.id,
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon), const SizedBox(width: 8), Text(label)],
      ),
    );
  }

  void _showDeleteTransactionConfirmation(
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
