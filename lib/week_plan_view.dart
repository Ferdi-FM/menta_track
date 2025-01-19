import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/termin.dart';
import 'package:time_planner/time_planner.dart';

class WeekPlanView extends StatefulWidget {
  const WeekPlanView({
    super.key,
    required this.title,
    required this.termine,
    required this.weekKey,
  });

  final String title;
  final String weekKey;
  final List<Termin> termine;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<WeekPlanView> {
  DateTime calendarStart = DateTime(0);
  List<TimePlannerTitle> calendarHeaders = [];
  List<TimePlannerTask> tasks = [];

  @override
  void initState() {
    super.initState();
    setUpCalendar(widget.weekKey, widget.termine);
  }

  void setUpCalendar(String weekKey, List<Termin> termine){
      print(weekKey);
      calendarStart = DateTime.parse(weekKey);
      calendarHeaders = [];

      DateFormat format = DateFormat("dd.MM.yyyy");
      DateTime firstDateDateTime = calendarStart;

      for(int i = 0; i < 7;i++){
        DateTime date = firstDateDateTime.add(Duration(days: i));
        String displayDate = format.format(date);
        String weekDay = getWeekdayName(date);
        print("$weekDay der $displayDate");
        calendarHeaders.add(TimePlannerTitle(title: weekDay, date: displayDate));
      }

      for(Termin t in termine){
        String title = t.terminName;
        DateTime startTime = t.timeBegin;
        DateTime endTime = t.timeEnd;

        _addObject(context, title, startTime, endTime);
      }
  }

  String getWeekdayName(DateTime dateTime) {
    List<String> weekdays = [
      "Montag",
      "Dienstag",
      "Mittwoch",
      "Donnerstag",
      "Freitag",
      "Samstag",
      "Sonntag"
    ];
    return weekdays[dateTime.weekday - 1]; //-1 weil index bei 0 beginnt aber weekday bei 1 beginnt
  }

  //Konvertiert eine DateTime zu der vom package erwartetem Format (integer). errechnet differenz zwischen der 0ten Stunde am Kalender und dem Termin
  Map<String, int> convertToCalendarFormat(DateTime calendarStart, DateTime terminDate) {
    Duration difference = terminDate.difference(calendarStart);

    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;

    return {
      'Days': days,
      'Hours': hours,
      'Minutes': minutes,
    };
  }

  //erzeugt Event im Kalender
  void _addObject(BuildContext context, String title, DateTime startTime, DateTime endTime) { //
    List<Color?> colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.lime[600]
    ];

    Map<String, int> convertedDate = convertToCalendarFormat(calendarStart, startTime);
    int day = convertedDate["Days"]!;
    int hour = convertedDate["Hours"]!;
    int minutes = convertedDate["Minutes"]!;
    int duration = endTime.difference(startTime).inMinutes;

    setState(() {
      tasks.add(
        TimePlannerTask(
          color: colors[Random().nextInt(colors.length)],
          dateTime: TimePlannerDateTime(
              day: day,
              hour: hour,
              minutes: minutes),
          minutesDuration: duration,
          daysDuration: 1,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                content: Text(startTime.toString())),
            );
          },
          child: Text(
            title,
            style: TextStyle(color: Colors.grey[350], fontSize: 12,fontWeight: FontWeight.bold),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: Icon(Icons.arrow_back)),
        ),
      body: Center(
        child: TimePlanner(
          startHour: 6,
          endHour: 23,
          use24HourFormat: true,
          setTimeOnAxis: true,
          style: TimePlannerStyle( //Needs to be adjusted
            // cellHeight: 60,
            // cellWidth: 60,
            showScrollBar: true,
            interstitialEvenColor: Colors.grey[50],
            interstitialOddColor: Colors.grey[200],
          ),
          headers: calendarHeaders,
          tasks: tasks,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print("Could show a Summary of the week"),
        tooltip: 'Show Summary of Appointment',
        child: const Icon(Icons.summarize_rounded),
      ),
    );
  }
}