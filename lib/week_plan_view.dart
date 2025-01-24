import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/question_page.dart';
import 'package:menta_track/termin.dart';
import 'package:time_planner/time_planner.dart';

import 'main.dart';

//Used Example-Code von: https://pub.dev/packages/time_planner/example as Reference

class WeekPlanView extends StatefulWidget {
  const WeekPlanView({
    super.key,
    required this.weekKey,
  });

  final String weekKey;

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

    setUpCalendar(widget.weekKey);
  }

  void setUpCalendar(String weekKey) async{
    DatabaseHelper databaseHelper = DatabaseHelper();
    calendarStart = DateTime.parse(weekKey);
    calendarHeaders = [];

    DateFormat format = DateFormat("dd.MM.yyyy");

    for(int i = 0; i < 7;i++){
      DateTime date = calendarStart.add(Duration(days: i));
      String displayDate = format.format(date);
      String weekDay = getWeekdayName(date);
      calendarHeaders.add(TimePlannerTitle(title: weekDay, date: displayDate));
    }

     List<Termin> weekAppointments = await databaseHelper.getWeeklyPlan(widget.weekKey); //await muss nach den erstellen der CalendarHeader passieren
     for(Termin t in weekAppointments){
       String title = t.terminName;
       DateTime startTime = t.timeBegin;
       DateTime endTime = t.timeEnd;
       Color? color = t.answered ? Colors.green : Colors.purple; //Purple nur übergangsweise, bis ich mich für style entschieden habe und Termin braucht einen weiteren zustand, wenn etwas schon passiert ist, aber nicht beantwortet wurde

       if(!t.answered && DateTime.now().isAfter(endTime)){
         color = Colors.orange;
       }

       _addObject(title, startTime, endTime, color);
     }
  }

  //Nicht Async Methode wegen context
  //void _notAsyncAddObject(String title, DateTime startTime, DateTime endTime, Color? color){
  //  _addObject(context, title, startTime, endTime, color);
  //}

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
  void _addObject(String title, DateTime startTime, DateTime endTime, Color? color) { //
    Map<String, int> convertedDate = convertToCalendarFormat(calendarStart, startTime);
    int day = convertedDate["Days"]!;
    int hour = convertedDate["Hours"]!;
    int minutes = convertedDate["Minutes"]!;
    int duration = endTime.difference(startTime).inMinutes;
    bool canAnswerTermin = false;
    if(color == Colors.orange){ //Könnte auch  if(!t.answered && DateTime.now().isAfter(endTime)) hernehmen, müsste aber t.answered übergeben
      canAnswerTermin = true;
    }

    setState(() {
      tasks.add(
        TimePlannerTask(
          color: color,
          dateTime: TimePlannerDateTime(
              day: day,
              hour: hour,
              minutes: minutes),
          minutesDuration: duration,
          daysDuration: 1,
          onTap: () {
            //print("WeekKey: ${widget.weekKey} \n timeBegin: ${startTime.toString()} \n terminName: $title");
            MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (context) => QuestionPage(
                  weekKey: widget.weekKey,
                  timeBegin: startTime.toString(),
                  terminName: title,
                  isEditable: canAnswerTermin),
            ));
            ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                content: Text(startTime.toString())),
            );
          },
            //Weißer Text mit schwarzer umrandung ist tendenziell auf jeder Farbe lesbar
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(2),
                alignment: Alignment.topRight,
                child: Icon(canAnswerTermin ? Icons.priority_high : null)
              ),
              // Stroked text as border.
              Container(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = Colors.black,
                      ),
                    ),
                    // Solid text as fill.
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          )
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Utilities().convertWeekkeyToDisplayPeriodString(widget.weekKey)),//Sehr unelegant
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
          currentTimeAnimation: true,
          style: TimePlannerStyle( //Needs to be adjusted
            cellHeight: 50,
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
        onPressed: () {},//print("Könnte zusammenfassung zeigen"),
        tooltip: 'Zeig Zusammenfassung',
        child: const Icon(Icons.summarize_rounded),
      ),
    );
  }
}