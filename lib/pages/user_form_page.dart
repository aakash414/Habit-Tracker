import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import './home_page.dart';

class UserDataForm extends StatefulWidget {
  const UserDataForm({super.key});

  @override
  _UserDataFormState createState() => _UserDataFormState();
}

class _UserDataFormState extends State<UserDataForm> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _dailyFoodBudgetController = TextEditingController();
  final _goalWeightController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _nationalityController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _dailyFoodBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _nationalityController,
                decoration: const InputDecoration(labelText: 'Nationality'),
              ),
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _dailyFoodBudgetController,
                decoration:
                    const InputDecoration(labelText: 'Daily Food Budget'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _goalWeightController,
                decoration: const InputDecoration(labelText: 'Goal Weight'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () => saveUserData(context),
                child: const Text('Save Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveUserData(BuildContext context) async {
    final userData = UserData(
        _nameController.text,
        int.parse(_ageController.text),
        _nationalityController.text,
        double.parse(_weightController.text),
        double.parse(_heightController.text),
        double.parse(_dailyFoodBudgetController.text),
        double.parse(_goalWeightController.text));

    final box = Hive.box<UserData>('userDataBox');
    await box.put('user', userData);

    // Show success message or navigate to another page
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data saved successfully')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(), // Use captured context
        ),
      );
    }
  }
}
