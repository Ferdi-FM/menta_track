import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/week_overview.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/Pages/question_page.dart';
import 'package:menta_track/termin.dart';
import 'package:time_planner/time_planner.dart';
import '../generated/l10n.dart';
import '../main.dart';
import 'day_overview.dart';

//Example-Code von: https://pub.dev/packages/time_planner/example

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
    setUpCalendar(widget.weekKey);
    super.initState();

  }

  void setUpCalendar(String weekKey) async{
    DatabaseHelper databaseHelper = DatabaseHelper();
    calendarStart = DateTime.parse(weekKey);
    calendarHeaders = [];

    for(int i = 0; i < 7;i++){
      DateTime date = calendarStart.add(Duration(days: i));
      String displayDate = DateFormat("dd.MM.yy").format(date);
      String weekDay = getWeekdayName(date);
      calendarHeaders.add(
          TimePlannerTitle(
              title: weekDay,
              date: displayDate, //Wichtig fürs öffnen des dayOverview
              displayDate: S.current.displayADate(date),
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
    print(S.current.monday);
    List<String> weekdays = [
      S.current.monday,
      S.current.tuesday,
      S.current.wednesday,
      S.current.thursday,
      S.current.friday,
      S.current.saturday,
      S.current.sunday
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
          child:
          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (event) async {
                Offset pos = event.globalPosition;
                final result = await MyApp.navigatorKey.currentState?.push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => QuestionPage(
                          weekKey: widget.weekKey,
                          timeBegin: startTime.toIso8601String(),
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
                        );},
                    )
                );
                if(result != null){
                  updateCalendar();
                }
              },
              child: Stack( //Uhrzeit und Text könnten bei zu kurzen Terminen überlappen
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                      top: -6,
                      right: -5,
                      child: Icon(color == Colors.grey ? Icons.priority_high : null)
                  ),
                  Positioned(
                      bottom: 2,
                      left: 5,
                      child: Text(DateFormat("HH:mm").format(startTime), style: TextStyle(fontWeight: FontWeight.w200, color: Colors.black87, fontStyle: FontStyle.italic, fontSize: 10),) //TODO: Farbe und Italic? 
                  ),
                  // Stroked text as border.
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 12, right: 12, bottom: 20, top: 3),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                        //Text( //Weißer Text mit schwarzer Umrandung ist tendenziell auf jeder Farbe lesbar, gerade aber schwarz
                        //  title,
                        //  style: TextStyle(
                        //    fontSize: 11,
                        //    foreground: Paint()
                        //      ..style = PaintingStyle.stroke
                        //      ..strokeWidth = 0
                        //      ..color = Colors.black,
                        //  ),
                        //  textAlign: TextAlign.center,
                        //  maxLines: 2,
                        //  overflow: TextOverflow.ellipsis,
                        //),

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
        title: FittedBox(
          child: Text(Utilities().convertWeekkeyToDisplayPeriodString(widget.weekKey)),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: Icon(Icons.arrow_back)),
        actions: [
          Utilities().getHelpBurgerMenu(context, "WeekPlanView")
        ],
        ),
      body: LayoutBuilder(builder: (context, constraints){
          bool isPortrait = constraints.maxWidth < 600;
          return Container(
            decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                  color: Theme.of(context).scaffoldBackgroundColor
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0),
                child: TimePlanner( //evtl auf 24/7 ändern
                  startHour: 0,
                  endHour: 23,
                  use24HourFormat: true,
                  setTimeOnAxis: true,
                  currentTimeAnimation: true,
                  style: TimePlannerStyle(
                    cellHeight: 50,
                    cellWidth:  isPortrait ? 115 : ((MediaQuery.of(context).size.width - 60)/7).toInt(), //leider nur wenn neu gebuildet wird
                    showScrollBar: true,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    interstitialEvenColor: MyApp.of(context).themeMode == ThemeMode.light ? Colors.grey[50] : Colors.blueGrey.shade400,
                    interstitialOddColor: MyApp.of(context).themeMode == ThemeMode.light ? Colors.grey[200] : Colors.blueGrey.shade500,
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
                    weekKey: widget.weekKey,
                    fromNotification: false,),
          ));
        },
        child: const Icon(Icons.summarize_rounded),
      ),
    );
  }
}