import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String address;

  @HiveField(4)
  double totalDebt;

  Customer({
    String? id,
    required this.name,
    required this.phone,
    required this.address,
    this.totalDebt = 0.0,
  }) : id = id ?? const Uuid().v4();

  Customer copyWith({
    String? name,
    String? phone,
    String? address,
    double? totalDebt,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      totalDebt: totalDebt ?? this.totalDebt,
    );
  }

  void updateDebt(double amount) {
    totalDebt += amount;
    save();
  }
}
