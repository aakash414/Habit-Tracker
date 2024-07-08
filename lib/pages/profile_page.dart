import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import 'package:flutter_animate/flutter_animate.dart'; // For animations

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _dailyFoodBudgetController = TextEditingController();
  final _goalWeightController = TextEditingController();

  UserData? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final box = await Hive.openBox<UserData>('userDataBox');
    setState(() {
      _userData = box.get('user');
      if (_userData != null) {
        _nameController.text = _userData!.name;
        _ageController.text = _userData!.age.toString();
        _nationalityController.text = _userData!.nationality;
        _weightController.text = _userData!.weight.toString();
        _heightController.text = _userData!.height.toString();
        _dailyFoodBudgetController.text = _userData!.dailyFoodBudget.toString();
        _goalWeightController.text = _userData!.goalWeight.toString();
      }
    });
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

      final box = await Hive.openBox<UserData>('userDataBox');
      await box.put('user', userData);

      // Show success message or navigate to another page
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data saved successfully')),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('../../assets/image.jpg'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Edit your information below',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
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
      ),
    );
  }
}
