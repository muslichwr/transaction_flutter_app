import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/customer_repository.dart';

class TransactionRepository {
  final Box<TransactionModel> _transactionBox = Hive.box<TransactionModel>(
    'transactions',
  );
  final CustomerRepository _customerRepository = CustomerRepository();

  // Get all transactions
  List<TransactionModel> getAllTransactions() {
    return _transactionBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  // Get transaction by ID
  TransactionModel? getTransactionById(String id) {
    return _transactionBox.values.firstWhere(
      (transaction) => transaction.id == id,
      orElse: () => throw Exception('Transaction not found'),
    );
  }

  // Get transactions for a specific customer
  List<TransactionModel> getTransactionsByCustomerId(String customerId) {
    return _transactionBox.values
        .where((transaction) => transaction.customerId == customerId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  // Get transactions for a specific date
  List<TransactionModel> getTransactionsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _transactionBox.values
        .where(
          (transaction) =>
              transaction.date.isAfter(startOfDay) &&
              transaction.date.isBefore(endOfDay),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get recent transactions
  List<TransactionModel> getRecentTransactions({int limit = 5}) {
    final transactions = getAllTransactions();
    return transactions.take(limit).toList();
  }

  // Add a transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);

    // Update customer debt
    await _customerRepository.updateCustomerDebt(
      transaction.customerId,
      transaction.signedAmount,
    );
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    final transaction = getTransactionById(id);
    if (transaction != null) {
      // Reverse the debt effect
      await _customerRepository.updateCustomerDebt(
        transaction.customerId,
        -transaction.signedAmount,
      );

      await _transactionBox.delete(id);
    }
  }

  // Get transactions by type
  List<TransactionModel> getTransactionsByType(TransactionType type) {
    return _transactionBox.values
        .where((transaction) => transaction.type == type)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get transactions for a date range
  List<TransactionModel> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _transactionBox.values
        .where(
          (transaction) =>
              transaction.date.isAfter(start) && transaction.date.isBefore(end),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get total debt amount for today
  double getTodayTransactionsTotal() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _transactionBox.values
        .where(
          (transaction) =>
              transaction.date.isAfter(startOfDay) &&
              transaction.date.isBefore(endOfDay),
        )
        .fold(0, (sum, transaction) => sum + transaction.signedAmount);
  }

  // Get total transactions count for today
  int getTodayTransactionsCount() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _transactionBox.values
        .where(
          (transaction) =>
              transaction.date.isAfter(startOfDay) &&
              transaction.date.isBefore(endOfDay),
        )
        .length;
  }

  // Generate dummy transactions for testing
  Future<void> seedDummyData() async {
    final customerRepository = CustomerRepository();
    final customers = customerRepository.getAllCustomers();

    // Sample descriptions for transactions
    final debitDescriptions = [
      'Pembelian barang elektronik',
      'Kredit perlengkapan rumah',
      'Pembelian bahan bangunan',
      'Barang toko',
      'Perabotan rumah tangga',
      'Perlengkapan dapur',
      'Kredit smartphone',
      'Pembelian laptop',
      'Alat pertanian',
      'Sepeda motor',
    ];

    final creditDescriptions = [
      'Pembayaran cicilan',
      'Pelunasan sebagian',
      'Pembayaran utang',
      'Cicilan bulanan',
      'Pembayaran kredit',
      'Pelunasan pinjaman',
      'Angsuran pertama',
      'Pembayaran kekurangan',
    ];

    // Transaction date range (3 months ago until now)
    final now = DateTime.now();
    final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);

    // Generate 50+ random transactions
    final transactions = <TransactionModel>[];

    for (int i = 0; i < 60; i++) {
      // Randomly select a customer
      final customer = customers[i % customers.length];

      // Randomly determine transaction type
      final isDebit =
          i % 3 != 0; // 2/3 debit, 1/3 credit to ensure debt builds up
      final type = isDebit ? TransactionType.debit : TransactionType.credit;

      // Random amount between 10,000 and 500,000
      final amount = (10000 + (490000 * (i % 10) / 10)).roundToDouble();

      // Random date between 3 months ago and now
      final daysToAdd =
          (now.difference(threeMonthsAgo).inDays * (i / 60)).round();
      final transactionDate = threeMonthsAgo.add(Duration(days: daysToAdd));

      // Select description based on type
      final descriptions = isDebit ? debitDescriptions : creditDescriptions;
      final description = descriptions[i % descriptions.length];

      transactions.add(
        TransactionModel(
          id: 'trans-${i + 1}',
          customerId: customer.id,
          type: type,
          amount: amount,
          description: description,
          date: transactionDate,
        ),
      );
    }

    // Add all transactions
    for (final transaction in transactions) {
      await _transactionBox.put(transaction.id, transaction);

      // Update customer debt
      await _customerRepository.updateCustomerDebt(
        transaction.customerId,
        transaction.signedAmount,
      );
    }
  }
}
