import 'package:action_slider/action_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/settings.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/gif_progress_widget.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:sqflite/sqflite.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../reward_pop_up.dart';
import '../termin.dart';
import 'week_plan_view.dart';

//Confetti package: https://pub.dev/packages/confetti

class DayOverviewPage extends StatefulWidget {
  final String weekKey;
  final String weekDayKey; //braucht ("dd.MM.yy") format
  final bool fromNotification;

  const DayOverviewPage({
    super.key,
    required this.weekKey,
    required this.weekDayKey,
    required this.fromNotification
  });

  @override
  DayOverviewState createState() => DayOverviewState();
}

class DayOverviewState extends State<DayOverviewPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  late ConfettiController _controllerCenter;
  late ConfettiController _controllerConstant;
  List<RadarEntry> radarEntries = [];
  int overAllTasksThisDay = 0;
  int tasksDoneInt = 0;
  int tasksMissed = 0;
  bool loaded = false;
  String name = "";

  double startFrame = 0;
  double endFrame = 0;

  List<String> favoriteAnswers = [];
  bool noFavorites = false;

  @override
  void initState() {
    getTermineForDay();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 2));
    _controllerConstant = ConfettiController(duration: const Duration(seconds: 40));
    super.initState();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    _controllerConstant.dispose();

    super.dispose();
  }

  void getTermineForDay() async{
    List<Termin> termineForThisDay = await databaseHelper.getDayTermine(widget.weekDayKey); //weekKey im Format "dd.MM.yy"
    int totalTasksTillThisDay = await databaseHelper.getWeekTermineCount(widget.weekKey);
    overAllTasksThisDay = termineForThisDay.length;
    SettingData data = await SettingsPageState().getSettings();
    name = data.name;

    DateTime date = DateFormat('dd.MM.yy').parse(widget.weekDayKey);
    date = DateTime(date.year, date.month, date.day, 0 , 1 ); //Sucht termine in dieser Woche bevor dem Tag  //DateTime.now().hour, DateTime.now().minute
    String compareDateString = date.toIso8601String();

    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
        "Termine",
        where: "weekKey = ? AND answered = 1 AND (datetime(timeBegin) < datetime(?))" ,
        whereArgs: [widget.weekKey, compareDateString]
    );
    int tasksUntilThisDay = maps.length;

    if(termineForThisDay.isNotEmpty) {
      tasksDoneInt = 0;
      int meanQuestion1 = 0;
      int meanQuestion2 = 0;
      int meanQuestion3 = 0;
      String favoriteTasks = "";
      String calmTasks = "";
      String helpingTasks = "";

      for (Termin t in termineForThisDay) { //Evtl. direkte SQLite abfrage, bringt aber neue probleme mit sich
        String negative = "";
        if(t.doneQuestion == 2){
          negative = "(nicht zu tun)";
        } else {
          negative = "";
        }

        if (t.answered) {
          tasksDoneInt++;
          if (t.goodMean == 6) {
            favoriteTasks = "$favoriteTasks • ${t.terminName} $negative\n";
            //databaseHelper.saveHelpingActivities(t.terminName, "good");
          }
          if (t.calmMean == 6) {
            calmTasks = "$calmTasks • ${t.terminName} $negative\n";
            //databaseHelper.saveHelpingActivities(t.terminName, "calm");
          }
          if (t.helpMean == 6) {
            helpingTasks = "$helpingTasks • ${t.terminName} $negative\n";
            //databaseHelper.saveHelpingActivities(t.terminName, "help");
          }
          meanQuestion1 = meanQuestion1 + (t.goodMean + 1); //wie gut  , +1 weil skala bei 0 beginnt
          meanQuestion2 = meanQuestion2 + (t.calmMean + 1); //wie ruhig
          meanQuestion3 = meanQuestion3 + (t.helpMean + 1); //wie gut getan
        } else {
          if(DateTime.now().isAfter(t.timeEnd)){
            tasksMissed++;
          }
        }
      }
      radarEntries = [
        //wie gut ging es dir
        RadarEntry(value: meanQuestion1 / tasksDoneInt),
        //wie gut hat es getan
        RadarEntry(value: meanQuestion3 / tasksDoneInt),
        //wie ruhig warst du
        RadarEntry(value: meanQuestion2 / tasksDoneInt),



      ];
      favoriteAnswers = [favoriteTasks.trimRight(), calmTasks.trimRight(), helpingTasks.trimRight()]; //.trimRight() entfernt letztes \n, if(favoriteTasks != "") favoriteAnswers.add(...) geht nicht, da die Tasks den Comments zugeordnet werden müssen, wenn nur calmTaks da wären, würden diese sonst den favoriteComment zugeordnet werden
      //Und schaut ob sie leer sind, damit kein leeres Material angezeigt wird
      if (favoriteTasks == "" && calmTasks == "" && helpingTasks == "") noFavorites = true;

    } else {
      noFavorites = true;
    }
    startFrame = tasksUntilThisDay/totalTasksTillThisDay;
    endFrame = (tasksUntilThisDay + tasksDoneInt)/totalTasksTillThisDay;

    setState(() {
      tasksDoneInt;
      overAllTasksThisDay;
      loaded = true;
      _controllerCenter.play();
      _controllerConstant.play();
    });
  }



  /*Widget favoriteItems(int i) { //TODO: Test
    List<String> favoriteComments = [
      "Am besten ging es dir hier ${Emojis.smile_grinning_face_with_smiling_eyes}:",
      "Hier warst du am ruhigsten ${Emojis.smile_relieved_face}:",
      "Am meisten geholfen hat dir ${Emojis.body_flexed_biceps}:"];

    if(favoriteAnswers.isNotEmpty){
      if(favoriteAnswers[i] != ""){
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              child: Text(favoriteComments[i],textAlign: TextAlign.start, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            ),
            Padding(
                padding: EdgeInsets.only(left: 20,bottom: 10,top: 10),
                child: Text(favoriteAnswers[i],style: TextStyle(fontSize: 15),textAlign: TextAlign.start,)
            )
          ],
        );
      }
    }
    return SizedBox(height: 0,);
  }*/

  Widget buildConfettiWidgets() {
    if (overAllTasksThisDay == 0 || tasksDoneInt == 0 || !widget.fromNotification) {
      return SizedBox(); // Wenn eine der Bedingungen nicht erfüllt ist, kein Confetti anzeigen
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildConfetti(_controllerCenter, BlastDirectionality.explosive, 0.25, 20, 0.1, false, Alignment.topRight),
        buildConfetti(_controllerCenter, BlastDirectionality.explosive, 0.25, 20, 0.1, false, Alignment.topLeft),
        buildConfetti(_controllerConstant, BlastDirectionality.explosive, 0.15, 2, 0.1, true, Alignment.topLeft),
        buildConfetti(_controllerConstant, BlastDirectionality.explosive, 0.15, 2, 0.1, true, Alignment.topRight),
      ],
    );
  }

  Widget buildConfetti(ConfettiController controller, BlastDirectionality blastDirectionality, double emissionFrequency, int numberOfParticles, double gravity, bool shouldLoop, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirectionality: blastDirectionality,
        emissionFrequency: emissionFrequency,
        numberOfParticles: numberOfParticles,
        gravity: gravity,
        shouldLoop: shouldLoop,
      ),
    );
  }

  void openRewardPopUp() async{
    String? result = await RewardPopUp().show(
        context,
        S.current.day_reward_message,
        widget.weekKey,
        false
      //(){Navigator.of(context).pop();}
    );
    if(result == "confirmed"){
      backToPage();
    }
  }

  void backToPage(){
    Navigator.of(context).pop();
  }

  Widget getText() {
    final local = S.current;

    if (tasksDoneInt != 0) {
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 24,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          children: <TextSpan>[
            TextSpan(
              text: local.taskCompletedOn(DateFormat("dd.MM.yy").format(DateTime.now()) == widget.weekDayKey ? local.today : "${S.of(context).am} ${widget.weekDayKey}"
              ),
              style: TextStyle(fontSize: 22),
            ),
            TextSpan(
              text: "$tasksDoneInt",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            TextSpan(
              text: local.tasksCompleted(tasksDoneInt),
              style: TextStyle(fontSize: 22),
            ),
            TextSpan(
              text: "\n\n${Utilities().getRandomisedEncouragement(widget.fromNotification, name)}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            if (tasksMissed > 0)
              TextSpan(
                text: local.tasksPendingFeedback(tasksMissed),
                style: TextStyle(fontSize: 15),
              ),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    if (tasksDoneInt == 0) {
      return RichText(
        text: overAllTasksThisDay == 0
            ? TextSpan(
          style: TextStyle(
            fontSize: 24,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          children: <TextSpan>[
            TextSpan(
                text: local.noAppointmentsOn(DateFormat("dd.MM.yy").format(DateTime.now()) == widget.weekDayKey ? local.today : "${local.am} ${widget.weekDayKey}")
            ),
            TextSpan(
                text: "\n\n", style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: local.hopeYouHadAGoodDay(name.length,name)),
          ],
        )
            : (tasksMissed > 0 && overAllTasksThisDay != 0)
            ? TextSpan(
          style: TextStyle(
            fontSize: 24,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          children: <TextSpan>[
            TextSpan(
                text: local.tasksNotAnsweredOn(overAllTasksThisDay, DateFormat("dd.MM.yy").format(DateTime.now()) == widget.weekDayKey ? local.today : "${local.am} ${widget.weekDayKey}")
            ),
            TextSpan(text: "\n\n"),
            TextSpan(text: local.checkPendingFeedback),
            TextSpan(text: "\n\n${local.hopeYouHadAGoodDay(name.length,name)}"),
          ],
        )
            : tasksMissed == 0 ? TextSpan(
            style: TextStyle(
            fontSize: 24,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          children: <TextSpan>[
            TextSpan(text: local.dayNotYetArrived(name)),
          ],
        )
            : TextSpan(text: local.unexpectedCaseFound),
        textAlign: TextAlign.center,
      );
    }

    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.weekDayKey),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if(widget.fromNotification){ //Andere Pageroute, wenn von Notification, wird wahrscheinlich entfernt
              MyApp.navigatorKey.currentState?.pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => WeekPlanView(
                        weekKey: widget.weekKey),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  )
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body:  Stack(
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
              stops: [0.0, 0.1, 0.9, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              // ignore: avoid_unnecessary_containers
              child: loaded ? Container(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //SizedBox(height: MediaQuery.of(context).size.height*0.07,), //TODO: Falls Appbar entfernt wird
                      SizedBox(height: MediaQuery.of(context).size.height*0.03,),
                      loaded ? getText() : SizedBox(width: MediaQuery.of(context).size.width,),
                      SizedBox(height: 20,),
                      if (!noFavorites) Material(//zuerst favoriteAnswers.isNotEmpty, durch es ist aber immer mindestens ["","",""] was als voll gezählt wird
                          elevation: 10,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.fromBorderSide(BorderSide(width: 0.5, color: Colors.black)),
                            ),
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: [
                                FittedBox(
                                  child: Text(S.current.special_activities, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                ),
                                for (int i = 0; i < 3; i++) ...{ //favoriteComments.length
                                  Utilities().favoriteItems(i, favoriteAnswers, context),
                                },
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      if (endFrame != 0 && tasksMissed == 0)
                        GifProgressWidget(
                          progress: endFrame,
                          startFrame: overAllTasksThisDay != 0 ? startFrame : 0,
                          finished: () => {},
                          termineForThisDay: overAllTasksThisDay,
                          forRewardPage: false,
                        ),
                      SizedBox(
                        height: 40,
                      ),
                      (overAllTasksThisDay == 0|| tasksDoneInt == 0)
                          ? SizedBox()
                          : Text(
                        S.of(context).daily_Values,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor.withAlpha(200),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      (overAllTasksThisDay == 0|| tasksDoneInt == 0)
                          ? SizedBox()
                          : SizedBox(
                        height: 30,
                      ),
                      (overAllTasksThisDay == 0|| tasksDoneInt == 0)
                          ? SizedBox()
                          : AspectRatio(
                        aspectRatio: 1.3,
                        child: RadarChart(
                          RadarChartData(
                            dataSets: showingDataSets(),
                            radarBackgroundColor: Colors.transparent,
                            borderData: FlBorderData(show: false),
                            radarBorderData: const BorderSide(color: Colors.transparent),
                            titlePositionPercentageOffset: 0.1,
                            titleTextStyle: TextStyle(color: Colors.black, fontSize: 14),
                            getTitle: (index, angle) {
                              switch (index) {
                                /// case 0 ist oben, case 1 ist unten links, case 2 ist unten rechts
                                ///aber radar
                                case 0: //Wie gut hast du dich gefühlt
                                  return RadarChartTitle(
                                    text: "${S.of(context).legend_Msg0}\n ${radarEntries[0].value.toString().substring(0, 3)}/7",
                                  );
                                case 1: //Wie ruhig warst du
                                  return RadarChartTitle(
                                    text: "${radarEntries[1].value.toString().substring(0, 3)}/7 \n Wie sehr hat\nes geholfen",
                                    angle: 0);
                                case 2: //Wie sehr hat es geholfen?
                                  return RadarChartTitle(
                                      text: "${radarEntries[2].value.toString().substring(0, 3)}/7 \n Wie Ruhig\nwarst du",
                                      angle: 0);
                                default:
                                  return RadarChartTitle(text: "");
                              }},
                            tickCount: 1,
                            ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
                            tickBorderData: const BorderSide(color: Colors.transparent),
                            gridBorderData: BorderSide(color: Colors.orange, width: 2),
                          ),
                          duration: const Duration(milliseconds: 400),
                        ),
                      ),
                      SizedBox(
                        height: 36,
                      ),
                      widget.fromNotification
                          ? ActionSlider.standard(
                        child: Text(S.current.understood, key: GlobalKey(debugLabel: "actKey")),
                        action: (controller) async {
                          controller.loading();
                          await Future.delayed(const Duration(seconds: 1));
                          controller.success();
                          controller.reset();
                          openRewardPopUp();},
                      )
                          : ElevatedButton(
                          style: ElevatedButton.styleFrom(minimumSize: Size(200, 50),),
                          onPressed: Navigator.of(context).pop,
                          child: Text(S.current.back)),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ) : Center(child: CircularProgressIndicator()),
            ),
          ),
          buildConfettiWidgets(),
        ],
      ),
    );
  }


  List<RadarDataSet> showingDataSets() {
    return <RadarDataSet> [
      RadarDataSet(
        dataEntries: radarEntries,
        fillColor: Colors.lightBlueAccent.withValues(alpha: 0.4),
        borderColor: Colors.blue.withValues(alpha: 0.7),
        borderWidth: 3,
      ),
      RadarDataSet( //Legt die grö0e des Graphen immer auf 7 fest
          dataEntries: [
            RadarEntry(value: 7),
            RadarEntry(value: 7),
            RadarEntry(value: 7),
          ],
          fillColor: Colors.transparent,
          borderColor: Colors.transparent,
          borderWidth: 0
      )
    ];
  }
}
