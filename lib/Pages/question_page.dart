import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/reward_pop_up.dart';
import 'package:menta_track/termin.dart';
import '../generated/l10n.dart';

//TODO?: Man könnte ziemlich einfach den Termin im nachhinein wieder bearbeitbar machen, wenn gewünscht

class QuestionPage extends StatefulWidget{
  final String weekKey; ///"MM-dd-yyyy"
  final String timeBegin;
  final String terminName;

  const QuestionPage({
    super.key,
    required this.weekKey,
    required this.timeBegin,
    required this.terminName,});

  @override
  QuestionPageState createState() => QuestionPageState();
}

class QuestionPageState extends State<QuestionPage> {
  List<int> radioAnswers = [-1,-1,-1,-1]; //Hier deklariert um beim abfragen im Scaffholding keine outOfRange Exception zu bekommen
  TextEditingController textEditingController = TextEditingController();
  bool isEditable = false;
  late bool isTooEarly = false;
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    getTermin();
    super.initState();
  }

  //Holt sich den Termin und füllt die Questionpage mit den Antworten, falls er schon beantwortet wurde
  void getTermin() async {
     Termin? termin = await databaseHelper.getSpecificTermin(widget.weekKey, widget.timeBegin, widget.terminName);
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
          if(DateTime.now().isAfter(termin.timeBegin.add(Duration(minutes: 10)))){
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

  //Speichert/Updated die Antworten in der Datenbank
  void saveAnswers() {
    Map<String, dynamic> updatedValues = {
      "doneQuestion": radioAnswers[0],
      "goodQuestion": radioAnswers[1],
      "calmQuestion": radioAnswers[2],
      "helpQuestion": radioAnswers[3],
      "comment": textEditingController.text,
      "answered": 1,
    };
    //print("Updatedvalues: $updatedValues");
    checkIfExceptional(radioAnswers);
    databaseHelper.updateEntry(widget.weekKey, widget.timeBegin, widget.terminName, updatedValues);
    databaseHelper.updateActivities(widget.weekKey);
    Navigator.pop(context, "updated");
    //print(databaseHelper.getSpecificTermin(widget.weekKey, timeBeginForDataBase, widget.terminName).toString()); UpdateTest
  }

  void checkIfExceptional(List<int> radioAnswers) {
    for(int i = 1; i < radioAnswers.length; i++){ //starten bei 1 um die ja/später/nein frage zu überspringen
      if(radioAnswers[i] >= 6){
        databaseHelper.saveHelpingActivities(
            widget.terminName,
            i == 1 ? "good" : i == 2 ? "calm" : i == 3 ? "help" : "",
            radioAnswers[0] == 2 ? false : true);
      }
    }
  }

  void openRewardPopUp() async{
    String? result = await RewardPopUp().show(
        context,
        S.of(context).questionPage_rewardMsg,
        widget.weekKey,
        false
    );
    if(result == "confirmed"){
      //for(int i = 0; i < radioAnswers.length; i++){
      //  print(radioAnswers[i]);
      //}
      saveAnswers();
    }
  }

  Widget buildQuestion(
      int questionIndex,
      //String questionText,
      //int groupValue,
      //int questionIndex,
      //String labelStart,
      //String labelEnd,
      bool firstQuestion) {
    List<String> questions = [
      S.of(context).questionPage_q1,
      S.of(context).questionPage_q2,
      S.of(context).questionPage_q3,
      S.of(context).questionPage_q4,
    ];
    List<String> labelStart = [
      "",
      S.of(context).questionPage_a1s,
      S.of(context).questionPage_a2s,
      S.of(context).questionPage_a3s];
    List<String> labelEnd = [
      "",
      S.of(context).questionPage_a1e,
      S.of(context).questionPage_a2e,
      S.of(context).questionPage_a3e,];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(questions[questionIndex], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
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
                children: [
                  RichText(
                    text: TextSpan(
                        children: [
                          TextSpan(text: "${widget.terminName}  \n", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "${S.of(context).am} ${S.current.displayADate(DateTime.parse(widget.timeBegin))} "
                              "${S.of(context).um} ${S.current.displayATime(DateTime.parse(widget.timeBegin))}")
                        ],
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 18)),
                  ),
                  if(!isEditable && !isTooEarly) SizedBox(width: 15,),
                  if(!isEditable && !isTooEarly) Icon(Icons.check,size: 35, color: Colors.green,),
                  if(!isEditable && !isTooEarly) SizedBox(width: 15,),
                ]
            ) ,
          ), //Text(pageTitle,style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.transparent),
      body: GestureDetector(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 15,),
                //Erste Frage
                //!isEditable ? ÜBERSICHT ÜBER WERTE?
                !isTooEarly ? buildQuestion(0, true) : Text("${widget.terminName} ist ${S.current.am} ${DateFormat("dd.MM").format(DateTime.parse(widget.timeBegin))} ${S.current.um} ${DateFormat("HH:mm").format(DateTime.parse(widget.timeBegin))}\n${S.of(context).questionPage_too_early}", style: TextStyle(fontSize: 24),textAlign: TextAlign.center,),
                SizedBox(height: 16),
                //Frage 2,3,4
                for (int i = 1; i < 4; i++)
                  if (radioAnswers[i - 1] != -1) ...[
                    buildQuestion(i, false),
                    SizedBox(height: 16),
                  ],
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
                        onChanged: !isEditable ? null : (value){
                          setState(() {
                            //enteredText = textEditingController.text.isNotEmpty;
                          });
                        },
                        onTap:() => {} //tapedOnTextBox = true,
                      )],
                  )
                },
                //Buttons & Sliders
                if(radioAnswers[3] != -1 && isEditable)...{
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                          ActionSlider.standard(
                            child: Text(S.of(context).questionPage_save, key: GlobalKey()),
                            action: (controller) async {
                              controller.loading();
                              await Future.delayed(const Duration(seconds: 1));
                              controller.success();
                              controller.reset();
                              HapticFeedback.lightImpact();
                              openRewardPopUp();
                            },
                            stateChangeCallback:(actionsliderState1 ,actionSliderState2, actionSliderController1) {
                               // print(actionSliderState2.position); //Prozent des Sliders
                              HapticFeedback.vibrate();
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
                if(!isEditable || isTooEarly)...{ //Zurückknopf
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(minimumSize: Size(200,50),),
                    child: Text(S.of(context).back, style: TextStyle(fontSize: 16),)
                  ),
                  SizedBox(height: 16)
                },
              ],
            ),
          ),
        ),
        onTapDown: (ev) => {
          FocusScope.of(context).unfocus(),
        },
      )
    );
  }
}

//Alternative
/*
    Alternative erste Anzeige von den Fragen
    /*//Zweite Frage
    if (radioAnswers[0] != -1) buildQuestion(questions[1], radioAnswers[1], 1, "sehr \n schlecht", "sehr \n gut", false),
    SizedBox(height: 16),
    //Dritte Frage
    if (radioAnswers[1] != -1) buildQuestion(questions[2], radioAnswers[2], 2, "sehr \n aufgeregt", "sehr \n ruhig",false),
    SizedBox(height: 16),
    //Vierte Frage
    if (radioAnswers[2] != -1) buildQuestion(questions[3], radioAnswers[3], 3, "wenig \n geholfen", "sehr \n geholfen",false),
    SizedBox(height: 16),*/
    //Textbox
 */
/*Anzeige von Termin
              Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(15),
                      color: !isEditable ? Colors.lightBlueAccent.shade400 : Theme.of(context).listTileTheme.tileColor,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(20),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            //Positioned( Sieht nicht gut aus
                            //  top: -30,
                            //    right: -30,
                            //    child:Icon(Icons.check, color: Colors.green, size: 36,),
                            //),
                            RichText(
                              text:TextSpan(
                                  children: [
                                    TextSpan(text: pageTitle),
                                  ]
                              ),
                              textAlign: TextAlign.start,
                              textScaler: TextScaler.linear(1.5),
                            ),
                          ],
                        )
                      ),
                    ),*/
/* ALTE VERSION  Center(
                  child: Column(
                    children: [
                      Text(questions[0],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 70,
                        children: List.generate(3, (index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 15,
                                child: Text(
                                  index == 0 ? "Ja"
                                      : index == 1 ? "Später"
                                      : "Nein",
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Radio<int>(
                                value: index,
                                groupValue: radioAnswers[0],
                                onChanged: !isEditable ? null : (value) {
                                  setState(() {
                                    radioAnswers[0] = value as int;
                                  });
                                },
                                activeColor: Theme.of(context).primaryColor,
                              ),
                            ],
                          );
                        }),
                      )
                    ],
                  ),
                ),
                if(radioAnswers[0] != -1)...{ //Zeigt es erst an, wenn Frage 1 beantwortet wurde
                  Center( //crossAxisAlignment hat nicht funktioniert
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(questions[1],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        Wrap(
                          children: List.generate(7, (index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 35,
                                  child: Text(
                                    index == 0 ? "sehr \n schlecht"
                                        : index == 6 ? "sehr \n gut"
                                        : "\n",
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Radio<int>(
                                  value: index,
                                  groupValue: radioAnswers[1],
                                  onChanged: !isEditable ? null : (value) {
                                    setState(() {
                                      print(value);
                                      radioAnswers[1] = value as int;
                                    });
                                  },
                                  activeColor: Theme.of(context).primaryColor,
                                ),
                              ],
                            );
                          }),
                        )
                      ],
                    ),
                  )},
                SizedBox(height: 16),
                //Dritte Frage
                if(radioAnswers[1] != -1)...{
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(questions[2],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        Wrap(
                          children: List.generate(7, (index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 35,
                                  child: Text(
                                    index == 0 ? "sehr \n aufgeregt"
                                        : index == 6 ? "sehr \n ruig"
                                        : "\n",
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Radio<int>(
                                  value: index,
                                  groupValue: radioAnswers[2],
                                  onChanged: !isEditable ? null : (value) {
                                    setState(() {
                                      radioAnswers[2] = value as int;
                                    });
                                  },
                                  activeColor: Theme.of(context).primaryColor,
                                ),
                              ],
                            );
                          }),
                        )
                      ],
                    ),
                  )},
                SizedBox(height: 16),
                //vierte Frage
                if(radioAnswers[2] != -1)...{
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(questions[3],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        Wrap(
                          children: List.generate(7, (index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 35,
                                  child: Text(
                                    index == 0 ? "wenig \n geholfen"
                                        : index == 6 ? "sehr \n geholfen"
                                        : "\n",
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Radio<int>(
                                  value: index,
                                  groupValue: radioAnswers[3],
                                  onChanged: !isEditable ? null : (value) {
                                    setState(() {
                                      radioAnswers[3] = value as int;
                                    });
                                  },
                                  activeColor: Theme.of(context).primaryColor,
                                ),
                              ],
                            );
                          }),
                        )
                      ],
                    ),
                  )},*/


                  /*ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade400),
                          child: Text("Abbrechen", style: TextStyle(fontSize: 16),),
                        ),
                        ElevatedButton(
                          key: buttonKey,
                          onPressed: () => {
                            RewardPopUp().show(
                                context,
                                    "Danke ${Emojis.smile_smiling_face} \n\n "
                                    "Du hast dich mit deinen Emotionen außeinandergesetzt ${Emojis.smile_smiling_face_with_hearts} \n\n "
                                    "Das war wirklich stark von dir ${Emojis.body_flexed_biceps}",
                                buttonKey,
                                saveAnswers
                            ),
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColorLight),
                          child: Text("Speichern", style: TextStyle(fontSize: 16)),
                        ),*/