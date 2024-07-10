import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
        colorScheme: ColorScheme.light(
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

  // List of image paths for demo purposes
  List<String> imagePaths = [
    '../images/ilaw.jpg',
    '../images/images.jpg',
    '../images/jeep.jpg',
    '../images/w.jpg',
    // Add more image paths as needed
  ];

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _signingUp = false;
  bool _showPasswordError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Budget Buddy',
        ),
        backgroundColor: Colors.green[100],
        actions: [
          IconButton(
            onPressed: () {
              // Show sign-up dialog
              _showSignUpDialog(context);
            },
            icon: const Icon(
              Icons.person_add,
              color: Colors.black, // Set the color of the icon
            ),
          ),
        ],
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
                  Tab(icon: Icon(Icons.account_circle), text: 'Profile'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    HomeScreen(imagePaths: imagePaths, orientation: orientation),
                    ExpensesScreen(imagePaths: imagePaths),
                    ProfileScreen(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'BebasNeue', // Change to PlaywriteESDeco
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Add Expenses',
                style: TextStyle(fontFamily: 'BebasNeue'), // Change to PlaywriteESDeco
              ),
              leading: const Icon(Icons.add),
            ),
            ListTile(
              title: Text(
                'Monthly Expenses',
                style: TextStyle(fontFamily: 'BebasNeue'), // Change to PlaywriteESDeco
              ),
              leading: const Icon(Icons.calendar_today),
            ),
            ListTile(
              title: Text(
                'Summary Expenses',
                style: TextStyle(fontFamily: 'BebasNeue'), // Change to PlaywriteESDeco
              ),
              leading: const Icon(Icons.attach_money),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show the sign-up dialog
  void _showSignUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Sign Up',
                style: TextStyle(fontFamily: 'BebasNeue'), // Change to PlaywriteESDeco
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText:
                          _showPasswordError ? 'Please enter a valid email' : null,
                      labelStyle:
                          const TextStyle(fontFamily: 'BebasNeue'), // Change to PlaywriteESDeco
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText:
                          _showPasswordError ? 'Please enter a valid password' : null,
                      labelStyle:
                          const TextStyle(fontFamily: 'BebasNeue'), // Change to PlaywriteESDeco
                    ),
                  ),
                  const SizedBox(height: 20),
                  _signingUp
                      ? LinearProgressIndicator(
                          backgroundColor: Colors.green[100], // Background color
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.green),
                          // Progress color
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Close the dialog
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Validate inputs
                                String email =
                                    _emailController.text.trim();
                                String password =
                                    _passwordController.text.trim();

                                if (email.isEmpty || password.isEmpty) {
                                  setState(() {
                                    _showPasswordError = true;
                                  });
                                  return;
                                }

                                // Simulate sign-up process
                                setState(() {
                                  _signingUp = true; // Start signing up
                                  _showPasswordError = false;
                                });

                                Future.delayed(
                                    const Duration(seconds: 2), () {
                                  // Simulated sign-up success
                                  setState(() {
                                    _signingUp =
                                        false; // Finish signing up
                                  });
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                  _showSignUpSuccessDialog(
                                      context); // Show success dialog
                                });
                              },
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Method to show the sign-up success dialog
  void _showSignUpSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sign Up Successful',
            style: TextStyle(fontFamily: 'BebasNeue'), // Change to PlaywriteESDeco
          ),
          content: const Text('You have successfully signed up!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the success dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class HomeScreen extends StatelessWidget {
  final List<String> imagePaths;
  final Orientation? orientation;

  const HomeScreen({Key? key, required this.imagePaths, this.orientation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: imagePaths.map((path) {
          return Container(
            height: 200,
            margin: const EdgeInsets.only(right: 16),
            child: Image.asset(
              path,
              fit: BoxFit.contain,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ExpensesScreen extends StatelessWidget {
  final List<String> imagePaths;

  const ExpensesScreen({Key? key, required this.imagePaths}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: imagePaths.length,
      itemBuilder: (BuildContext context, int index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset(
            imagePaths[index],
            fit: BoxFit.cover,
          ),
        );
      },
      staggeredTileBuilder: (int index) => const StaggeredTile.fit(2),
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Profile Page',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'PlaywriteESDeco', // Change to PlaywriteESDeco
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      const MyHomePage(),
                  transitionsBuilder:
                      (context, animation1, animation2, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation1.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

class OrientationList extends StatelessWidget {
  final String title;
  const OrientationList({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.pink[400],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return GridView.count(
            // Grid with 3 and 4 columns for portrait and landscape mode respectively
            crossAxisCount: orientation == Orientation.portrait ? 3 : 4,
            // Random item generator
            children: List.generate(100, (index) {
              return Center(
                child: Text('A $index'),
              );
            }),
          );
        },
      ),
    );
  }
}
