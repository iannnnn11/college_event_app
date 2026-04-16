import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'student_home.dart';
import 'admin_home.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Event App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:const SplashScreen(),
    );
  }
}

// RootPage to check if user is already logged in
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in → go to login
      return const LoginPage();
    } else {
      // Logged in → check role
      // Example: if email is admin, go to AdminHome
      if (user.email == 'admin@college.com') {
        return const AdminHome();
      } else {
        return const StudentHome();
      }
    }
  }
}
