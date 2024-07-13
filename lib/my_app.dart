import 'package:flutter/material.dart';
import 'home_page.dart';

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
