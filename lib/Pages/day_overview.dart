import 'package:action_slider/action_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/settings.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/gif_progress_widget.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:sqflite/sqflite.dart';
import '../generated/l10n.dart';
import '../reward_pop_up.dart';
import '../termin.dart';

///Tagesübersichtsseite zeigt Informationen zu einem Tag
//Confetti package: https://pub.dev/packages/confetti
//TODO Variation falls Termin nach endbenachrichtigung!

class DayOverviewPage extends StatefulWidget {
  final String weekKey; ///braucht "yyyy-MM-dd"-Format
  final String weekDayKey; ///braucht ("dd.MM.yy") format
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
  List<RadarEntry> radarEntries = [];
  int overAllTasksThisDay = 0;
  int tasksDoneInt = 0;
  int tasksMissed = 0;
  bool loaded = false;
  bool tooEarly = false;
  String name = "";

  double startFrame = 0;
  double endFrame = 0;

  List<String> favoriteAnswers = [];
  bool noFavorites = false;

  @override
  void initState() {
    getTermineForDay();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 2));
    tooEarly = DateTime.now().isBefore(DateFormat("dd.MM.yy").parse(widget.weekDayKey));
    super.initState();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();

    super.dispose();
  }

  ///Holt alle relevanten Daten und wandelt sie für die verschieden Widgets (Besondere Aktivitäten/Graphen/Fortschritt-Baum) um
  void getTermineForDay() async{
    List<Termin> termineForThisDay = await databaseHelper.getDayTermine(widget.weekDayKey); //weekKey im Format "dd.MM.yy"
    int totalTasksThisWeek = await databaseHelper.getWeekTermineCount(widget.weekKey, false);
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
          }
          if (t.calmMean == 6) {
            calmTasks = "$calmTasks • ${t.terminName} $negative\n";
          }
          if (t.helpMean == 6) {
            helpingTasks = "$helpingTasks • ${t.terminName} $negative\n";
          }
          meanQuestion1 = meanQuestion1 + (t.goodMean); //wie gut  , +1 weil skala bei 0 beginnt
          meanQuestion2 = meanQuestion2 + (t.calmMean); //wie ruhig
          meanQuestion3 = meanQuestion3 + (t.helpMean); //wie gut getan
        } else {
          if(DateTime.now().isAfter(t.timeBegin.add(Duration(minutes: 10)))){
            tasksMissed++;
          }
        }
      }
      radarEntries = [
        //wie gut ging es dir
        RadarEntry(value: meanQuestion1 / tasksDoneInt +1),
        //wie gut hat es getan
        RadarEntry(value: meanQuestion3 / tasksDoneInt +1),
        //wie ruhig warst du
        RadarEntry(value: meanQuestion2 / tasksDoneInt +1),

      ];
      favoriteAnswers = [favoriteTasks.trimRight(), calmTasks.trimRight(), helpingTasks.trimRight()]; //.trimRight() entfernt letztes \n, if(favoriteTasks != "") favoriteAnswers.add(...) geht nicht, da die Tasks den Comments zugeordnet werden müssen, wenn nur calmTaks da wären, würden diese sonst den favoriteComment zugeordnet werden
      if (favoriteTasks == "" && calmTasks == "" && helpingTasks == "") noFavorites = true;//schaut ob sie leer sind, damit kein leeres Material angezeigt wird
    } else {
      noFavorites = true;
    }
    startFrame = tasksUntilThisDay/totalTasksThisWeek;
    endFrame = (tasksUntilThisDay + tasksDoneInt)/totalTasksThisWeek;

    setState(() {
      tasksDoneInt;
      overAllTasksThisDay;
      loaded = true;
      _controllerCenter.play();
      //_controllerConstant.play();
    });
  }

  ///Erstellt die Confetti Widgets
  Widget buildConfettiWidgets() {
    if (overAllTasksThisDay == 0 || tasksDoneInt == 0 || !widget.fromNotification) {
      return SizedBox(); // Wenn eine der Bedingungen nicht erfüllt ist, kein Confetti anzeigen
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildConfetti(_controllerCenter, BlastDirectionality.explosive, 0.25, 20, 0.1, false, Alignment.topRight),
        buildConfetti(_controllerCenter, BlastDirectionality.explosive, 0.25, 20, 0.1, false, Alignment.topLeft),
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

  ///Öffnet das Belohnungs-PopUp und wartet auf das Bestätigen um die Seite zu verlassen
  void openRewardPopUp() async{
    String? result = await RewardPopUp().show(
        context,
        S.current.day_reward_message,
        widget.weekKey,
        false
    );
    if(result == "confirmed"){
      leavePage();
    }
  }

  ///Erzeugt den anzuzeigenden Text basierend auf beantworteten Aktivitäten/Zeitpunkt/etc.
  Widget getText() {
    final local = S.current;

    List<TextSpan> text = [];
    if(overAllTasksThisDay == 0){
      ///kein Termin an diesem tag
      text = [
        TextSpan(text: local.noAppointmentsOn(DateFormat("dd.MM.yy").format(DateTime.now()) == widget.weekDayKey ? local.today : "${local.am} ${widget.weekDayKey}")),
        TextSpan(text: "\n\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: local.hopeYouHadAGoodDay(name.length,name)),
      ];
    }
    if(overAllTasksThisDay != 0){
      ///Es gab termine
      if(tasksDoneInt != 0){
        ///Es wurde mindestens ein Termin beantwortet
        text = [
          TextSpan(text: local.taskCompletedOn(DateFormat("dd.MM.yy").format(DateTime.now()) == widget.weekDayKey ? local.today : "${S.of(context).am} ${widget.weekDayKey}"),style: TextStyle(fontSize: 25),),
          TextSpan(text: "$tasksDoneInt",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),),
          TextSpan(text: local.tasksCompleted(tasksDoneInt),style: TextStyle(fontSize: 25),),
          TextSpan(text: "\n\n${Utilities().getRandomisedEncouragement(widget.fromNotification, name)}",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
          ///mindestens ein Termin missed
          if(tasksMissed > 0 )TextSpan(text: local.tasksPendingFeedback(tasksMissed),style: TextStyle(fontSize: 15))
        ];

      }
      if(tasksMissed > 0 && tasksDoneInt == 0){
        ///Noch keinen Termin beantwortet
        text = [
          if(widget.fromNotification) TextSpan(text: S.current.noFeedbackFromNotification),
          TextSpan(text: local.tasksNotAnsweredOn(overAllTasksThisDay, DateFormat("dd.MM.yy").format(DateTime.now()) == widget.weekDayKey ? local.today : "${local.am} ${widget.weekDayKey}")),
          TextSpan(text: "\n\n"),
          TextSpan(text: local.checkPendingFeedback),
          TextSpan(text: "\n\n${local.hopeYouHadAGoodDay(name.length,name)}"),
        ];
      }
      if(tasksMissed == 0 && tasksDoneInt == 0){
        ///die Aktivität ist noch nicht gekommen
        text = [
          TextSpan(text: local.activity_not_there_yet(overAllTasksThisDay, name)),
        ];
      }
      if(tasksDoneInt + tasksMissed != overAllTasksThisDay){
        ///mindestens ein termin ist noch nicht gekommen
        text = [
          if(tasksDoneInt > 0)...{
            TextSpan(text: local.taskCompletedOn(DateFormat("dd.MM.yy").format(DateTime.now()) == widget.weekDayKey ? local.today : "${S.of(context).am}\n${widget.weekDayKey}"),style: TextStyle(fontSize: 25),),
            TextSpan(text: "$tasksDoneInt",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),),
            TextSpan(text: local.tasksCompleted(tasksDoneInt),style: TextStyle(fontSize: 25),),
            TextSpan(text: "\n\n${Utilities().getRandomisedEncouragement(widget.fromNotification, name)}",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
          },
          ///mindestens ein Termin missed
          if(tasksMissed > 0 ) TextSpan(text: local.tasksPendingFeedback(tasksMissed),style: TextStyle(fontSize: 15)),
          TextSpan(text: local.activity_not_there_yet(overAllTasksThisDay, name)),
        ];
      }
    }
    if(DateTime.now().isBefore(DateFormat("dd.MM.yy").parse(widget.weekDayKey))){
      ///Der Tag ist noch nicht gekommen
      text = [
        TextSpan(text: S.current.dayNotYetArrived(name)),
        TextSpan(text: "\n\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: local.hopeYouHadAGoodDay(name.length,name)),
      ];
    }
    if(text.isNotEmpty){
      return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              children: text),
      );
    }

    return SizedBox();
  }

  ///Zum verlassen der Seite, damit context nicht in async Funktion liegt
  void leavePage(){
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, result) {
          if (!didPop) {
            leavePage();
          }
        },
        child:  Scaffold(
          appBar: AppBar(
            title: Text(widget.weekDayKey),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                leavePage();
              },
            ),
            actions: [
              Utilities().getHelpBurgerMenu(context, "DayOverView")
            ],
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
                          SizedBox(height: MediaQuery.of(context).size.height*0.07,),
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
                                    child: Text("${S.current.special_activities}\n", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                  ),
                                  for (int i = 0; i < 3; i++) ...{ //favoriteComments.length
                                    Utilities().favoriteItems(i, favoriteAnswers, context),
                                  },
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (endFrame != 0 && !tooEarly && tasksMissed != overAllTasksThisDay)
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
                              : Padding(
                            padding: EdgeInsets.all(10),
                            child:AspectRatio(
                              aspectRatio: 1.3,
                              child: RadarChart(
                                RadarChartData(
                                  dataSets: showingDataSets(),
                                  radarBackgroundColor: Colors.transparent,
                                  borderData: FlBorderData(show: false),
                                  radarBorderData: const BorderSide(color: Colors.transparent),
                                  titlePositionPercentageOffset: 0.1,
                                  titleTextStyle: TextStyle(fontSize: 14),
                                  getTitle: (index, angle) {
                                    switch (index) {
                                    /// case 0 ist oben, case 1 ist unten links, case 2 ist unten rechts
                                      case 0: //Wie gut hast du dich gefühlt
                                        return RadarChartTitle(
                                          text: "${S.of(context).legend_Msg0}\n ${radarEntries[0].value.toString().substring(0, 3)}/7",
                                        );
                                      case 1: //Wie ruhig warst du
                                        return RadarChartTitle(
                                            text: "${radarEntries[1].value.toString().substring(0, 3)}/7 \n ${S.of(context).legend_Msg2_clip}",
                                            angle: 0);
                                      case 2: //Wie sehr hat es geholfen?
                                        return RadarChartTitle(
                                            text: "${radarEntries[2].value.toString().substring(0, 3)}/7 \n ${S.of(context).legend_Msg1_clip}",
                                            angle: 0);
                                      default:
                                        return RadarChartTitle(text: "");
                                    }
                                  },
                                  ticksTextStyle: TextStyle(color: Colors.transparent, fontSize: 10),
                                  tickBorderData: const BorderSide(color: Colors.transparent),
                                  gridBorderData: BorderSide(color: Colors.orange, width: 2),
                                ),
                                duration: const Duration(milliseconds: 400),
                              ),
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
                              HapticFeedback.lightImpact();
                              openRewardPopUp();
                              },
                            stateChangeCallback:(actionsliderState1 ,actionSliderState2, actionSliderController1) {
                              //actionSliderState2.position; //Prozent des Sliders
                              HapticFeedback.vibrate();
                            },
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
        )
    );
  }


  ///DataSet für den Radar-Chart
  List<RadarDataSet> showingDataSets() {
    return <RadarDataSet> [
      RadarDataSet(
        dataEntries: radarEntries,
        fillColor: Colors.lightBlueAccent.withValues(alpha: 0.4),
        borderColor: Colors.blue.withValues(alpha: 0.7),
        borderWidth: 2,
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
