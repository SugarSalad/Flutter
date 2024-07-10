import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'expense_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  await Hive.openBox<Expense>('expenses');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'BebasNeue', // Default font family for the entire app
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[100],
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        tabBarTheme: const TabBarTheme(
          labelStyle: TextStyle(
            fontFamily: 'BebasNeue', // Apply PlaywriteESDeco font to tab labels
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.green, // Primary color
          secondary: Colors.amber, // Turmeric color as secondary
          error: Colors.redAccent, // Error color
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Box<Expense>? _expenseBox;
  List<Expense> _expenses = [];
  double _totalMonthlyAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _expenseBox = Hive.box<Expense>('expenses');
    _fetchExpenses();
  }

  void _fetchExpenses() {
    final expenses = _expenseBox?.values.toList() ?? [];
    double totalAmount = expenses.fold(0, (sum, item) => sum + item.amount);
    setState(() {
      _expenses = expenses;
      _totalMonthlyAmount = totalAmount;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Budget Buddy',
        ),
        backgroundColor: Colors.green[100],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.home), text: 'Home'),
                  Tab(icon: Icon(Icons.attach_money), text: 'Expenses'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHomeTab(),
                    _buildExpensesTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                _showExpenseEntryDialog(context);
              },
              child: const Icon(Icons.add),
            )
          : null,

    );
  }

  Widget _buildHomeTab() {
    List<double> monthlyExpenses = List.filled(12, 0.0);

    for (var expense in _expenses) {
      int month = expense.date.month;
      monthlyExpenses[month - 1] += expense.amount;
    }

    String formattedTotalAmount =
        NumberFormat.currency(locale: 'en_PH', symbol: '₱').format(_totalMonthlyAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Total Expenses this month: $formattedTotalAmount',
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'BebasNeue',
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: monthlyExpenses.reduce((value, element) => value > element ? value : element) * 1.5,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (context, value) => const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    getTitles: (value) {
                      switch (value.toInt()) {
                        case 0:
                          return 'Jan';
                        case 1:
                          return 'Feb';
                        case 2:
                          return 'Mar';
                        case 3:
                          return 'Apr';
                        case 4:
                          return 'May';
                        case 5:
                          return 'Jun';
                        case 6:
                          return 'Jul';
                        case 7:
                          return 'Aug';
                        case 8:
                          return 'Sep';
                        case 9:
                          return 'Oct';
                        case 10:
                          return 'Nov';
                        case 11:
                          return 'Dec';
                        default:
                          return '';
                      }
                    },
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (context, value) => const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    reservedSize: 30,
                  ),
                  topTitles: SideTitles(showTitles: false),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black),
                ),
                barGroups: _generateBars(monthlyExpenses),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _generateBars(List<double> monthlyExpenses) {
    List<BarChartGroupData> bars = [];

    for (int i = 0; i < 12; i++) {
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: monthlyExpenses[i],
              colors: [Colors.green],
              width: 30,
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return bars;
  }

  Widget _buildExpensesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Total Expenses this month: ₱${NumberFormat.currency(locale: 'en_PH', symbol: '').format(_totalMonthlyAmount)}',
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'BebasNeue',
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _expenses.length,
            itemBuilder: (context, index) {
              final expense = _expenses[index];
              return ListTile(
                title: Text(
                  expense.title,
                  style: const TextStyle(fontFamily: 'BebasNeue'),
                ),
                subtitle: Text(
                  'Amount: ${NumberFormat.currency(locale: 'en_PH', symbol: '').format(expense.amount)}, Date: ${DateFormat('dd-MM-yyyy').format(expense.date)}',
                  style: const TextStyle(fontFamily: 'BebasNeue'),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDeleteExpense(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmDeleteExpense(int index) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      _deleteExpense(index);
    }
  }

  void _deleteExpense(int index) async {
    final expense = _expenses[index];
    try {
      await _expenseBox?.delete(expense.key); // Use the key field for deletion
      _fetchExpenses(); // Update the list after deletion
    } catch (e) {
      print('Error deleting expense: $e');
      // Handle error, show error message, etc.
    }
  }

  Future<void> _showExpenseEntryDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _addExpense(titleController.text, double.tryParse(amountController.text) ?? 0.0);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addExpense(String title, double amount) async {
  String uniqueKey = DateTime.now().millisecondsSinceEpoch.toString(); // Generate a unique key
  final expense = Expense(
    key: uniqueKey,
    title: title,
    amount: amount,
    date: DateTime.now(),
  );

  await _expenseBox?.add(expense);
  _fetchExpenses();
}


  @override
void dispose() {
  _tabController.dispose();
  _expenseBox?.close(); // Close the Hive box properly
  super.dispose();
}

}
