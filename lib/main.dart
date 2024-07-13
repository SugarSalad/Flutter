import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'my_app.dart';
import 'expense.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  await Hive.openBox<Expense>('expenses');
  runApp(const MyApp());
}
