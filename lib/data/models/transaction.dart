import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  debit, // Customer owes money

  @HiveField(1)
  credit, // Customer pays money back
}

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final DateTime date;

  TransactionModel({
    String? id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.description,
    DateTime? date,
  }) : id = id ?? const Uuid().v4(),
       date = date ?? DateTime.now();

  // Returns a negative amount if credit (reducing debt) or positive for debit (increasing debt)
  double get signedAmount => type == TransactionType.debit ? amount : -amount;
}
