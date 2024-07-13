import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late int key;

  Expense({
    required this.title,
    required this.amount,
    required this.date,
  }) {
    key = DateTime.now().millisecondsSinceEpoch;
  }
}
