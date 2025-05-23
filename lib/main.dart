import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'data/models/customer.dart';
import 'data/models/transaction.dart';
import 'data/providers/app_provider.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/transaction_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());

  // Open boxes
  await Hive.openBox<Customer>('customers');
  await Hive.openBox<TransactionModel>('transactions');

  // Initialize repositories
  final customerRepository = CustomerRepository();
  final transactionRepository = TransactionRepository();

  // Initialize seed data if needed
  await _initSeedDataIfNeeded(customerRepository, transactionRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (_) => AppProvider(
                customerRepository: customerRepository,
                transactionRepository: transactionRepository,
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initSeedDataIfNeeded(
  CustomerRepository customerRepository,
  TransactionRepository transactionRepository,
) async {
  final customerBox = Hive.box<Customer>('customers');

  // Only seed data if the box is empty
  if (customerBox.isEmpty) {
    await customerRepository.seedDummyData();
    await transactionRepository.seedDummyData();
  }
}
