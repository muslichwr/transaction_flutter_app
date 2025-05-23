import 'package:flutter/material.dart';
import '../../ui/screens/home_screen.dart';
import '../../ui/screens/customer_list_screen.dart';
import '../../ui/screens/customer_detail_screen.dart';
import '../../ui/screens/add_customer_screen.dart';
import '../../ui/screens/add_transaction_screen.dart';
import '../../ui/screens/transaction_list_screen.dart';
import '../../ui/screens/transaction_detail_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String customerList = '/customers';
  static const String customerDetail = '/customers/detail';
  static const String addCustomer = '/customers/add';
  static const String transactionList = '/transactions';
  static const String transactionDetail = '/transactions/detail';
  static const String addTransaction = '/transactions/add';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      customerList: (context) => const CustomerListScreen(),
      customerDetail: (context) => const CustomerDetailScreen(),
      addCustomer: (context) => const AddCustomerScreen(),
      transactionList: (context) => const TransactionListScreen(),
      transactionDetail: (context) => const TransactionDetailScreen(),
      addTransaction: (context) => const AddTransactionScreen(),
    };
  }
}
