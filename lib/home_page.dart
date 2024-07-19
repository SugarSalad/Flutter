import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'expense.dart';

class MyHomePage extends StatefulWidget {
  // ignore: use_super_parameters
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Box<Expense> _expenseBox;
  List<Expense> _expenses = [];
  double _totalMonthlyAmount = 0.0;
  double _totalYearlyAmount = 0.0;
  double _totalExpensesAmount = 0.0;

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

  String? selectedExpenseTitle;

  bool isDarkMode = false; // Default to light mode

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _expenseBox = Hive.box<Expense>('expenses');
    _fetchExpenses();
  }

  void _fetchExpenses() {
    final expenses = _expenseBox.values.toList();
    final now = DateTime.now();

    // Filter for current month and year
    final monthlyExpenses = expenses.where((expense) =>
        expense.date.year == now.year && expense.date.month == now.month).toList();

    // Filter for current year
    final yearlyExpenses =
        expenses.where((expense) => expense.date.year == now.year).toList();

    double totalMonthlyAmount =
        monthlyExpenses.fold(0, (sum, item) => sum + item.amount);
    double totalYearlyAmount =
        yearlyExpenses.fold(0, (sum, item) => sum + item.amount);
    double totalExpensesAmount =
        expenses.fold(0, (sum, item) => sum + item.amount);

    setState(() {
      _expenses = expenses;
      _totalMonthlyAmount = totalMonthlyAmount; // Total for the current month
      _totalYearlyAmount = totalYearlyAmount; // Total for the current year
      _totalExpensesAmount = totalExpensesAmount; // Total expenses
    });
  }

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
    home: Scaffold(
      appBar: AppBar(
        title: Text(
          'Budget Buddy',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.green[900] : Colors.green[100],
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
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
      bottomNavigationBar: BottomAppBar(
        color: isDarkMode ? Colors.green[900] : Colors.green[100],
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
    ),
  );
}


Widget _buildHomeTab() {
  List<double> monthlyExpenses = List.filled(12, 0.0);

  for (var expense in _expenses) {
    int month = expense.date.month;
    monthlyExpenses[month - 1] += expense.amount;
  }

  String formattedTotalMonthlyAmount = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
  ).format(_totalMonthlyAmount);

  String formattedTotalYearlyAmount = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
  ).format(_totalYearlyAmount);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Total Expenses this month: $formattedTotalMonthlyAmount',
          style: const TextStyle(
            fontSize: 24,
            fontFamily: 'BebasNeue',
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Total Expenses this year: $formattedTotalYearlyAmount',
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
              maxY: monthlyExpenses.reduce((value, element) =>
                    value > element ? value : element) *
                    1.5,
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (context, value) => TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
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
                  showTitles: false,
                  getTextStyles: (context, value) => TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  getTitles: (value) {
                    return '₱${NumberFormat.decimalPattern().format(value)}';
                  },
                  reservedSize: 30,
                ),
                topTitles: SideTitles(showTitles: false),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              barGroups: _generateBars(monthlyExpenses),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.grey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    // ignore: unused_local_variable
                    String month;
                    switch (group.x.toInt()) {
                      case 0:
                        month = 'Jan';
                        break;
                      case 1:
                        month = 'Feb';
                        break;
                      case 2:
                        month = 'Mar';
                        break;
                      case 3:
                        month = 'Apr';
                        break;
                      case 4:
                        month = 'May';
                        break;
                      case 5:
                        month = 'Jun';
                        break;
                      case 6:
                        month = 'Jul';
                        break;
                      case 7:
                        month = 'Aug';
                        break;
                      case 8:
                        month = 'Sept';
                        break;
                      case 9:
                        month = 'Oct';
                        break;
                      case 10:
                        month = 'Nov';
                        break;
                      case 11:
                        month = 'Dec';
                        break;
                      default:
                        throw Error();
                    }
                    // Format value to thousands
      String formattedValue = rod.y >= 1000
          ? '₱${(rod.y / 1000).toStringAsFixed(1)}k'
          : rod.y.toString();
                    return BarTooltipItem(
                      '',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      children: <TextSpan>[
          TextSpan(
            // ignore: unnecessary_string_interpolations
            text: '$formattedValue',
            style: const TextStyle(
              color: Color.fromARGB(255, 152, 230, 155),
              fontSize: 10,
              fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
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
              borderRadius: const BorderRadius.all(Radius.zero),
              width: 16,
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return bars;
  }

  Widget _buildExpensesTab() {
    String formattedTotalExpensesAmount = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
    ).format(_totalExpensesAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Total Expenses: $formattedTotalExpensesAmount',
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
    builder: (context) {
      return Theme(
        data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
        child: AlertDialog(
          title: Text(
            'Confirm Delete',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          content: Text(
            'Are you sure you want to delete this expense?',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: isDarkMode ? Colors.red : Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (confirmDelete) {
    _deleteExpense(index);
  }
}


  void _deleteExpense(int index) {
    try {
      _expenseBox.deleteAt(index);
      _fetchExpenses();
    } catch (e) {
      // ignore: avoid_print
      print('Failed to delete expense: $e');
    }
  }

  Future<void> _showExpenseEntryDialog(BuildContext context) async {
  TextEditingController amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  await showDialog(
    context: context,
    builder: (context) {
      return Theme(
        data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
        child: AlertDialog(
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
                    child: Text(
                      title,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Expenses',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₱',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  prefixStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                  ),
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
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
                        child: child!,
                      );
                    },
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
                    border: Border.all(color: isDarkMode ? Colors.white : Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: isDarkMode ? Colors.white : Colors.black),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('dd-MM-yyyy').format(selectedDate),
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
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
              child: Text('Cancel', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            ),
            TextButton(
              onPressed: () {
                if (selectedExpenseTitle == null || amountController.text.isEmpty) {
                  _showErrorDialog(context, 'Please fill in all fields.');
                  return;
                }

                double? amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  _showErrorDialog(context, 'Please enter a valid amount.');
                  return;
                }

                _addExpense(selectedExpenseTitle!, amount, selectedDate);
                amountController.clear();
                selectedDate = DateTime.now();
                selectedExpenseTitle = null;
                Navigator.of(context).pop();
              },
              child: Text('Add', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            ),
          ],
        ),
      );
    },
  );
}

  void _addExpense(String title, double amount, DateTime date) {
    final expense = Expense(
      title: title,
      amount: amount,
      date: date,
    );
    _expenseBox.add(expense);
    _fetchExpenses();
  }

 void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: AlertDialog(
        title: const Text('Input Error'),
        content: Text(message, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
      ),
    );
  }
}
