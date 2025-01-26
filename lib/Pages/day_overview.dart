import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:menta_track/database_helper.dart';
import '../main.dart';
import '../termin.dart';
import 'week_plan_view.dart';

//Confetti package: https://pub.dev/packages/confetti

class DayOverviewPage extends StatefulWidget {
  final String weekKey;
  final String weekDayKey;

  const DayOverviewPage({
    super.key,
    required this.weekKey,
    required this.weekDayKey
  });

  @override
  DayOverviewState createState() => DayOverviewState();
}

class DayOverviewState extends State<DayOverviewPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Termin> termineForThisDay = [];

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
      int tasksDoneInt = 0;

      for(Termin t in termineForThisDay){
        if(t.answered){
          tasksDoneInt++;
          print(t.toString());
          if(t.question1 == 6){
            favoriteTasks = "$favoriteTasks - ${t.terminName} \n";
          }
          if(t.question2 == 6){
            calmTasks = "$calmTasks - ${t.terminName} \n";
          }
          if(t.question3 == 6){
            helpingTasks = "$helpingTasks - ${t.terminName} \n";
          }
        }
      }
      tasksDoneString = "$tasksDoneInt / ${termineForThisDay.length} \n also \n ${(tasksDoneInt/termineForThisDay.length*100).round()}%";
      favoriteAnswers= [favoriteTasks,calmTasks,helpingTasks];
      setState(() {
        tasksDoneString;
        _controllerCenter.play();
        _controllerConstant.play();
      });
  }

  List<String> favoriteComments = [
    "Am besten ging es dir bei diesen Aktionen ${Emojis.smile_grinning_face_with_smiling_eyes}:\n\n",
    "Du warst hierbei am ruhigsten ${Emojis.smile_relieved_face}:\n\n",
    "Am meisten geholfen haben dir ${Emojis.body_flexed_biceps}: \n\n"];
  List<String> favoriteAnswers = [];

  Widget favoriteItems(int i) {
    return RichText( //besten gefallen
      text: TextSpan(
          style: TextStyle(
            fontSize: 24,
            color: Colors.grey[700],
          ),
          children: <TextSpan>[
            TextSpan(text: favoriteComments[i], style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: favoriteAnswers[i])
          ]
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Week Key"),
        backgroundColor: Colors.orangeAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
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
          },
        ),
      ),
      body:
      Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.7,
            focalRadius: -2,
            colors: [
            Colors.white,
            Colors.orangeAccent,
            ],)
          //image: DecorationImage( //TODO: Vielleicht hintergrundbild
          //image: AssetImage("assets/images/"),
          //fit: BoxFit.fill,
          ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: ConfettiWidget(
                  confettiController: _controllerCenter,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.25,
                  numberOfParticles: 35, // a lot of particles at once
                  gravity: 0.1,
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: ConfettiWidget(
                  confettiController: _controllerCenter,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.25,
                  numberOfParticles: 35, // a lot of particles at once
                  gravity: 0.1,
                ),
              ),
              Align(
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
              Align(
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
              SizedBox(height: 50,),
              RichText(
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
              SizedBox(height: 36),
              RichText(
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey[700],
                    ),
                    children: <TextSpan>[
                      TextSpan(text: "$tasksDoneString \n \n", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: "Termine geschafft")
                    ]
                ),
                textAlign: TextAlign.center,
              ),
              for(int i = 0; i < favoriteComments.length; i++)...{
                SizedBox(height: 20),
                favoriteItems(i),
              },
            ],
          ),
        ),
      )

    );
  }
}
