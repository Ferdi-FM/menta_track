import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:menta_track/database_helper.dart';
import '../main.dart';
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
  List<Termin> termineForThisDay = [];
  List<RadarEntry> radarEntries = [];
  int tasksDoneInt = 0;
  int tasksMissed = 0;

  String tasksDoneString = "0";
  String favoriteTasks = "";
  String calmTasks = "";
  String helpingTasks = "";
  late ConfettiController _controllerCenter;
  late ConfettiController _controllerConstant;

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
      termineForThisDay = await databaseHelper.getDayTermine(widget.weekKey, widget.weekDayKey);
      print(termineForThisDay.isNotEmpty);
      if(termineForThisDay.isNotEmpty) {
        tasksDoneInt = 0;
        int meanQuestion1 = 0;
        int meanQuestion2 = 0;
        int meanQuestion3 = 0;

        for (Termin t in termineForThisDay) {
          if (t.answered) {
            tasksDoneInt++;
            print(t.toString());
            if (t.question1 == 6) {
              favoriteTasks = "$favoriteTasks \n - ${t.terminName} ";
              databaseHelper.saveHelpingActivities(t.terminName, "good");
            }
            if (t.question2 == 6) {
              calmTasks = "$calmTasks \n - ${t.terminName} ";
              databaseHelper.saveHelpingActivities(t.terminName, "calm");
            }
            if (t.question3 == 6) {
              helpingTasks = "$helpingTasks \n - ${t.terminName} ";
              databaseHelper.saveHelpingActivities(t.terminName, "help");
            }
            meanQuestion1 = meanQuestion1 +
                (t.question1 + 1); //wie gut  , +1 weil skala bei 0 beginnt
            meanQuestion2 = meanQuestion2 + (t.question2 + 1); //wie ruhig
            meanQuestion3 = meanQuestion3 + (t.question3 + 1); //wie gut getan
          } else {
            if(DateTime.now().isAfter(t.timeEnd)){
              tasksMissed++;
              print(tasksMissed);
            }
          }
        }
        radarEntries = [
          RadarEntry(value: meanQuestion1 / tasksDoneInt),
          //wie gut ging es dir
          RadarEntry(value: meanQuestion3 / tasksDoneInt),
          //wie gut hat es getan
          RadarEntry(value: meanQuestion2 / tasksDoneInt),
          //wie ruhig warst du

        ];
        print(radarEntries.toString());
        tasksDoneString = "$tasksDoneInt"; //"$tasksDoneInt / ${termineForThisDay.length} \n also \n ${(tasksDoneInt / termineForThisDay.length * 100).round()}%";
        favoriteAnswers = [favoriteTasks, calmTasks, helpingTasks];
      }
      setState(() {
        tasksDoneString;
        _controllerCenter.play();
        _controllerConstant.play();
      });
  }

  List<String> favoriteComments = [
    "Am besten ging es dir hier ${Emojis.smile_grinning_face_with_smiling_eyes}:",
    "Du warst hierbei am ruhigsten ${Emojis.smile_relieved_face}:",
    "Am meisten geholfen hat dir ${Emojis.body_flexed_biceps}:"];
  List<String> favoriteAnswers = [];

  Widget favoriteItems(int i) {
    if(favoriteAnswers.isNotEmpty){
      if(favoriteAnswers[i] != ""){
        return RichText( //besten gefallen
          text: TextSpan(
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey[700],
              ),
              children: [
                TextSpan(text: favoriteComments[i], style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: "", style: TextStyle(fontSize: 6)),
                TextSpan(text: favoriteAnswers[i])
              ]
          ),
          textAlign: TextAlign.center,
        );
      }
    }
    return SizedBox(height: 0,);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Week Key"),
        backgroundColor: Theme.of(context).primaryColorLight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if(widget.fromNotification){
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
      body: SingleChildScrollView(
        child: Container(
          /*decoration: BoxDecoration( //TODO: Vielleicht hintergrundbild
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1,
                focalRadius: -2,
                colors: [
                  Colors.white,
                  Theme.of(context).primaryColorLight,
                ],)
            //image: DecorationImage(
            //image: AssetImage("assets/images/"),
            //fit: BoxFit.fill,
          ), */
          child: Padding(padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if(termineForThisDay.isNotEmpty && tasksDoneInt != 0) Align(
                alignment: Alignment.topRight,
                child: ConfettiWidget(
                  confettiController: _controllerCenter,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.25,
                  numberOfParticles: 20, // a lot of particles at once
                  gravity: 0.1,
                ),
              ),
              if(termineForThisDay.isNotEmpty && tasksDoneInt != 0) Align(
                alignment: Alignment.topLeft,
                child: ConfettiWidget(
                  confettiController: _controllerCenter,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.25,
                  numberOfParticles: 20, // a lot of particles at once
                  gravity: 0.1,
                ),
              ),
              if(termineForThisDay.isNotEmpty && tasksDoneInt != 0) Align(
                alignment: Alignment.topLeft,
                child: ConfettiWidget(
                  confettiController: _controllerConstant,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.15,
                  numberOfParticles: 2, // a lot of particles at once
                  gravity: 0.1,
                  shouldLoop: true,

                ),
              ),
              if(termineForThisDay.isNotEmpty && tasksDoneInt != 0) Align(
                alignment: Alignment.topRight,
                child: ConfettiWidget(
                  confettiController: _controllerConstant,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.15,
                  numberOfParticles: 2, // a lot of particles at once
                  gravity: 0.1,
                  shouldLoop: true,

                ),
              ),
              SizedBox(height: 15,),
              (termineForThisDay.isEmpty || tasksDoneInt == 0) ? SizedBox(height: 150,) :RichText(
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey[700],
                    ),
                    children: <TextSpan>[
                      TextSpan(text: "Du hast heute am \n",),
                      TextSpan(text: widget.weekKey, style: TextStyle(fontWeight: FontWeight.bold))
                    ]
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              if(tasksDoneInt != 0) RichText( //Wenn Termine beantwortet wurden
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey[700],
                    ),
                    children: <TextSpan>[
                      TextSpan(text: "$tasksDoneString \n \n", style: TextStyle(fontWeight: FontWeight.bold)),
                      tasksDoneInt != 0 ? TextSpan(text: "Termine geschafft") : TextSpan(text: ""),
                    ]
                ),
                textAlign: TextAlign.center,
              ),
              if(termineForThisDay.isEmpty || tasksDoneInt == 0) RichText( //wenn keine Termine gab oder keine beantwortet wurden
                text: termineForThisDay.isEmpty ? TextSpan( //Nachricht, wenn keine Termine am Tag waren
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey[700],
                    ),
                    children: <TextSpan>[
                      TextSpan(text: "Du hast heute \n"),
                      TextSpan(text: "Keinen Termine geplant gehabt, \n \n", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: "Ich hoffe du hast und hattest trotzdem einen schönen Tag ${Emojis.smile_smiling_face}")
                    ]
                ) : (tasksMissed > 0 && termineForThisDay.isNotEmpty )? TextSpan( //Nachricht, wenn Termine am Tag waren aber keine beantwortet wurden
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[700],
                  ),
                  children: <TextSpan>[
                    TextSpan(text: "Du hast heute ${termineForThisDay.length > 1 ? "${tasksDoneInt > 0 ? "mind. einen deiner" : "deine"} Termine" : "deinen Termin"} noch nicht beantwortet\n"), //Konstrukt um auf jede Möglichkeit an Versäumnis einzugehen
                    TextSpan(text:"Schau auf der Startseite unter \n"),
                    TextSpan(text: "\n", style: TextStyle(fontSize: 15)),
                    TextSpan(text:"\"Offen\"", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "\n oder in der \n"),
                    TextSpan(text:"\"Wochenübersicht\"", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "\n", style: TextStyle(fontSize: 15)),
                    TextSpan(text:"\n nach um Feedback zu einer Aktivität zu geben ${Emojis.hand_thumbs_up}"),
                    TextSpan(text: "\n Ich hoffe du hast und hattest einen schönen Tag ${Emojis.smile_smiling_face}")
                  ],
                ) : tasksMissed == 0 ? TextSpan( //Nachricht, wenn ein Termin ansteht, aber die Zeit noch nicht gekommen ist
                  children: <TextSpan>[
                    TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: "Die Zeit für den Termin ist noch nicht gekommen ${Emojis.smile_winking_face}")

                        ]
                    )
                  ] ,
                ): TextSpan(text: "Glückwunsch!!! ${Emojis.activites_party_popper} \n Du hast einen Fall gefunden, an den Ich nicht gedacht hab!\n Gut gemacht! ${Emojis.smile_smiling_face} \n Falls möglich sag deinem Therapeuten oder Entwickler der App welche Kombination an benantworteten und nicht beantworteten Terminen hierzu geführt hat"),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10,),
              Padding(
                padding: EdgeInsets.all(10) ,
                child: Column(
                  children: [
                    for(int i = 0; i < favoriteComments.length; i++)...{
                      SizedBox(height: 15),
                      favoriteItems(i),
                    },
                  ],
                ),
              ),

              SizedBox(height: 60,),
              (termineForThisDay.isEmpty || tasksDoneInt == 0) ? SizedBox() : AspectRatio(
                aspectRatio: 1.3,
                child: termineForThisDay.isNotEmpty ? RadarChart(
                  RadarChartData(
                    dataSets: showingDataSets(),
                    radarBackgroundColor: Colors.transparent,
                    borderData: FlBorderData(show: false),
                    radarBorderData: const BorderSide(color: Colors.transparent),
                    titlePositionPercentageOffset: 0.1  ,
                    titleTextStyle:
                    TextStyle(color: Colors.black, fontSize: 14),
                    getTitle: (index, angle) {
                      switch (index) {
                        case 0:
                          return RadarChartTitle(
                            text: 'Laune \n ${radarEntries[0].value.toString().substring(0,3)}/7',
                          );
                        case 2:
                          return RadarChartTitle(
                              text: '${radarEntries[2].value.toString().substring(0,3)}/7 \n Ruhe',
                              angle: 0
                          );
                        case 1:
                          return RadarChartTitle(
                              text: '${radarEntries[1].value.toString().substring(0,3)}/7 \n geholfen',
                              angle: 0);
                        default:
                          return const RadarChartTitle(text: '');
                      }
                    },
                    tickCount: 1,
                    ticksTextStyle:
                    const TextStyle(color: Colors.transparent, fontSize: 10),
                    tickBorderData: const BorderSide(color: Colors.transparent),
                    gridBorderData: BorderSide(color: Colors.orange, width: 2),
                  ),
                  duration: const Duration(milliseconds: 400),
                ) : SizedBox(),
              ),
            ],
          ),
          ),
        ), 
                
          
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
