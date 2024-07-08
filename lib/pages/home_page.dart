import 'package:flutter/material.dart';
import 'package:habittrackertute/components/habit_tile.dart';
import 'package:habittrackertute/components/month_summary.dart';
import 'package:habittrackertute/components/my_fab.dart';
import 'package:habittrackertute/components/my_alert_box.dart';
import 'package:habittrackertute/data/habit_database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'profile_page.dart'; // Import the ProfilePage

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box("Habit_Database");
  final TextEditingController _newHabitNameController = TextEditingController();
  final TextEditingController _newHabitCaloriesController =
      TextEditingController();
  final PageController _pageController = PageController();

  final List<String> mealLabels = ['Morning', 'Afternoon', 'Evening'];

  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    _initializeData().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  Future<void> _initializeData() async {
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      await db
          .createDefaultData(); // Replace with your async initialization logic
    } else {
      db.loadData();
      if (db.todaysHabitList.isEmpty) {
        db.todaysHabitList = [
          ['Breakfast', false, 0],
          ['Lunch', false, 0],
          ['Dinner', false, 0],
        ];
      }
    }
  }

  void checkBoxTapped(bool? value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value;
    });
    if (index == 2) {
      db.nextDay();
    }
    db.updateDatabase();
  }

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          hintText: 'Enter food name..',
          additionalController: _newHabitCaloriesController,
          additionalHintText: 'Enter calories..',
          onSave: saveNewHabit,
          onCancel: cancelDialogBox,
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 500.ms)
            .slide(begin: const Offset(0, 0.5));
      },
    );
  }

  void saveNewHabit() {
    setState(() {
      db.todaysHabitList.add([
        _newHabitNameController.text,
        false,
        int.tryParse(_newHabitCaloriesController.text) ?? 0
      ]);
    });
    _newHabitNameController.clear();
    _newHabitCaloriesController.clear();
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  void cancelDialogBox() {
    _newHabitNameController.clear();
    _newHabitCaloriesController.clear();
    Navigator.of(context).pop();
  }

  void openHabitSettings(int index) {
    _newHabitNameController.text = db.todaysHabitList[index][0];
    _newHabitCaloriesController.text = db.todaysHabitList[index][2].toString();
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          hintText: 'Enter food name..',
          additionalController: _newHabitCaloriesController,
          additionalHintText: 'Enter calories..',
          onSave: () => saveExistingHabit(index),
          onCancel: cancelDialogBox,
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 500.ms)
            .slide(begin: const Offset(0, 0.5));
      },
    );
  }

  void saveExistingHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
      db.todaysHabitList[index][2] =
          int.tryParse(_newHabitCaloriesController.text) ?? 0;
    });
    _newHabitNameController.clear();
    _newHabitCaloriesController.clear();
    Navigator.pop(context);
    db.updateDatabase();
  }

  void deleteHabit(int index) {
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Savvy Diet'),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: MyFloatingActionButton(onPressed: createNewHabit)
          .animate()
          .fadeIn(delay: 300.ms, duration: 500.ms)
          .slide(begin: const Offset(0, 0.5)),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  MonthlySummary(
                    datasets: db.heatMapDataSet,
                    startDate: _myBox.get("START_DATE"),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slide(begin: const Offset(0, 0.5)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: db.todaysHabitList.length,
                      itemBuilder: (context, index) {
                        String label = mealLabels[index];
                        String habitName = db.todaysHabitList[index][0];
                        dynamic calories = db.todaysHabitList[index][2];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 8.0),
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: HabitTile(
                                habitName: '$habitName ($calories cal)',
                                habitCompleted: db.todaysHabitList[index][1],
                                onChanged: (value) =>
                                    checkBoxTapped(value, index),
                                settingsTapped: (context) =>
                                    openHabitSettings(index),
                                deleteTapped: (context) => deleteHabit(index),
                              )
                                  .animate()
                                  .fadeIn(
                                    delay: (index * 100).ms,
                                    duration: 400.ms,
                                  )
                                  .slide(
                                    begin: const Offset(0, 0.5),
                                  ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MyAlertBox extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController additionalController;
  final String hintText;
  final String additionalHintText;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const MyAlertBox({
    required this.controller,
    required this.additionalController,
    required this.hintText,
    required this.additionalHintText,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hintText),
          ),
          TextField(
            controller: additionalController,
            decoration: InputDecoration(hintText: additionalHintText),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
