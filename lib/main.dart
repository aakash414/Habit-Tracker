import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habittrackertute/pages/login_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user.dart';
import 'package:habittrackertute/data/habit_database.dart';
import 'package:hive/hive.dart';
import 'pages/user_form_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserDataAdapter());
  await Hive.openBox<UserData>('userDataBox');
  await Hive.openBox('Habit_Database');
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDqqBkMoEia_pMYA8eQBWuYFEurrWijvrc",
      appId: "1:962244329048:web:da89adc78c82dd1b2e542d",
      messagingSenderId: "962244329048",
      projectId: "dietplan-aa427",
    ),
  );
  // await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hive Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}
