import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/customer.dart';

class CustomerRepository {
  final Box<Customer> _customerBox = Hive.box<Customer>('customers');

  // Get all customers
  List<Customer> getAllCustomers() {
    return _customerBox.values.toList();
  }

  // Get customer by ID
  Customer? getCustomerById(String id) {
    return _customerBox.values.firstWhere(
      (customer) => customer.id == id,
      orElse: () => throw Exception('Customer not found'),
    );
  }

  // Add a customer
  Future<void> addCustomer(Customer customer) async {
    await _customerBox.put(customer.id, customer);
  }

  // Update a customer
  Future<void> updateCustomer(Customer customer) async {
    await _customerBox.put(customer.id, customer);
  }

  // Delete a customer
  Future<void> deleteCustomer(String id) async {
    await _customerBox.delete(id);
  }

  // Search customers by name or phone
  List<Customer> searchCustomers(String query) {
    final normalizedQuery = query.toLowerCase().trim();

    return _customerBox.values.where((customer) {
      return customer.name.toLowerCase().contains(normalizedQuery) ||
          customer.phone.contains(normalizedQuery);
    }).toList();
  }

  // Update customer debt amount
  Future<void> updateCustomerDebt(String customerId, double amount) async {
    final customer = getCustomerById(customerId);
    if (customer != null) {
      customer.totalDebt += amount;
      await updateCustomer(customer);
    }
  }

  // Generate dummy customers for testing
  Future<void> seedDummyData() async {
    final dummyCustomers = [
      Customer(
        id: '1',
        name: 'Ahmad Wijaya',
        phone: '081234567890',
        address: 'Jl. Merdeka No. 123, Jakarta',
        totalDebt: 150000,
      ),
      Customer(
        id: '2',
        name: 'Siti Rahayu',
        phone: '081298765432',
        address: 'Jl. Kenanga No. 45, Bandung',
        totalDebt: 275000,
      ),
      Customer(
        id: '3',
        name: 'Budi Santoso',
        phone: '087812345678',
        address: 'Jl. Mawar No. 67, Surabaya',
        totalDebt: 0,
      ),
      Customer(
        id: '4',
        name: 'Dewi Lestari',
        phone: '081387654321',
        address: 'Jl. Dahlia No. 12, Yogyakarta',
        totalDebt: 425000,
      ),
      Customer(
        id: '5',
        name: 'Rizky Pratama',
        phone: '089876543210',
        address: 'Jl. Melati No. 89, Semarang',
        totalDebt: 180000,
      ),
      Customer(
        id: '6',
        name: 'Putri Indah',
        phone: '081234987654',
        address: 'Jl. Anggrek No. 34, Malang',
        totalDebt: 50000,
      ),
      Customer(
        id: '7',
        name: 'Anwar Ibrahim',
        phone: '087812309876',
        address: 'Jl. Flamboyan No. 56, Makassar',
        totalDebt: 320000,
      ),
      Customer(
        id: '8',
        name: 'Rina Suryani',
        phone: '081345678901',
        address: 'Jl. Cempaka No. 78, Medan',
        totalDebt: 90000,
      ),
      Customer(
        id: '9',
        name: 'Doni Kusuma',
        phone: '089812345678',
        address: 'Jl. Kamboja No. 23, Palembang',
        totalDebt: 200000,
      ),
      Customer(
        id: '10',
        name: 'Lina Marlina',
        phone: '081234567809',
        address: 'Jl. Tulip No. 45, Balikpapan',
        totalDebt: 150000,
      ),
      Customer(
        id: '11',
        name: 'Hadi Wijaya',
        phone: '087898765432',
        address: 'Jl. Lotus No. 67, Manado',
        totalDebt: 75000,
      ),
      Customer(
        id: '12',
        name: 'Maya Sari',
        phone: '081234598765',
        address: 'Jl. Teratai No. 89, Denpasar',
        totalDebt: 500000,
      ),
    ];

    for (final customer in dummyCustomers) {
      await addCustomer(customer);
    }
  }
}
