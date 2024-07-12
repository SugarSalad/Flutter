import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
        fontFamily: 'BebasNeue',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[100],
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        tabBarTheme: const TabBarTheme(
          labelStyle: TextStyle(
            fontFamily: 'BebasNeue',
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.green,
          secondary: Colors.amber,
          error: Colors.redAccent,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Box<Expense> _expenseBox;
  List<Expense> _expenses = [];
  double _totalMonthlyAmount = 0.0;

  // Predefined list of expense titles
  List<String> expenseTitles = [
    'Food',
    'Transportation',
    'Utilities',
    'Entertainment',
    'Healthcare',
    'Education',
    'Shopping',
    'Bills',
    'Other',
  ];

  // Selected expense title
  String? selectedExpenseTitle;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _expenseBox = Hive.box<Expense>('expenses');
    _fetchExpenses();
  }

  void _fetchExpenses() {
    final expenses = _expenseBox.values.toList();
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
        title: const Text('Budget Buddy'),
        backgroundColor: Colors.green[100],
      ),
      body: Column(
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
      ),
      floatingActionButton: null, // Remove floating action button
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _showExpenseEntryDialog(context);
              },
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

Widget _buildHomeTab() {
  List<double> monthlyExpenses = List.filled(12, 0.0);

  for (var expense in _expenses) {
    int month = expense.date.month;
    monthlyExpenses[month - 1] += expense.amount;
  }

  String formattedTotalAmount = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
  ).format(_totalMonthlyAmount);

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
                  getTitles: (value) {
                    // Format the left axis labels with peso sign and currency format
                    return '₱${NumberFormat.decimalPattern().format(value)}';
                  },
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
    List<Color> barColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.teal,
      Colors.pink,
      Colors.cyan,
      Colors.indigo,
      Colors.brown,
      Colors.deepOrange,
    ];

    List<BarChartGroupData> bars = [];

    for (int i = 0; i < 12; i++) {
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: monthlyExpenses[i],
              colors: [barColors[i % barColors.length]], // Assigning color based on index
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

  void _deleteExpense(int index) {
    try {
      _expenseBox.deleteAt(index);
      _fetchExpenses(); // Update the list after deletion
    } catch (e) {
      // Handle error, show error message, etc.
      // ignore: avoid_print
      print('Error deleting expense: $e');
    }
  }

Future<void> _showExpenseEntryDialog(BuildContext context) async {
  TextEditingController amountController = TextEditingController();
  DateTime selectedDate = DateTime.now(); // Default to current date

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedExpenseTitle,
              onChanged: (value) {
                setState(() {
                  selectedExpenseTitle = value;
                });
              },
              items: expenseTitles.map((String title) {
                return DropdownMenuItem<String>(
                  value: title,
                  child: Text(title),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Expenses',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₱', // Add pesos sign as prefix
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today), // Calendar icon
                    const SizedBox(width: 10),
                    Text(DateFormat('dd-MM-yyyy').format(selectedDate)),
                  ],
                ),
              ),
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
              _addExpense(selectedExpenseTitle!, double.tryParse(amountController.text) ?? 0.0, selectedDate);
              amountController.clear(); // Clear the amount field
              selectedDate = DateTime.now(); // Reset selected date to current date
              selectedExpenseTitle = null; // Reset dropdown value
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
}

void _addExpense(String title, double amount, DateTime date) {
  final expense = Expense(
    title: title,
    amount: amount,
    date: date,
  );
  _expenseBox.add(expense);
  _fetchExpenses(); // Update the list after addition
}




  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}



@HiveType(typeId: 0)
class Expense {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late int key; // Ensure to initialize this field

  Expense({
    required this.title,
    required this.amount,
    required this.date,
  }) {
    // Initialize the key with a unique value, such as current timestamp
    key = DateTime.now().millisecondsSinceEpoch;
  }
}



class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    return Expense(
      title: reader.read(),
      amount: reader.read(),
      date: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.write(obj.title);
    writer.write(obj.amount);
    writer.write(obj.date);
  }
}
