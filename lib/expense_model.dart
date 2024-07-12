import 'package:hive/hive.dart';

part 'expense_model.g.dart'; // Generated file name

@HiveType(typeId: 0)
class Expense {
  @HiveField(0)
  late String key; // Ensure key field is included in Hive serialization

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late DateTime date;

  Expense({
    required this.key, // Make sure key is required in the constructor
    required this.title,
    required this.amount,
    required this.date,
  });
}
