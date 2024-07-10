import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _expenses = [];
  double _totalMonthlyAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    int month = expense['date'].month;
    monthlyExpenses[month - 1] += expense['amount'];
  }

  // Format total monthly amount with commas
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
                    fontSize: 14, // Adjust the font size here
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
                    fontSize: 10, // Adjust the font size here
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
    List<double> monthlyExpenses = List.filled(12, 0.0);

    for (var expense in _expenses) {
      int month = expense['date'].month;
      monthlyExpenses[month - 1] += expense['amount'];
    }

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
                  expense['title'],
                  style: const TextStyle(fontFamily: 'BebasNeue'),
                ),
                subtitle: Text(
                  'Amount: ₱${NumberFormat.currency(locale: 'en_PH', symbol: '').format(expense['amount'])}, Date: ${DateFormat('dd-MM-yyyy').format(expense['date'])}',
                  style: const TextStyle(fontFamily: 'BebasNeue'),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to delete this expense?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      setState(() {
        _totalMonthlyAmount -= _expenses[index]['amount'];
        _expenses.removeAt(index);
      });
    }
  }

  void _showExpenseEntryDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExpenseEntryDialog();
      },
    );

    if (result != null) {
      String title = result['title'];
      double amount = double.tryParse(result['amount'] ?? '') ?? 0.0;

      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid amount.'),
          ),
        );
        return;
      }

      DateTime date = DateTime.now();

      setState(() {
        _expenses.add({
          'title': title,
          'amount': amount,
          'date': date,
        });

        _totalMonthlyAmount += amount;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class ExpenseEntryDialog extends StatefulWidget {
  @override
  _ExpenseEntryDialogState createState() => _ExpenseEntryDialogState();
}

class _ExpenseEntryDialogState extends State<ExpenseEntryDialog> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
            ],
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            String title = _titleController.text.trim();
            String amount = _amountController.text.trim();

            if (title.isEmpty || amount.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter valid data.'),
                ),
              );
            } else {
              Navigator.of(context).pop({
                'title': title,
                'amount': amount,
              });
            }
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
