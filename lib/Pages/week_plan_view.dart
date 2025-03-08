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
import 'main_page.dart';

//Example-Code von: https://pub.dev/packages/time_planner/example

class WeekPlanView extends StatefulWidget {
  final String weekKey;

  const WeekPlanView({
    super.key,
    required this.weekKey,
  });

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<WeekPlanView> with RouteAware{
  DateTime calendarStart = DateTime(0);
  List<TimePlannerTitle> calendarHeaders = [];
  List<TimePlannerTask> tasks = [];
  bool updated = false;
  int rememberAnsweredTasks = 0;

  @override
  void initState() {
    setUpCalendar(widget.weekKey);
    super.initState();
  }

  ///Falls eine Benachrichtigung geöffnet wird, wenn man bereits auf der WeekPlanView-Seite ist, wird so beim zurückkehren die Seite geupdated
  @override
  Future<void> didPopNext() async {
    ///Checkt ob sich die Anzahl an beantworteten Tasks verändert hat und wenn ja updated den Kalender
    int c = await DatabaseHelper().getWeekTermineCountAnswered(widget.weekKey, true);
    if(rememberAnsweredTasks != c){
      print("Diffrent: $rememberAnsweredTasks | $c");
      updated = true;
      setState(() {
        tasks.clear();
        rememberAnsweredTasks = 0;
        setUpCalendar(widget.weekKey);
      });
    }
  }

  @override
  void didChangeDependencies() {
    if (ModalRoute.of(context)?.isCurrent == true) {
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
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
     List<String> foundOvrelaps = [];
    for(Termin t in weekAppointments){
       String title = t.terminName;
       DateTime startTime = t.timeBegin;
       DateTime endTime = t.timeEnd;
       Color? color = t.answered ? Colors.lightGreen : Colors.white60; //Purple nur übergangsweise, bis ich mich für style entschieden habe und Termin braucht einen weiteren zustand, wenn etwas schon passiert ist, aber nicht beantwortet wurde
       if(!t.answered && DateTime.now().isAfter(endTime)){
         color = Colors.grey;
       }
       int overlapPos = 0;
       ///Checkt nach Überschneidungen und macht den überlappenden Termin zu ca 25% Transparent
       if(foundOvrelaps.contains(t.terminName)){
         //color = color.withAlpha(60);
         //TODO: was wenn sich mehr als 2 Überschneiden?
         //print(foundOvrelaps);
         //overlapPos = 1;
         //for(String s in foundOvrelaps){
         //  if(s == t.terminName){
         //    overlapPos++;
         //  }
         //}
         overlapPos = 2;
       } else {
         DateTimeRange range = DateTimeRange(start: t.timeBegin, end: t.timeEnd);
         for (Termin t2 in weekAppointments) {
           DateTimeRange rangeCompare = DateTimeRange(start: t2.timeBegin, end: t2.timeEnd);

           // Check if the ranges overlap
           bool overlaps = range.start.isBefore(rangeCompare.end) && range.end.isAfter(rangeCompare.start);

           if (overlaps && t2.terminName != t.terminName && !foundOvrelaps.contains(t2.terminName)&& !foundOvrelaps.contains(t.terminName)) {
             foundOvrelaps.add(t2.terminName);
             foundOvrelaps.add(t.terminName);
             overlapPos = 1;
            // color = Colors.grey.shade600;

           }
         }
       }

       _addObject(title, startTime, endTime, color, overlapPos);
     }
  }

  void clickOnCalendarHeader(String dateString){
    String weekDayKey = dateString;
    navigatorKey.currentState?.push(MaterialPageRoute(
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
  void _addObject(String title, DateTime startTime, DateTime endTime, Color? color, int numberofOverlaps) { //
    Map<String, int> convertedDate = convertToCalendarFormat(calendarStart, startTime);
    int day = convertedDate["Days"]!;
    int hour = convertedDate["Hours"]!;
    int minutes = convertedDate["Minutes"]!;
    int duration = endTime.difference(startTime).inMinutes;
    rememberAnsweredTasks += 1; //Merkt sich, wieviele Taks geantwortet wurden

    setState(() {
      tasks.add(
        TimePlannerTask(
          color: color,
          dateTime: TimePlannerDateTime(
              day: day,
              hour: hour,
              minutes: minutes),
          minutesDuration: duration,
          numOfOverlaps: numberofOverlaps,
          daysDuration: 1,
          child:
          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (event) async {
                Offset pos = event.globalPosition;
                final result = await navigatorKey.currentState?.push(
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
                  updated = true;
                  updateCalendar();
                }
              },
              child: Stack( //Uhrzeit und Text könnten bei zu kurzen Terminen überlappen
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                      top: -6,
                      right: -3,
                      child: Icon(color == Colors.grey ? Icons.priority_high : null)
                  ),
                  ///Start and Endzeit, beide, damit falls sich einträge Überlappen, sie auseinandergehalten werden können
                  Positioned(
                      top: 1,
                      left: 5,
                      child: Text(DateFormat("HH:mm").format(startTime), style: TextStyle(fontWeight: FontWeight.w200, color: Colors.black87, fontStyle: FontStyle.italic, fontSize: duration < 46 ? 4 : 6),), //Ursprünglich 7 : 9
                  ),
                  Positioned(
                    bottom: 1,
                    left: 5,
                    child: Text(DateFormat("HH:mm").format(endTime), style: TextStyle(fontWeight: FontWeight.w200, color: Colors.black87, fontStyle: FontStyle.italic,  fontSize: duration < 46 ? 4 : 6),), //${DateFormat("HH:mm").format(startTime)} -
                  ),
                  //Positioned(
                  //  top: 2,
                  //    left: 1,
                  //    right: 1,
                  //    bottom: 20,
                  //    child: Center(
                  //        child: Text(
                  //          title,
                  //          style: TextStyle(
                  //            fontSize: 11,
                  //            color: Colors.black,
                  //          ),
                  //          textAlign: TextAlign.center,
                  //          maxLines: 2,
                  //          overflow: TextOverflow.ellipsis,
                  //        )
                  //    )
                  //),
                  // Stroked text as border.
                  Container(
                    decoration:BoxDecoration(
                      color: Colors.transparent
                    ),
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 10, right: 10, bottom: duration < 46 ? 5: 10, top: duration < 46 ? 5: 10), //Ursprünglich 8 : 12
                      child: ConstrainedBox(
                        constraints: BoxConstraints.expand(),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 10, //Ursprünglich 11
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                  )
                      /*FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          wrapTitle(title),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )*/
                ],
              )
          ),
        )
      );
    });
  }

  ///Wraped den Text manuel, da mit Constrains, Positioned, etc. immer Text horizontal abgeschnitten wurde
  String wrapTitle(String text) {
    String correctedText = text;
    if (text.length > 9) { //9 wirkte wie guter Wert
      List<String> words = text.split(" ");
      if (words.length > 2) {
        if (words[0].length + words[1].length >= 9) {
          correctedText = "${words[0]} ${words[1]}\n${words[2]}";
        } else {
          correctedText = "${words[0]}\n${words.sublist(1).join(" ")}";
        }
      } else if (words.length == 2) {
        correctedText = "${words[0]}\n${words[1]}";
      }
    }
    return correctedText;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, result) {
          if (!didPop) {
            String updateMainPage = updated ? "updated" : "";
            navigatorKey.currentState?.pop(updateMainPage);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: FittedBox(
              child: Text(Utilities().convertWeekkeyToDisplayPeriodString(widget.weekKey)),
            ),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  String updateMainPage = updated ? "updated" : "";
                  navigatorKey.currentState?.pop(updateMainPage);
                },
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
              navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (context) =>
                    WeekOverview(
                      weekKey: widget.weekKey,
                      fromNotification: false,),
              ));
            },
            child: const Icon(Icons.summarize_rounded),
          ),
        )
    );

      ;
  }
}