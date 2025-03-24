import 'package:add_2_calendar/add_2_calendar.dart';
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
import '../termin_creator.dart';
import 'day_overview.dart';

///Wochenplan-Seite, zeigt eine Woche wie einen Stundenplan
//Package von: https://pub.dev/packages/time_planner/example

class WeekPlanView extends StatefulWidget {
  final String weekKey;
  final int? scrollToSpecificHour;

  const WeekPlanView({
    super.key,
    required this.weekKey,
    this.scrollToSpecificHour,
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
    // Liste für die Gruppen von überschneidenden Terminen
    List<List<String>> overlapGroups = [];
    // Set, um bereits gruppierte Termine zu verfolgen
    Set<String> groupedTerminNames = {};

    // Funktion um zu überprüfen ob zwei Termine sich überschneiden
    bool isOverlapping(Termin t1, Termin t2) {
      return t1.timeBegin.isBefore(t2.timeEnd) && t1.timeEnd.isAfter(t2.timeBegin);
    }

    // Gruppierung der Termine
    for (var t1 in weekAppointments) {
      //SafeName, als einzigartige Identifikation
      String t1SafeName = "${t1.terminName}${t1.timeBegin.toIso8601String()}";
      if (groupedTerminNames.contains(t1SafeName)) continue;

      //Wenn t1 noch in keiner Gruppe ist wird neue Gruppe erstellt
      List<String> currentGroup = [t1SafeName];

      //Vergleicht alle termine mit t1 und überspringt wenn er gleich ist, oder schon in einer gruppe ist
      for (var t2 in weekAppointments) {
        String t2SafeName =  "${t2.terminName}${t2.timeBegin.toIso8601String()}";
        if (t1 == t2 || groupedTerminNames.contains(t2SafeName)) continue;

        //wenn sich die termine überschneiden wird t2 der aktuellen gruppe hinzugefügt und als schon gruppiert markiert (dem set hinzugefügt
        if (isOverlapping(t1, t2)) {
          currentGroup.add(t2SafeName);
          groupedTerminNames.add(t2SafeName);
        }
      }

      // Termin selbst als gruppiert markieren
      groupedTerminNames.add(t1SafeName);

      // Gruppe nur hinzufügen, wenn sie mindestens zwei Termine enthält
      if (currentGroup.length > 1) {
        overlapGroups.add(currentGroup);
      }
    }

    //TODO: Potentiell CellWidth erhöhen, wenn 3 oder mehr sich überschneiden!
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

  ///Lädt den Kalender neu
  void updateCalendar() {
    setState(() {
      tasks.clear();
    });
    setUpCalendar(widget.weekKey);
  }

  ///Konvertiert eine DateTime zu der vom package erwartetem Format (integer). errechnet differenz zwischen der 0ten Stunde am Kalender und dem Termin
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
              onTapDown: (event) async {
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
                      child: Text(DateFormat("HH:mm").format(startTime), style: TextStyle(fontWeight: FontWeight.w200, color: Colors.black87, fontStyle: FontStyle.italic, fontSize: duration/10 < 10 ? duration/10 : 9,),), //Ursprünglich 7 : 9
                  ),
                  Positioned(
                    bottom: 1,
                    left: 5,
                    child: Text(DateFormat("HH:mm").format(endTime), style: TextStyle(fontWeight: FontWeight.w200, color: Colors.black87, fontStyle: FontStyle.italic,  fontSize: duration/10 < 10 ? duration/10 : 9),), //${DateFormat("HH:mm").format(startTime)} -
                  ),
                  Container(
                    height: textheight.toDouble(),
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 10, right: 10, bottom: 14, top: 10), //Ursprünglich 8 : 12
                      child: Text(
                          overflow: TextOverflow.ellipsis,
                          maxLines: (duration/30).toInt(),
                          title,
                          style: TextStyle(
                            fontSize: 10, //Ursprünglich 11
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
                  animateToDefinedHour: widget.scrollToSpecificHour,
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
                if(result){
                  updateCalendar();
                }
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