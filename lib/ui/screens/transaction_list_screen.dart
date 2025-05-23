import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_theme.dart';
import '../../app/routes/routes.dart';
import '../../data/models/transaction.dart';
import '../../data/providers/app_provider.dart';
import '../widgets/transaction_list_item.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.searchTransactions(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addTransaction);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
              ),
            ),
          ),

          // Active filters
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              final hasFilters =
                  appProvider.selectedDate != null ||
                  appProvider.selectedCustomerId != null ||
                  appProvider.selectedTransactionType != null;

              if (!hasFilters) {
                return const SizedBox.shrink();
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Filters applied',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        appProvider.clearTransactionFilters();
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
            },
          ),

          // Transaction list
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                final transactions = appProvider.filteredTransactions;

                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          appProvider.transactionSearchQuery.isEmpty &&
                                  appProvider.selectedDate == null &&
                                  appProvider.selectedCustomerId == null &&
                                  appProvider.selectedTransactionType == null
                              ? 'No transactions found'
                              : 'No transactions match the current filters',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final customer = appProvider.getCustomerById(
                      transaction.customerId,
                    );

                    return TransactionListItem(
                      transaction: transaction,
                      customerName: customer?.name ?? 'Unknown Customer',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.transactionDetail,
                          arguments: transaction.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Transactions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Date filter
                  Text('Date', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: appProvider.selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );

                      if (selectedDate != null) {
                        setState(() {
                          appProvider.filterTransactionsByDate(selectedDate);
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.textHint),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            appProvider.selectedDate != null
                                ? DateFormat(
                                  'dd MMM yyyy',
                                ).format(appProvider.selectedDate!)
                                : 'Select Date',
                            style: TextStyle(
                              color:
                                  appProvider.selectedDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textHint,
                            ),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),

                  // Transaction type filter
                  const SizedBox(height: 16),
                  Text(
                    'Transaction Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeFilterChip(
                          context,
                          'Debit',
                          TransactionType.debit,
                          appProvider.selectedTransactionType ==
                              TransactionType.debit,
                          (selected) {
                            setState(() {
                              if (selected) {
                                appProvider.filterTransactionsByType(
                                  TransactionType.debit,
                                );
                              } else {
                                appProvider.filterTransactionsByType(null);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTypeFilterChip(
                          context,
                          'Credit',
                          TransactionType.credit,
                          appProvider.selectedTransactionType ==
                              TransactionType.credit,
                          (selected) {
                            setState(() {
                              if (selected) {
                                appProvider.filterTransactionsByType(
                                  TransactionType.credit,
                                );
                              } else {
                                appProvider.filterTransactionsByType(null);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Buttons
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              appProvider.clearTransactionFilters();
                            });
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeFilterChip(
    BuildContext context,
    String label,
    TransactionType type,
    bool isSelected,
    ValueChanged<bool> onSelected,
  ) {
    final color =
        type == TransactionType.debit ? AppColors.debit : AppColors.credit;

    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? color : AppColors.textHint),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == TransactionType.debit
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: isSelected ? color : AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
