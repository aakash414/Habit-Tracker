import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showLogin = false; // Track whether to show login form

  Future<void> _signUpWithEmailAndPassword() async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Navigate to the login page upon successful sign up
      if (userCredential.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Handle sign up errors here
        print('Failed to sign up with email and password: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign Up Error'),
            content: const Text('Failed to sign up with email and password.'),
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
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showLogin ? _buildLoginForm() : _buildSignUpForm(),
      ),
    );
  }

  Widget _buildSignUpForm() {
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
          onPressed: _signUpWithEmailAndPassword,
          child: const Text('Sign Up'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _toggleForm,
          child: const Text('Already have an account? Login'),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return const LoginPage(); // Replace with your login form widget
  }
}
