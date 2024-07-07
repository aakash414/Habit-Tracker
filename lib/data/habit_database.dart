import 'package:habittrackertute/datetime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

const apiKey = "AIzaSyCGd4B8sVsrRVEpQa6UnK5TYqsbZhg13Gw";

// reference our box
final _myBox = Hive.box("Habit_Database");

class HabitDatabase {
  dynamic allHabitsList = [];
  List todaysHabitList = [];
  dynamic day = 0;
  Map<DateTime, int> heatMapDataSet = {};

  // create initial default data
  void createDefaultData() async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
    const prompt =
        'I know you are not a diet planning API, but please generate a JSON response for my requirements. Here are some details of the user: Current weight: 71kg Height: 171cm goal weight: 80kg age: 21 Daily budget: 500 INR Naitonality: Indian Generate a diet plan consisting of breakfast, lunch and dinner for 7 days. Generate a response in this format: [ [ { "day": 1, "type": "breakfast", "food": "Idli vada sambar" }, { "day": 2, "type": "lunch", "food": "Rice sambaar" }, { "day": 2, "type": "dinner", "food": "chapaati daal" } ], // day 2 array consisting of breakfast, lunch and dinner [ .... ]. Dont give me any additional information, just the json response with a ```json in the start and ``` in the end';
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

        for (var day in allHabitsList) {
          for (var meal in day) {
            meal["done"] = false;
          }
        }

        todaysHabitList = [
          [allHabitsList[0][0]['food'], false],
          [allHabitsList[0][1]['food'], false],
          [allHabitsList[0][2]['food'], false],
        ];

        // You can parse the jsonString using jsonDecode as explained before.
      } else {
        // Handle the case where the JSON code block is not found
        print('Error: JSON code block not found in response');
      }
    }

    // todaysHabitList = [
    //   ["Run", false],
    //   ["Read", false],
    // ];

    _myBox.put("START_DATE", todaysDateFormatted());

    updateDatabase();
  }

  // load data if it already exists
  void loadData() {
    // if it's a new day, get habit list from database
    if (_myBox.get(todaysDateFormatted()) == null) {
      todaysHabitList = _myBox.get("CURRENT_HABIT_LIST");
      // set all habit completed to false since it's a new day
      for (int i = 0; i < todaysHabitList.length; i++) {
        todaysHabitList[i][1] = false;
      }
    }
    // if it's not a new day, load todays list
    else {
      todaysHabitList = _myBox.get(todaysDateFormatted());
    }

    updateDatabase();
  }

  void nextDay() {
    // if it's the last day of the week, go back to the first day
    if (day == 6) {
      day = 0;
    } else {
      day++;
    }

    todaysHabitList = [
      [allHabitsList[day][0]['food'], allHabitsList[day][0]['done']],
      [allHabitsList[day][1]['food'], allHabitsList[day][1]['done']],
      [allHabitsList[day][2]['food'], allHabitsList[day][2]['done']],
    ];
  }

  // update database
  void updateDatabase() {
    // update todays entry
    _myBox.put(todaysDateFormatted(), todaysHabitList);

    // update universal habit list in case it changed (new habit, edit habit, delete habit)
    _myBox.put("CURRENT_HABIT_LIST", todaysHabitList);

    print(todaysHabitList);

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
    int daysInBetween = DateTime.now().difference(startDate).inDays;

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
