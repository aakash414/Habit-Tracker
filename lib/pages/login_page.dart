import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habittrackertute/pages/user_form_page.dart';
import './signup_page.dart'; // Import your sign-up page file
import './home_page.dart'; // Import your home page file
import './user_form_page.dart'; // Import your user form page file
import 'package:habittrackertute/pages/login_page.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../models/user.dart'; // For animations

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showSignUp = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkUserData();
    // _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    // Check Firebase Authentication status
    User? user = _auth.currentUser;

    if (user != null) {
      // User is logged in, navigate to appropriate page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  Future<void> _checkUserData() async {
    final box = await Hive.openBox<UserData>('userDataBox');
    final userData = box.get('user');

    if (userData != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Navigate to the next screen upon successful login
      if (userCredential.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const UserDataForm(),
          ),
        ); // Replace with your home screen route
      }
    } catch (e) {
      if (mounted) {
        // Handle login errors here
        print('Failed to sign in with email and password: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Error'),
            content: const Text('Failed to sign in with email and password.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  void _toggleForm() {
    setState(() {
      _showSignUp = !_showSignUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showSignUp ? _buildSignUpForm() : _buildLoginForm(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _signInWithEmailAndPassword,
          child: const Text('Login'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _toggleForm,
          child: const Text('Create an account'),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return const SignUpPage(); // Replace with your sign-up form widget
  }
}
