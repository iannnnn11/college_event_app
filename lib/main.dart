import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Futuristic Event Manager',
      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: isDark ? Colors.black : Colors.grey[100],
        textTheme: TextTheme(
          headline6: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isDark ? Colors.pinkAccent : Colors.deepPurple),
          bodyText2: TextStyle(
              fontSize: 16, color: isDark ? Colors.white : Colors.black),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: isDark ? Colors.pinkAccent : Colors.deepPurple,
        ),
      ),
      home: LoginPage(
        toggleTheme: () {
          setState(() => isDark = !isDark);
        },
      ),
    );
  }
}
