import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'expense.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter()); // Register the Expense adapter
  await Hive.openBox<Expense>('expenses');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Buddy',
      theme: ThemeData.light(),
      home: MyHomePage(),
    );
  }
}
