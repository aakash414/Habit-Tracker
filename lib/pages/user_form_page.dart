import 'package:flutter/material.dart';
import 'package:habittrackertute/pages/login_page.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import './home_page.dart';
import 'package:flutter_animate/flutter_animate.dart'; // For animations

class UserDataForm extends StatefulWidget {
  const UserDataForm({super.key});

  @override
  _UserDataFormState createState() => _UserDataFormState();
}

class _UserDataFormState extends State<UserDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _dailyFoodBudgetController = TextEditingController();
  final _goalWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUserData();
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

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _nationalityController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _dailyFoodBudgetController.dispose();
    _goalWeightController.dispose();
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  labelText: 'Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _ageController,
                  labelText: 'Age',
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _nationalityController,
                  labelText: 'Nationality',
                  icon: Icons.flag,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your nationality';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _weightController,
                  labelText: 'Weight',
                  icon: Icons.line_weight,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _heightController,
                  labelText: 'Height',
                  icon: Icons.height,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _dailyFoodBudgetController,
                  labelText: 'Daily Food Budget',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your daily food budget';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _goalWeightController,
                  labelText: 'Goal Weight',
                  icon: Icons.track_changes,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your goal weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _saveUserData(context),
                  child: const Text('Save Data'),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slide(begin: const Offset(0, 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
      )
          .animate()
          .fadeIn(delay: 200.ms, duration: 400.ms)
          .slide(begin: const Offset(0, 0.5)),
    );
  }

  Future<void> _saveUserData(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final userData = UserData(
        _nameController.text,
        int.parse(_ageController.text),
        _nationalityController.text,
        double.parse(_weightController.text),
        double.parse(_heightController.text),
        double.parse(_dailyFoodBudgetController.text),
        double.parse(_goalWeightController.text),
      );

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
            builder: (context) => const LoginPage(),
          ),
        );
      }
    }
  }
}
