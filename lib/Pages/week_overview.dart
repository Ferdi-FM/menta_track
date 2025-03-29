import 'package:action_slider/action_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/settings.dart';
import 'package:menta_track/fl_chart_graph.dart';
import 'package:menta_track/helper_utilities.dart';
import '../database_helper.dart';
import '../generated/l10n.dart';
import '../gif_progress_widget.dart';
import '../reward_pop_up.dart';
import '../termin.dart';

///Wochenübersichts-Seite

class WeekOverview extends StatefulWidget {
  final String weekKey; //weekKey als "yyyy-MM-dd" format
  final bool fromNotification;

  const WeekOverview({
    super.key,
    required this.weekKey,
    required this.fromNotification,
  });

  @override
  WeekOverviewState createState() => WeekOverviewState();
}

class WeekOverviewState extends State<WeekOverview> {
  late ConfettiController _controllerCenter;
  List<List<double>> meanLists = [[], [], []];
  List<String> favoriteAnswers = [];
  String name = "";
  int overallAnswered = 0;
  int totalTasks = 0;
  int totalTasksTillNow = 0;
  bool favoritesInThisWeek = false;
  bool isShowingMainData = true;
  bool isListAvailable = false;
  
  @override
  void initState() {
    getTermineForWeek();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 2));
    super.initState();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  ///Lädt die Daten für jeden Tag der Woche und fügt sie zusammen
  void getTermineForWeek() async{
    DateTime firstDay = DateTime.parse(widget.weekKey);
    totalTasks = await DatabaseHelper().getWeekTermineCount(widget.weekKey,false);
    totalTasksTillNow = await DatabaseHelper().getWeekTermineCount(widget.weekKey, true);
    String favoriteTasks = "";
    String calmTasks = "";
    String helpingTasks = "";
    SettingData data = await SettingsPageState().getSettings();
    name = data.name;

    for(int i = 0; i < 7;i++){ //Iteriert Tag für Tag um Den Mittelwert für jeden Tag zu bekommen
      String weekDayKey = DateFormat("yyyy-MM-dd").format(firstDay.add(Duration(days: i, hours: 1)));
      List<Termin> termine = await DatabaseHelper().getDayTermineAnswered(weekDayKey,true);
      int answeredCounter = termine.length;

      double goodMean = 0;
      double calmMean = 0;
      double didGoodMean = 0;

      for(Termin t in termine){
          overallAnswered++; //Könnte auch direkte SQL Abfrage sein, muss aber sowieso durch Tage iterieren
          String negative = "";
          if(t.doneQuestion == 2){
            negative = S.current.toNotDoIt;
          } else {
            negative = "";
          }

          goodMean = goodMean + (t.goodMean + 1);
          calmMean = calmMean + (t.calmMean + 1);
          didGoodMean = didGoodMean + (t.helpMean + 1);

          if (t.goodMean == 6 && !favoriteTasks.contains(t.terminName)) {
            favoriteTasks = "$favoriteTasks • ${t.terminName} $negative\n";
          }
          if (t.calmMean == 6 && !calmTasks.contains(t.terminName)) {
            calmTasks = "$calmTasks • ${t.terminName} $negative\n";
          }
          if (t.helpMean == 6 && !helpingTasks.contains(t.terminName)) {
            helpingTasks = "$helpingTasks • ${t.terminName} $negative\n";
          }
      }
      goodMean = goodMean/answeredCounter;
      calmMean = calmMean/answeredCounter;
      didGoodMean = didGoodMean/answeredCounter;

      meanLists[0].add(goodMean);
      meanLists[1].add(calmMean);
      meanLists[2].add(didGoodMean);
    }

    setState(() {
      favoriteAnswers = [favoriteTasks.trimRight(), calmTasks.trimRight(), helpingTasks.trimRight()];
      if(favoriteTasks != "" || calmTasks != "" || helpingTasks != "") favoritesInThisWeek = true;
      isListAvailable = true;
    });
  }

  ///Erstellt die Confetti-Widgets
  Widget buildConfettiWidgets() {
    if (!widget.fromNotification) {
      return SizedBox(); // Wenn eine der Bedingungen nicht erfüllt ist, kein Confetti anzeigen
    }
    _controllerCenter.play();
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
        pauseEmissionOnLowFrameRate: true,
      ),
    );
  }

  ///Erstellt die Legende für den Graph
  Widget createDescription(String text, Color color){
    return Row(
        spacing: 15,
        children: [
          const SizedBox(width: 8),
          Container(
            width: 12,  // Größe des Kreises
            height: 12,
            decoration: BoxDecoration(
              color: color, // Farbe des Punktes
              shape: BoxShape.circle,  // Kreisform
            ),
          ),
          // Abstand zwischen dem Punkt und dem Text
          Text(
            text,
            style: TextStyle(fontSize: 16),  // Textstil nach Wunsch anpassen
          ),
        ]
    );
  }

  ///Öffnet Belohnungs-PopUp
  void openRewardPopUp() async{
    String? result = await RewardPopUp().show(
        context,
        S.of(context).week_reward_message,
        widget.weekKey,
        true
    );
    if(result == "confirmed"){
      leavePage();
    }
  }

  ///Verlässt seite ohne probleme mit context in async
  void leavePage(){
    Navigator.pop(context);
  }

  Widget getText() {
    if(DateTime.now().isBefore(DateTime.parse(widget.weekKey))){
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(text: S.of(context).weekOverView_tooEarly, style: TextStyle(fontSize: 24))
          ],
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        textAlign: TextAlign.center,
      );
    }
    return overallAnswered > 0 ? RichText(
      text: TextSpan(
          style: TextStyle(
            fontSize: 24,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          children:  [
            TextSpan(text: S.current.weekOverView_summary),
            TextSpan(text: "$overallAnswered\n", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
            TextSpan(text: S.current.weekOverView_summary_part2(overallAnswered)),
            TextSpan(text: Utilities().getRandomisedEncouragement(widget.fromNotification, name), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            TextSpan(text: S.current.weekOverView_leftAnswers(totalTasksTillNow-overallAnswered),style: TextStyle(fontSize: 16)),
            TextSpan(text: S.current.weekOverView_scroll, style: TextStyle(fontSize: 14))]
      ),
      textAlign: TextAlign.center,
    ) : RichText(
      text: TextSpan(
        children: [
          TextSpan(text: S.of(context).weekOverView_noAnswers, style: TextStyle(fontSize: 24))
        ],
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return  PopScope(
        canPop: false, // Ermöglicht das Verlassen der Seite
        onPopInvokedWithResult: (bool didPop, result) {
      if (!didPop) {
        leavePage();
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text(Utilities().convertWeekKeyToDisplayPeriodString(widget.weekKey))),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
        foregroundColor: Colors.white60,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            leavePage();
          },
        ),
        actions: [
          Utilities().getHelpBurgerMenu(context, "WeekOverView")
        ],
      ),
      body: !isListAvailable ? Center(child: CircularProgressIndicator()) : Stack(
        children: [ShaderMask(
          shaderCallback: (Rect bounds) {
          return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
          stops: [0.0, 0.08, 0.9, 1.0],
          ).createShader(bounds);
          },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView( //wenn Liste noch nicht geladen ist, wird ladekreis angezeigt
              physics: ScrollPhysics(),
              child: Padding(padding: EdgeInsets.symmetric(vertical: 40,horizontal: 10),
                child: Column(
                  children: [
                    SizedBox(height: 16,),
                    FittedBox(
                      child: Text(
                        Utilities().convertWeekKeyToDisplayPeriodString(widget.weekKey),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    getText(),
                    SizedBox(height: 20,),
                    if(favoritesInThisWeek) Material(//zuerst favoriteAnswers.isNotEmpty, durch es ist aber immer mindestens ["","",""] was als voll gezählt wird
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
                                  child: Text("${S.current.special_activities}\n",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Theme.of(context).primaryColor.withAlpha(200), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2,)),
                                ),
                                for (int i = 0; i < 3; i++) ...{ //favoriteComments.length
                                  Utilities().favoriteItems(i, favoriteAnswers, context),
                                },
                              ],
                          ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if(overallAnswered != 0)GifProgressWidget(
                      progress: overallAnswered/totalTasks,
                      startFrame: 0,
                      finished: () => {},
                      forRewardPage: false,
                    ),
                    SizedBox(height: 20,),
                    if(overallAnswered != 0)Column(
                      children: [
                        SizedBox(height: 15,),
                        Text(
                          S.current.weekly_values,
                          style: TextStyle(color: Theme.of(context).primaryColor.withAlpha(200), fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        createDescription(S.of(context).legend_Msg0, Colors.green),
                        createDescription(S.of(context).legend_Msg1, Colors.orange),
                        createDescription(S.of(context).legend_Msg2, Colors.blue),
                        SizedBox(
                          height: 12,
                        ),
                        Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 15),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height*0.4,
                                  width: MediaQuery.of(context).size.width*0.9,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 26, left: 0),
                                    child: isListAvailable
                                        ? FlChartGraph(isShowingMainData: isShowingMainData, meanList: meanLists, weekKey: widget.weekKey, context: context,)
                                        : SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 10,
                              child: IconButton(
                                iconSize: 40,
                                icon: Icon(
                                  Icons.refresh,
                                  color: Theme.of(context).primaryColor.withValues(alpha: isShowingMainData ? 1.0 : 0.5),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isShowingMainData = !isShowingMainData;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 36,),
                    widget.fromNotification ? ActionSlider.standard( //Wenn von Notification gekommen wird
                      child:Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10), //Damit der Thumb nicht des Text überdeckt
                          child: FittedBox(
                              child: Text(S.current.understood, key: GlobalKey(debugLabel: "actKey")),
                          )
                      ),
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
                        HapticFeedback.lightImpact();
                      },
                    ) : ElevatedButton(
                        style: ElevatedButton.styleFrom(minimumSize: Size(200,50),),
                        onPressed: Navigator.of(context).pop,
                        child: Text(S.current.back)),
                    SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
          ),
          buildConfettiWidgets(),
        ],
      )
    )
    );
  }
}

