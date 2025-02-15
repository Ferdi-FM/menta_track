import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/week_overview.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/Pages/question_page.dart';
import 'package:menta_track/termin.dart';
import 'package:time_planner/time_planner.dart';

import '../main.dart';
import 'day_overview.dart';

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

class MyHomePageState extends State<WeekPlanView>{
  DateTime calendarStart = DateTime(0);
  List<TimePlannerTitle> calendarHeaders = [];
  List<TimePlannerTask> tasks = [];

  @override
  void initState() {
    super.initState();
    setUpCalendar(widget.weekKey);
    print(MyApp.of(context).themeMode);
  }

  void setUpCalendar(String weekKey) async{
    DatabaseHelper databaseHelper = DatabaseHelper();
    calendarStart = DateTime.parse(weekKey);
    calendarHeaders = [];

    DateFormat format = DateFormat("dd.MM.yy");

    for(int i = 0; i < 7;i++){
      DateTime date = calendarStart.add(Duration(days: i));
      String displayDate = format.format(date);
      String weekDay = getWeekdayName(date);
      calendarHeaders.add(
          TimePlannerTitle(
              title: weekDay,
              date: displayDate,
              voidAction: clickOnCalendarHeader,
          ));
    }

     List<Termin> weekAppointments = await databaseHelper.getWeeklyPlan(widget.weekKey); //await muss nach den erstellen der CalendarHeader passieren
     for(Termin t in weekAppointments){
       String title = t.terminName;
       DateTime startTime = t.timeBegin;
       DateTime endTime = t.timeEnd;
       Color? color = t.answered ? Colors.lightGreen : Colors.white60; //Purple nur übergangsweise, bis ich mich für style entschieden habe und Termin braucht einen weiteren zustand, wenn etwas schon passiert ist, aber nicht beantwortet wurde
       if(!t.answered && DateTime.now().isAfter(endTime)){
         color = Colors.grey;
       }

       _addObject(title, startTime, endTime, color);
     }
  }

  void clickOnCalendarHeader(String dateString){
    print(dateString);
    String weekDayKey = dateString;
    MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => DayOverviewPage(
        weekKey: widget.weekKey,
        weekDayKey: weekDayKey,
        fromNotification: false
      ),
    ));
  }

  void updateCalendar() {
    setState(() {
      tasks.clear();
    });
    setUpCalendar(widget.weekKey);
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
      "Days": days,
      "Hours": hours,
      "Minutes": minutes,
    };
  }

  //erzeugt Event im Kalender
  void _addObject(String title, DateTime startTime, DateTime endTime, Color? color) { //
    Map<String, int> convertedDate = convertToCalendarFormat(calendarStart, startTime);
    int day = convertedDate["Days"]!;
    int hour = convertedDate["Hours"]!;
    int minutes = convertedDate["Minutes"]!;
    int duration = endTime.difference(startTime).inMinutes;

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
            //Weißer Text mit schwarzer umrandung ist tendenziell auf jeder Farbe lesbar
          child:
          GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (event) async {
                  // print("WeekKey: ${widget.weekKey} \n timeBegin: ${startTime.toString()} \n terminName: $title");
                  Offset pos = event.globalPosition;
                  final result = await MyApp.navigatorKey.currentState?.push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => QuestionPage(
                            weekKey: widget.weekKey,
                            timeBegin: startTime.toString(),
                            terminName: title),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const curve = Curves.easeInOut;

                          // Erstelle eine Skalierungs-Animation
                          var tween = Tween<double>(begin: 0.1, end: 1.0).chain(CurveTween(curve: curve));
                          var scaleAnimation = animation.drive(tween);

                          return ScaleTransition(
                            scale: scaleAnimation,
                            alignment: Alignment(pos.dx / MediaQuery.of(context).size.width * 2 - 1,
                                pos.dy / MediaQuery.of(context).size.height * 2 - 1), // Die Tap-Position relativ zur Bildschirmgröße
                            child: child,
                          );
                        },
                      )
                  );
                  if(result != null){
                    print(result.toString());
                    updateCalendar();
                  } else {
                    print("no data");
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      //decoration: BoxDecoration(
                      //  border: Border.all(
                      //    width: 1,
                      //  ),
                      //  borderRadius: BorderRadius.circular(12),
                      //),
                        padding: EdgeInsets.all(2),
                        alignment: Alignment.topRight,
                        child: Icon(color == Colors.grey ? Icons.priority_high : null) //TODO: unabhöngig von Farbe machen
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
                                ..strokeWidth = 0
                                ..color = Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Solid text as fill.
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ),
          )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Utilities().convertWeekkeyToDisplayPeriodString(widget.weekKey)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: Icon(Icons.arrow_back)),
        ),
      body: OrientationBuilder(builder: (context, orientation){
          return Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                  color: Theme.of(context).scaffoldBackgroundColor
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0),
                child: TimePlanner(
                  startHour: 6,
                  endHour: 23,
                  use24HourFormat: true,
                  setTimeOnAxis: true,
                  currentTimeAnimation: true,
                  style: TimePlannerStyle( //Needs to be adjusted
                    cellHeight: 50,
                    cellWidth:  orientation == Orientation.portrait ? 115 : 120, //leider nur wenn neu gebuildet wird
                    showScrollBar: true,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    interstitialEvenColor: MyApp.of(context).themeMode == ThemeMode.light ? Colors.grey[50] : Colors.blueGrey.shade400,
                    interstitialOddColor: MyApp.of(context).themeMode == ThemeMode.light ? Colors.grey[200] : Colors.blueGrey.shade500,
                    //backgroundColor: Theme.of(context).scaffoldBackgroundColor
                  ),
                  headers: calendarHeaders,
                  tasks: tasks,
                ),
              ),
            ),
          );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) =>
                WeekOverview(
                    weekKey: widget.weekKey),
          ));
        },//print("Könnte zusammenfassung zeigen"),
        tooltip: "Zeig Zusammenfassung",
        child: const Icon(Icons.summarize_rounded),
      ),
    );
  }
}