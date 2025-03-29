import 'dart:math';
import 'package:action_slider/action_slider.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/settings.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/main.dart';
import 'package:menta_track/notification_helper.dart';
import 'package:menta_track/reward_pop_up.dart';
import 'package:menta_track/termin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/l10n.dart';
import '../helper_utilities.dart';

class QuestionPage extends StatefulWidget{
  final String weekKey; ///"MM-dd-yyyy"
  final String timeBegin;  //DateTime.toIso... ("MM-dd-yyyyT012:00:00")
  final String terminName;
  final String timeEnd; //DateTime.toIso...

  const QuestionPage({
    super.key,
    required this.weekKey,
    required this.timeBegin,
    required this.timeEnd,
    required this.terminName});

  @override
  QuestionPageState createState() => QuestionPageState();
}

class QuestionPageState extends State<QuestionPage> {
  List<int> radioAnswers = [-1,-1,-1,-1]; //Hier deklariert um beim abfragen im Scaffholding keine Exception zu bekommen
  TextEditingController textEditingController = TextEditingController();
  bool isEditable = false;
  bool isBeingEdited = false;
  bool hapticFeedback = false;
  late bool isTooEarly = false;
  late bool slightlyTooEarly = false;
  DatabaseHelper databaseHelper = DatabaseHelper();
  //Widget _themeIllustration = SizedBox();
  String name = "";

  @override
  void initState() {
    getTermin();
    loadTheme();
    super.initState();

  }

  void loadTheme() async{
    hapticFeedback = await SettingsPageState().getHapticFeedback();
    //Falls man eine eigene Illustration für die FeedbackSeite einabauen wollte
    //Widget image = SizedBox();
    //if(mounted) image = await ThemeHelper().getRewardImage();
    //setState(() {
    //  _themeIllustration = image;
    //});
  }

  ///Holt sich den Termin und füllt die Questionpage mit den Antworten, falls er schon beantwortet wurde
  void getTermin() async {
    final pref = await SharedPreferences.getInstance();
     Termin? termin = await databaseHelper.getSpecificTermin(widget.weekKey, widget.timeBegin, widget.terminName);
     name = pref.getString("userName") ?? "";
     if(termin != null){
        if(termin.answered){ //Wenn hier true, müsste isEditable eigentlich immer false sein, da diese Info schon im WeekPlanView abgefragt wird. Diese Datenabfrage hier ist auch eher eine zusätzliche redundanz zur Sicherheit
          setState(() {
            radioAnswers[0] = termin.doneQuestion;
            radioAnswers[1] = termin.goodMean;
            radioAnswers[2] = termin.calmMean;
            radioAnswers[3] = termin.helpMean;
            textEditingController.text = termin.comment;
            isEditable = false;
          });
        } else {
          int differenceInMinutes = termin.timeBegin.add(Duration(minutes: 10)).difference(DateTime.now()).inMinutes;
          if(differenceInMinutes < 10 && !differenceInMinutes.isNegative){
            isEditable = false;
            isTooEarly = true;
            slightlyTooEarly = true;
          } else if(differenceInMinutes.isNegative) {
            isEditable = true;
          } else {
            isEditable = false;
            isTooEarly = true;
          }
        }
     } 
     setState(() {
       isEditable;
     });
  }

  ///Speichert/Updated die Antworten in der Datenbank
  void saveAnswers() {
    Map<String, dynamic> updatedValues = {
      "doneQuestion": radioAnswers[0],
      "goodQuestion": radioAnswers[1],
      "calmQuestion": radioAnswers[2],
      "helpQuestion": radioAnswers[3],
      "comment": textEditingController.text,
      "answered": 1,
    };
    databaseHelper.updateEntry(widget.weekKey, widget.timeBegin, widget.terminName, updatedValues);
    databaseHelper.updateActivities(widget.weekKey);
    if(!isBeingEdited) {
      Navigator.pop(context, "updated");
    } else {
      setState(() {
        isBeingEdited = false;
        isEditable = false;
      });
    }
  }

  ///Öffnet das Belohnung-PopUp
  void openRewardPopUp() async{
    List<String> messages = [
      S.current.questionPage_rewardMsg,
      S.current.questionPage_rewardMsg2,
      S.current.questionPage_rewardMsg3,
      S.current.questionPage_rewardMsg4,
      S.current.questionPage_rewardMsg5,
    ];

    String? result = await RewardPopUp().show(
        context,
        messages[Random().nextInt(messages.length)],
        widget.weekKey,
        false
    );
    if(result == "confirmed"){
      saveAnswers();
    }
  }

  ///Erstellt ein Fragen-Widget abhängig von Index im for-Loop, kann so theoretisch sehr leicht erweitert werden
  ///Man könnte auch noch die Scala variabel anpassbar machen
  Widget buildQuestion(
      int questionIndex,
      bool firstQuestion) {
    List<String> questions = [
      S.of(context).questionPage_q1,
      S.of(context).questionPage_q2,
      S.of(context).questionPage_q3,
      S.of(context).questionPage_q4
    ];
    List<String> noQuestions = [
      S.of(context).questionPage_q1,
      S.current.questionPage_noQ1,
      S.current.questionPage_noQ2,
      S.current.questionPage_noQ3,
    ];
    List<String> labelStart = [
      "",
      S.of(context).questionPage_a1s,
      S.of(context).questionPage_a2s,
      S.of(context).questionPage_a3s
    ];
    List<String> labelEnd = [
      "",
      S.of(context).questionPage_a1e,
      S.of(context).questionPage_a2e,
      S.of(context).questionPage_a3e
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(questionIndex > 0 && radioAnswers[0] == 2 ? noQuestions[questionIndex]:questions[questionIndex], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(firstQuestion ? 3 : 7, (index) {
              return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                        child: FittedBox(
                          fit: BoxFit.contain ,
                          child: firstQuestion ?
                          Text(
                            index == 0 ? S.of(context).questionPage_a0s
                                : index == 1 ? S.of(context).questionPage_a0m
                                : index == 2 ? S.of(context).questionPage_a0e : "",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.7),
                            textAlign: TextAlign.center,
                          ) : Text(
                            index == 0 ? labelStart[questionIndex] :
                            index == 6 ? labelEnd[questionIndex] : " \n ",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, height: 1.1),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                       SizedBox(
                         width: MediaQuery.of(context).size.width,
                         //fit: BoxFit.contain,
                          child: Radio<int>(
                            value: index,
                            groupValue: radioAnswers[questionIndex],
                            onChanged: !isEditable ? null : (value) {
                              if(hapticFeedback) HapticFeedback.lightImpact();
                              setState(() {
                                radioAnswers[questionIndex] = value as int;
                              });
                            },
                            activeColor: Theme.of(context).primaryColor,
                          ),
                       ),
                    ],
                )
              );
            }),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Row(
                spacing: 25,
                children: [
                  RichText(
                    text: TextSpan(
                        children: [
                          TextSpan(text: "${widget.terminName}  \n", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text:  "${S.of(context).am} ${S.current.displayADate(DateTime.parse(widget.timeBegin))} "
                                          "${S.of(context).um} ${S.current.displayATime(DateTime.parse(widget.timeBegin))}")
                        ],
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 18)),
                  ),
                  if(!isEditable && !isTooEarly) Icon(Icons.check,size: 35, color: Colors.green,),
                ]
            ) ,
          ),
          backgroundColor: Colors.transparent,
        actions: [
          if(isBeingEdited || isEditable || isTooEarly) Padding( //Nicht die Funktion aus Utilities, da ich auf hinzufügen von Eintrag reagieren muss, was nicht durch RouteAware/DidPopNext aufgefangen wird
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
                    onPressed: () => Utilities().showHelpDialog(context, "QuestionPage", name),
                  ),
                  MenuItemButton(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.add_to_home_screen),
                          SizedBox(width: 10),
                          Text(S.current.addToCalendar)
                        ],
                      ),
                    ),
                    onPressed: () async {
                      final Event event = Event(
                        title: widget.terminName,
                        startDate: DateTime.parse(widget.timeBegin),
                        endDate: DateTime.parse(widget.timeEnd),
                      );
                      Add2Calendar.addEvent2Cal(event);
                    },
                  ),
                  MenuItemButton(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 10),
                              Text(S.current.deleteActivity)
                            ],
                          ),
                        ),
                        onPressed: () async {
                          String title =" ${widget.terminName} ${S.current.am} ${DateFormat("dd.MM").format(DateTime.parse(widget.timeBegin))} ${S.current.um} ${DateFormat("HH:mm").format(DateTime.parse(widget.timeBegin))}";
                          bool? result = await Utilities().showDeleteDialog(title, false, context);
                          if(result != null){
                            if(result){
                              NotificationHelper().unscheduleTerminNotification(widget.timeBegin, widget.timeEnd, widget.terminName);
                              DatabaseHelper().dropTermin(widget.weekKey, widget.terminName, widget.timeBegin);
                              navigatorKey.currentState?.pop("updated");
                            }
                          }

                        },
                      )
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
                    child: Icon(Icons.menu, size: 30, color: Theme.of(context).appBarTheme.foregroundColor,),
                  );
                }
            ),
          )
        ],
      ),
      body: GestureDetector(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //if(!isEditable && !isTooEarly) Column(
                //  spacing: 15,
                //  children: [
                //    //Kontext abhängig, wird aber nur minimal angepasst, sodass "Nein" Antworten nicht als anders auffallen
                //    if(radioAnswers[0] == 0) Text(S.current.questionPage_WellDone2(Random().nextInt(3),name != "" ? " $name":""), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.lightGreen),),
                //    if(radioAnswers[0] != 0) Text(S.current.questionPage_WellDone(Random().nextInt(3),name != "" ? " $name":""), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.lightGreen),),
                //    _illustrationImage
                //  ],
                //),
                SizedBox(height: 20),
                ///Erste Frage (Falls Zeitpunkt gekommen ist, ansonsten Info)
                isTooEarly ? Text(!slightlyTooEarly ?
                        S.current.questionPage_too_early1(DateTime.parse(widget.timeBegin), DateTime.parse(widget.timeBegin),0,widget.terminName) :
                        S.current.questionPage_too_early1(DateTime.parse(widget.timeBegin), DateTime.parse(widget.timeBegin),1,widget.terminName),
                    style: TextStyle(fontSize: 24),textAlign: TextAlign.center,)
                : buildQuestion(0, true),
                SizedBox(height: 16),
                ///Frage 2,3,4
                for (int i = 1; i < 4; i++)
                  if (radioAnswers[i - 1] != -1) ...[
                    buildQuestion(i, false),
                    SizedBox(height: 16),
                  ],
                ///TextFeld für Kommentar
                if(radioAnswers[3] != -1)...{
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).questionPage_comment,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      TextField(
                        enabled: isEditable,
                        maxLines: 5,
                        scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 18*5),
                        controller: textEditingController,
                        decoration: InputDecoration(
                          enabledBorder:  OutlineInputBorder(borderSide:  BorderSide(color: Theme.of(context).primaryColorLight, width: 2)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.5)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColorLight)),
                          labelText: S.of(context).questionPage_commentLabel,
                        ),
                      )],
                  )
                },
                ///Slider falls es bearbeitbar/beantwortbar ist
                if(radioAnswers[3] != -1 && isEditable && !isBeingEdited)...{
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                          ActionSlider.standard(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10), //Damit der Thumb nicht des Text überdeckt
                                child: FittedBox(
                                    child: Text(S.of(context).questionPage_save, key: GlobalKey())
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
                            stateChangeCallback:(actionSliderState1 ,actionSliderState2, actionSliderController1) {
                              HapticFeedback.lightImpact();
                            },
                          ),
                        SizedBox(height: 16,),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(minimumSize: Size(200,50),),
                          child: Text(S.of(context).cancel, style: TextStyle(fontSize: 16),),
                        ),
                        SizedBox(height: 16)
                      ],
                    ),
                  )
                },
                ///Buttons, falls es schon beantwortet wurde
                if(!isEditable || isTooEarly || isBeingEdited)...{
                  Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 30,left: 10,right: 10),
                    child: Row(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if(!isTooEarly) !isBeingEdited ? Expanded(
                          child: ElevatedButton(
                              onPressed: (){
                                if(hapticFeedback) HapticFeedback.lightImpact();
                                setState(() {
                                  isEditable = true;
                                  isBeingEdited = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).buttonTheme.colorScheme?.surface.withAlpha(50)),
                              child: AutoSizeText(S.current.edit, style: TextStyle(fontSize: 16), maxLines: 1,)
                          ),
                        ): Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                  if(hapticFeedback) HapticFeedback.lightImpact();
                                  saveAnswers();
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).buttonTheme.colorScheme?.primary.withAlpha(80)),
                              child: AutoSizeText(S.current.save, style: TextStyle(fontSize: 16), maxLines: 1,)
                          ),
                        ),
                         Expanded(
                          child: !isBeingEdited ? ElevatedButton(
                              onPressed: () {
                                if(hapticFeedback) HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                              //style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColorLight),
                              child: AutoSizeText(S.of(context).back, style: TextStyle(fontSize: 16), maxLines: 1,)
                          ) : ElevatedButton(
                              onPressed: (){
                                if(hapticFeedback) HapticFeedback.lightImpact();
                                setState(() {
                                  isEditable = false;
                                  isBeingEdited = false;
                                });
                                getTermin();
                              },
                              child: AutoSizeText(S.of(context).cancel, style: TextStyle(fontSize: 16), maxLines: 1,)
                          ),
                         )
                      ],
                    ),
                  )
                }
              ],
            ),
          ),
        ),
        onTapDown: (ev) => {
          FocusScope.of(context).unfocus(), //Um focus von TextField zu entfernen
        },
      )
    );
  }
}

/* Falls eigenes Theme eingebaut werden soll
    Text(
      "Wie ist es dir gegangen :   ${radioAnswers[1]}\n"
      "Wie ruhig warst du :   ${radioAnswers[2]}\n"
      "Wie sehr hat es geolfen :   ${radioAnswers[3]}\n",
      style: TextStyle(fontSize: 20),
    )
    if(!isEditable && !isTooEarly && _themeIllustration != SizedBox()) SizedBox(
      height: MediaQuery.of(context).size.width/3,
      width: MediaQuery.of(context).size.width/3,
      child: _themeIllustration,
    ),*/