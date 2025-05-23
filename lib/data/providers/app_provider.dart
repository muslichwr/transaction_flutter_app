import 'package:flutter/foundation.dart';
import '../../data/models/customer.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/transaction_repository.dart';

class AppProvider with ChangeNotifier {
  final CustomerRepository customerRepository;
  final TransactionRepository transactionRepository;

  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  String _customerSearchQuery = '';

  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  String _transactionSearchQuery = '';
  DateTime? _selectedDate;
  String? _selectedCustomerId;
  TransactionType? _selectedTransactionType;

  AppProvider({
    required this.customerRepository,
    required this.transactionRepository,
  }) {
    _loadCustomers();
    _loadTransactions();
  }

  // Customers getters
  List<Customer> get customers => _customers;
  List<Customer> get filteredCustomers => _filteredCustomers;
  String get customerSearchQuery => _customerSearchQuery;

  // Transactions getters
  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get filteredTransactions => _filteredTransactions;
  List<TransactionModel> get recentTransactions =>
      transactionRepository.getRecentTransactions();
  String get transactionSearchQuery => _transactionSearchQuery;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedCustomerId => _selectedCustomerId;
  TransactionType? get selectedTransactionType => _selectedTransactionType;

  // Dashboard stats
  int get totalCustomers => _customers.length;
  double get totalDebt =>
      _customers.fold(0, (sum, customer) => sum + customer.totalDebt);
  double get todayTransactionsTotal =>
      transactionRepository.getTodayTransactionsTotal();
  int get todayTransactionsCount =>
      transactionRepository.getTodayTransactionsCount();

  // Load all customers
  void _loadCustomers() {
    _customers = customerRepository.getAllCustomers();
    _applyCustomerFilters();
    notifyListeners();
  }

  // Load all transactions
  void _loadTransactions() {
    _transactions = transactionRepository.getAllTransactions();
    _applyTransactionFilters();
    notifyListeners();
  }

  // Customer operations
  Future<void> addCustomer(Customer customer) async {
    await customerRepository.addCustomer(customer);
    _loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await customerRepository.updateCustomer(customer);
    _loadCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    await customerRepository.deleteCustomer(id);
    _loadCustomers();
  }

  void searchCustomers(String query) {
    _customerSearchQuery = query;
    _applyCustomerFilters();
    notifyListeners();
  }

  void _applyCustomerFilters() {
    if (_customerSearchQuery.isEmpty) {
      _filteredCustomers = List.from(_customers);
    } else {
      _filteredCustomers = customerRepository.searchCustomers(
        _customerSearchQuery,
      );
    }
  }

  Customer? getCustomerById(String id) {
    return customerRepository.getCustomerById(id);
  }

  // Transaction operations
  Future<void> addTransaction(TransactionModel transaction) async {
    await transactionRepository.addTransaction(transaction);
    _loadCustomers(); // Reload customers to update debt amounts
    _loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await transactionRepository.deleteTransaction(id);
    _loadCustomers(); // Reload customers to update debt amounts
    _loadTransactions();
  }

  void searchTransactions(String query) {
    _transactionSearchQuery = query;
    _applyTransactionFilters();
    notifyListeners();
  }

  void filterTransactionsByDate(DateTime? date) {
    _selectedDate = date;
    _applyTransactionFilters();
    notifyListeners();
  }

  void filterTransactionsByCustomer(String? customerId) {
    _selectedCustomerId = customerId;
    _applyTransactionFilters();
    notifyListeners();
  }

  void filterTransactionsByType(TransactionType? type) {
    _selectedTransactionType = type;
    _applyTransactionFilters();
    notifyListeners();
  }

  void clearTransactionFilters() {
    _transactionSearchQuery = '';
    _selectedDate = null;
    _selectedCustomerId = null;
    _selectedTransactionType = null;
    _applyTransactionFilters();
    notifyListeners();
  }

  void _applyTransactionFilters() {
    _filteredTransactions = List.from(_transactions);

    // Apply search query
    if (_transactionSearchQuery.isNotEmpty) {
      _filteredTransactions =
          _filteredTransactions.where((transaction) {
            final customer = getCustomerById(transaction.customerId);
            return transaction.description.toLowerCase().contains(
                  _transactionSearchQuery.toLowerCase(),
                ) ||
                (customer?.name.toLowerCase().contains(
                      _transactionSearchQuery.toLowerCase(),
                    ) ??
                    false);
          }).toList();
    }

    // Apply date filter
    if (_selectedDate != null) {
      final startOfDay = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );
      final endOfDay = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        23,
        59,
        59,
      );

      _filteredTransactions =
          _filteredTransactions
              .where(
                (transaction) =>
                    transaction.date.isAfter(startOfDay) &&
                    transaction.date.isBefore(endOfDay),
              )
              .toList();
    }

    // Apply customer filter
    if (_selectedCustomerId != null) {
      _filteredTransactions =
          _filteredTransactions
              .where(
                (transaction) => transaction.customerId == _selectedCustomerId,
              )
              .toList();
    }

    // Apply transaction type filter
    if (_selectedTransactionType != null) {
      _filteredTransactions =
          _filteredTransactions
              .where(
                (transaction) => transaction.type == _selectedTransactionType,
              )
              .toList();
    }

    // Sort by date (most recent first)
    _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
  }

  List<TransactionModel> getTransactionsForCustomer(String customerId) {
    return transactionRepository.getTransactionsByCustomerId(customerId);
  }

  TransactionModel? getTransactionById(String id) {
    return transactionRepository.getTransactionById(id);
  }
}
