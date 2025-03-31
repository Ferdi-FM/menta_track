import 'dart:collection';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/settings.dart';
import 'package:menta_track/Pages/week_overview.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/Pages/question_page.dart';
import 'package:menta_track/termin.dart';
import 'package:time_planner/time_planner.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../termin_creator.dart';
import 'day_overview.dart';

///Wochenplan-Seite, zeigt eine Woche wie einen Stundenplan
//Package von: https://pub.dev/packages/time_planner/example

class WeekPlanView extends StatefulWidget {
  final String weekKey;
  final DateTime? scrollToSpecificDayAndHour;

  const WeekPlanView({
    super.key,
    required this.weekKey,
    this.scrollToSpecificDayAndHour,
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
  bool hapticFeedback = false;
  int scrollToSpecificDay = 0;
  int scrollToSpecificHour = 0;

  @override
  void initState() {
    setUpCalendar(widget.weekKey);
    loadTheme();
    super.initState();
  }

  void loadTheme() async{
    hapticFeedback = await SettingsPageState().getHapticFeedback();
  }

  ///Falls eine Benachrichtigung geöffnet wird, wenn man bereits auf der WeekPlanView-Seite ist, wird so beim zurückkehren die Seite geupdated
  @override
  Future<void> didPopNext() async {
    //Checkt ob sich die Anzahl an beantworteten Tasks verändert hat und wenn ja updated den Kalender
    int c = await DatabaseHelper().getWeekTermineCountAnswered(widget.weekKey, true);
    if(rememberAnsweredTasks != c){
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

  ///Setup vom Kalendar und den Einträgen
  void setUpCalendar(String weekKey) async{
    DatabaseHelper databaseHelper = DatabaseHelper();
    calendarStart = DateTime.parse(weekKey);
    calendarHeaders = [];

    if(widget.scrollToSpecificDayAndHour != null){
      scrollToSpecificHour = widget.scrollToSpecificDayAndHour!.hour;
      scrollToSpecificDay = widget.scrollToSpecificDayAndHour!.difference(calendarStart).inDays;
    }

    ///Erstellt die Köpfe der einzelnen Spalten
    for(int i = 0; i < 7;i++){
      DateTime date = calendarStart.add(Duration(days: i));
      String displayDate = DateFormat("dd.MM.yy").format(date);
      String weekDay = Utilities().getWeekdayName(date);
      calendarHeaders.add(
          TimePlannerTitle(
              title: weekDay,
              date: displayDate, //Wichtig fürs öffnen des dayOverview
              displayDate: S.current.displayADate(date),
              voidAction: clickOnCalendarHeader,
          ));
    }

    List<Termin> weekAppointments = await databaseHelper.getWeeklyPlan(widget.weekKey);
    // Liste für Gruppen von überschneidenden Terminen
    List<List<String>> overlapGroups = [];
    Set<String> groupedTerminNames = {};

    // Funktion, um zu überprüfen, ob zwei Termine sich überschneiden
    bool isOverlapping(Termin t1, Termin t2) {
      return t1.timeBegin.isBefore(t2.timeEnd) && t1.timeEnd.isAfter(t2.timeBegin);
    }

    // Gruppierung der Termine
    for (var t1 in weekAppointments) {
      String t1SafeName = "${t1.terminName}${t1.timeBegin.toIso8601String()}";
      if (groupedTerminNames.contains(t1SafeName)) continue;

      // Neue Gruppe mit t1 starten
      List<String> currentGroup = [t1SafeName];
      Queue<Termin> toCheck = Queue.of([t1]);

      while (toCheck.isNotEmpty) {
        var current = toCheck.removeFirst();
        String currentSafeName = "${current.terminName}${current.timeBegin.toIso8601String()}"; //Unique String zum Vergleichen

        for (var t2 in weekAppointments) {
          String t2SafeName = "${t2.terminName}${t2.timeBegin.toIso8601String()}";

          if (groupedTerminNames.contains(t2SafeName) || currentSafeName == t2SafeName) continue;

          if (isOverlapping(current, t2)) {
            if(!currentGroup.contains(t2SafeName)){
              currentGroup.add(t2SafeName);
            }
            groupedTerminNames.add(t2SafeName);
            toCheck.add(t2);
          }
        }
      }

      // Gruppe nur hinzufügen, wenn sie mehr als einen Termin enthält
      if (currentGroup.length > 1) {
        overlapGroups.add(currentGroup);
      }

      // Ursprünglichen Termin als verarbeitet markieren
      groupedTerminNames.add(t1SafeName);
    }

    for (Termin t in weekAppointments) {
      String title = t.terminName;
      DateTime startTime = t.timeBegin;
      DateTime endTime = t.timeEnd;
      Color? color = t.answered ? Colors.lightGreen : Colors.blueGrey.shade300;

      if (!t.answered && DateTime.now().isAfter(endTime)) {
        color = Colors.blueGrey.shade200;
      }
      int overlapPos =  0;
      int overlapOffset = 0;
      String safeName = "${t.terminName}${t.timeBegin.toIso8601String()}";
      for (var group in overlapGroups) {
        if(group.contains(safeName)){
          overlapPos = group.length;
          overlapOffset = group.indexOf(safeName);
        }
      }

      _addObject(title, startTime, endTime, color, overlapPos, overlapOffset);
    }
    if(mounted) await Utilities().checkAndShowFirstHelpDialog(context, "WeekPlanView");
  }

  ///Tap auf einen Kalenderkopf
  Future<void> clickOnCalendarHeader(String dateString) async {
    if(await SettingsPageState().getHapticFeedback()) HapticFeedback.lightImpact();
    String weekDayKey = dateString;
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => DayOverviewPage(
        weekKey: widget.weekKey,
        weekDayKey: weekDayKey,
        fromNotification: false
      ),
    ));
  }

  ///Lädt den Kalender neu
  void updateCalendar() {
    setState(() {
      tasks.clear();
    });
    setUpCalendar(widget.weekKey);
  }

  ///Konvertiert eine DateTime zu der vom package erwartetem Format (integer). errechnet differenz zwischen der 0ten Stunde am Kalender und dem Termin
  Map<String, int> convertToCalendarFormat(DateTime calendarStart, DateTime terminDate) {
    Duration difference = terminDate.add(terminDate.timeZoneOffset - calendarStart.timeZoneOffset).difference(calendarStart);
    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;

    return {
      "Days": days,
      "Hours": hours,
      "Minutes": minutes,
    };
  }

  ///erzeugt Event im Kalender
  void _addObject(String title, DateTime startTime, DateTime endTime, Color? color, int numberofOverlaps, int overlapOffset) { //
    Map<String, int> convertedDate = convertToCalendarFormat(calendarStart, startTime);
    int day = convertedDate["Days"]!;
    int hour = convertedDate["Hours"]!;
    int minutes = convertedDate["Minutes"]!;
    int duration = endTime.difference(startTime).inMinutes;
    if(color == Colors.lightGreen) rememberAnsweredTasks += 1; //Merkt sich, wieviele Taks geantwortet wurden

    int textheight = duration - 24;

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
          overLapOffset: overlapOffset,
          daysDuration: 1,
          child:
          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (event) async {
                Offset pos = event.globalPosition;
                final result = await navigatorKey.currentState?.push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => QuestionPage(
                          weekKey: widget.weekKey,
                          timeBegin: startTime.toIso8601String(),
                          timeEnd: endTime.toIso8601String(),
                          terminName: title),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const curve = Curves.easeInOut;
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
                      child: Icon(color == Colors.blueGrey.shade200 ? Icons.priority_high : null)
                  ),
                  ///Start and Endzeit, beide, damit falls sich einträge Überlappen, sie auseinandergehalten werden können
                  Positioned(
                      top: 1,
                      left: 5,
                      child: Text(DateFormat("HH:mm").format(startTime), style: TextStyle(fontWeight: FontWeight.w200, color: Colors.black87, fontStyle: FontStyle.italic, fontSize: duration/8 < 10 ? duration/8 : 9,),), //Ursprünglich 7 : 9
                  ),
                  Positioned(
                    bottom: 1,
                    left: 5,
                    child: Text(DateFormat("HH:mm").format(endTime), style: TextStyle(fontWeight: FontWeight.w200, color: Colors.black87, fontStyle: FontStyle.italic,  fontSize: duration/8 < 10 ? duration/8 : 9),), //${DateFormat("HH:mm").format(startTime)} -
                  ),
                  Container(
                    height: textheight.toDouble(),
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 10, right: 10, bottom: duration > 30 ? 12: duration/3, top: duration > 30 ? 10 : duration/4), //Ursprünglich 8 : 12
                      child: Text(
                          overflow: TextOverflow.ellipsis,
                          maxLines: (duration/30).toInt(),
                          title,
                          style: TextStyle(
                            fontSize: duration > 30 ? 10 : duration/7,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                      ),
                  )
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
            title: //Text(Utilities().convertWeekKeyToDisplayPeriodString(widget.weekKey)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
              Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 6,
                      backgroundColor: Colors.transparent,

                      shadowColor: Theme.of(context).shadowColor.withAlpha(80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: (){
                      if(hapticFeedback) HapticFeedback.lightImpact();
                      navigatorKey.currentState?.push(MaterialPageRoute(
                        builder: (context) =>
                            WeekOverview(
                              weekKey: widget.weekKey,
                              fromNotification: false,),
                      ));
                    },
                    child:FittedBox(fit:BoxFit.contain,child: Text(Utilities().convertWeekKeyToDisplayPeriodString(widget.weekKey), style: TextStyle(fontSize: 25, color: Theme.of(context).appBarTheme.foregroundColor),)),
                  ))
            ],),
            centerTitle: true,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15))),
            actions: [
              Padding( //Nicht die Funktion aus Utilities, da ich auf hinzufügen von Eintrag reagieren muss, was nicht durch RouteAware/DidPopNext aufgefangen wird
                padding: EdgeInsets.only(right: 5),
                child: MenuAnchor(
                    menuChildren: <Widget>[
                      MenuItemButton(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.help_rounded),
                              SizedBox(width: 10),
                              Text(S.of(context).help)
                            ],
                          ),
                        ),
                        onPressed: () => Utilities().showHelpDialog(context, "WeekPlanView"),
                      ),
                      MenuItemButton(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.assessment_outlined),
                              SizedBox(width: 10),
                              Text(S.current.weekOverViewHeadline)
                            ],
                          ),
                        ),
                        onPressed: () async {
                          navigatorKey.currentState?.push(MaterialPageRoute(
                            builder: (context) =>
                                WeekOverview(
                                  weekKey: widget.weekKey,
                                  fromNotification: false,),
                          ));
                        },
                      ),
                    ],
                    builder: (BuildContext context, MenuController controller, Widget? child) {
                      return TextButton(
                        focusNode: FocusNode(),
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        child: Icon(Icons.menu, size: 30, color: Theme.of(context).appBarTheme.foregroundColor),
                      );
                    }
                ),
              )
            ],
          ),
          body: LayoutBuilder(builder: (context, constraints){
            bool isPortrait = constraints.maxWidth < 600;
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                  color: Theme.of(context).scaffoldBackgroundColor
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0),
                child: TimePlanner( //index startet bei 0, 0-23 ist also 24/7
                  startHour: 0,
                  endHour: 23,
                  use24HourFormat: true,
                  setTimeOnAxis: true,
                  currentTimeAnimation: true,
                  animateToDefinedHour: scrollToSpecificHour,
                  animateToDefinedDay: scrollToSpecificDay,
                  style: TimePlannerStyle(
                    cellHeight: 60,
                    cellWidth:  isPortrait ? 125 : ((MediaQuery.of(context).size.width - 60)/7).toInt(), //leider nur wenn neu gebuildet wird
                    showScrollBar: true,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    interstitialEvenColor: MyApp.of(context).themeMode == ThemeMode.light ? Colors.grey[50] : Colors.blueGrey.shade400,
                    interstitialOddColor: MyApp.of(context).themeMode == ThemeMode.light ? Colors.grey[200] : Colors.blueGrey.shade500,
                  ),
                  headers: calendarHeaders,
                  tasks: tasks,
                ),
              ),
            );
          }),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              var result = await TerminDialog(weekKey: widget.weekKey).show(context);
              if(result != null){
                  updateCalendar();
                }

            },
            child: FittedBox( //Damit bei unterschiedlichen Displaygrößen die Icongröße nicht Über den Button ragt
              fit: BoxFit.fitHeight,
              child: Icon(Icons.add_task, size: 28),
            ),
          ),
        );
  }

  ///Soll alle Events dem Handy-Kalender hinzufügen, funktioniert aber nicht, da immer der Kalender erst geöffnet wird
  ///Man müsste ein anders Package suchen, dass Events hinzufügen kann ohne den Kalender zu öffnen, wird evtl noch gemacht
  Future<void> addToCalendar() async {
    List<Termin> weekAppointments = await DatabaseHelper().getWeeklyPlan(widget.weekKey);
        for(Termin t in weekAppointments){
          final Event event = Event(
            title: t.terminName,
            startDate: t.timeBegin,
            endDate: t.timeEnd,
          );
          Add2Calendar.addEvent2Cal(event);
        }
  }
}

//Funktion für ContextMenü bei einzelnen Einträgen (Kommt unter Container in dem Stack:

/*MenuAnchor(
                      menuChildren: <Widget>[
                        MenuItemButton(
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 10),
                                Text("Delete")
                              ],
                            ),
                          ),
                          onPressed: () => print("delete"),
                        ),
                        MenuItemButton(
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 10),
                                Text("Edit")
                              ],
                            ),
                          ),
                          onPressed: () {
                            print("Edit");
                          },
                        ),
                      ],
                      builder: (BuildContext context, MenuController controller, Widget? child) {
                        return TextButton(
                          focusNode: FocusNode(),
                          onLongPress: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          onPressed: () async {
                            final RenderBox renderBox = context.findRenderObject() as RenderBox;
                            final Offset pos = renderBox.localToGlobal(Offset.zero);
                            final result = await navigatorKey.currentState?.push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => QuestionPage(
                                      weekKey: widget.weekKey,
                                      timeBegin: startTime.toIso8601String(),
                                      timeEnd: endTime.toIso8601String(),
                                      terminName: title),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const curve = Curves.easeInOut;
                                    var tween = Tween<double>(begin: 0.1, end: 1.0).chain(CurveTween(curve: curve));
                                    var scaleAnimation = animation.drive(tween);
                                    return ScaleTransition(
                                      scale: scaleAnimation,
                                      alignment: Alignment((pos.dx+50) / MediaQuery.of(context).size.width * 2 - 1,
                                          (pos.dy+30) / MediaQuery.of(context).size.height * 2 - 1), // Die Tap-Position relativ zur Bildschirmgröße
                                      child: child,
                                    );},
                                )
                            );
                            if(result != null){
                              updated = true;
                              updateCalendar();
                            }
                          },
                          child: SizedBox.expand()
                        );
                      }
                  )*/