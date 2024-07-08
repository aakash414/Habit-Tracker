import 'package:habittrackertute/datetime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../models/user.dart';

const apiKey = "AIzaSyCGd4B8sVsrRVEpQa6UnK5TYqsbZhg13Gw";

// reference our box
final _myBox = Hive.box("Habit_Database");

final _userDataBox = Hive.box<UserData>("userDataBox");

class HabitDatabase {
  dynamic allHabitsList = [];
  List todaysHabitList = [];
  int day = 0;
  Map<DateTime, int> heatMapDataSet = {};

  // create initial default data
  Future<void> createDefaultData() async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    final userData = Hive.box<UserData>('userDataBox').get('user');

    if (userData != null) {
      final prompt =
          'I know you are not a diet planning API, but please generate a JSON response for my requirements. '
          'Here are some details of the user: Current weight: ${userData.weight}kg '
          'Height: ${userData.height}cm goal weight: ${userData.goalWeight}kg '
          'age: ${userData.age} Daily budget: ${userData.dailyFoodBudget} ${userData.nationality} currency'
          'Nationality: ${userData.nationality} Generate a diet plan consisting of breakfast, '
          'lunch and dinner for 7 days. '
          'Generate a response in this format: '
          '[ [ { "day": 1, "type": "breakfast", "food": "some typical ${userData.nationality} breakfast", "calories": total calories }, '
          '{ "day": 1, "type": "lunch", "food": "some typical ${userData.nationality} lunch", "calories": total calories }, '
          '{ "day": 1, "type": "dinner", "food": "some typical ${userData.nationality} dinner", "calories": total calories } ], '
          '// day 2 array consisting of breakfast, lunch and dinner [ .... ]. '
          'Dont give me any additional information, just the json response '
          'with a ```json in the start and ``` in the end';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      String? responseText = response.text;

      if (responseText != null) {
        // Find the starting position of the JSON code block
        int startIndex = responseText.indexOf('```json');

        // Check if the JSON code block is found
        if (startIndex != -1) {
          // Find the ending position of the JSON code block
          int endIndex = responseText.indexOf('```', startIndex + 7);

          // Extract the JSON substring
          String jsonString = responseText.substring(startIndex + 7, endIndex);

          allHabitsList = jsonDecode(jsonString);

          print(allHabitsList);

          for (var day in allHabitsList) {
            for (var meal in day) {
              meal["done"] = false;
            }
          }

          todaysHabitList = [
            [
              allHabitsList[0][0]['food'],
              false,
              allHabitsList[0][0]['calories']
            ],
            [
              allHabitsList[0][1]['food'],
              false,
              allHabitsList[0][1]['calories']
            ],
            [
              allHabitsList[0][2]['food'],
              false,
              allHabitsList[0][2]['calories']
            ],
          ];

          // You can parse the jsonString using jsonDecode as explained before.
        } else {
          // Handle the case where the JSON code block is not found
          print('Error: JSON code block not found in response');
        }
      }

      _myBox.put("START_DATE", todaysDateFormatted());

      updateDatabase();
    }
  }

  // load data if it already exists
  void loadData() {
    // getUserData();
    // if it's a new day, get habit list from database
    if (_myBox.get(todaysDateFormatted()) == null) {
      todaysHabitList = _myBox.get("CURRENT_HABIT_LIST");
      allHabitsList = _myBox.get("ALL_HABITS_LIST");
      // set all habit completed to false since it's a new day
      for (int i = 0; i < todaysHabitList.length; i++) {
        todaysHabitList[i][1] = false;
      }
    }
    // if it's not a new day, load todays list
    else {
      todaysHabitList = _myBox.get(todaysDateFormatted());
      allHabitsList = _myBox.get("ALL_HABITS_LIST");
    }

    updateDatabase();
  }

  Future<UserData?> getUserData() async {
    if (Hive.box('userDataBox').isOpen == false) {
      await Hive.openBox('userDataBox');
    }
    // Try to get the user data from the box
    print(_userDataBox.get('user'));

    return _userDataBox.get('user');
  }

  void nextDay() {
    // if it's the last day of the week, go back to the first day
    print(allHabitsList);
    if (day >= 6) {
      day = 0;
    } else {
      day++;
      print(day);
    }

    todaysHabitList = [
      [allHabitsList[day][0]['food'], false, allHabitsList[day][0]['calories']],
      [allHabitsList[day][1]['food'], false, allHabitsList[day][1]['calories']],
      [allHabitsList[day][2]['food'], false, allHabitsList[day][2]['calories']],
    ];
  }

  // update database
  void updateDatabase() {
    // update todays entry
    _myBox.put(todaysDateFormatted(), todaysHabitList);

    // update universal habit list in case it changed (new habit, edit habit, delete habit)
    _myBox.put("CURRENT_HABIT_LIST", todaysHabitList);

    _myBox.put("ALL_HABITS_LIST", allHabitsList);

    print(allHabitsList);

    // calculate habit complete percentages for each day
    calculateHabitPercentages();

    // load heat map
    loadHeatMap();
  }

  void calculateHabitPercentages() {
    int countCompleted = 0;
    for (int i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i][1] == true) {
        countCompleted++;
      }
    }

    String percent = todaysHabitList.isEmpty
        ? '0.0'
        : (countCompleted / todaysHabitList.length).toStringAsFixed(1);

    // key: "PERCENTAGE_SUMMARY_yyyymmdd"
    // value: string of 1dp number between 0.0-1.0 inclusive
    _myBox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  }

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(_myBox.get("START_DATE"));

    // count the number of days to load
    int daysInBetween = DateTime.now().difference(startDate).inDays + day;

    // go from start date to today and add each percentage to the dataset
    // "PERCENTAGE_SUMMARY_yyyymmdd" will be the key in the database
    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        _myBox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      // split the datetime up like below so it doesn't worry about hours/mins/secs etc.

      // year
      int year = startDate.add(Duration(days: i)).year;

      // month
      int month = startDate.add(Duration(days: i)).month;

      // day
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
      print(heatMapDataSet);
    }
  }
}
