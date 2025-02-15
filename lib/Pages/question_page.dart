import 'package:action_slider/action_slider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/reward_pop_up.dart';
import 'package:menta_track/termin.dart';

class QuestionPage extends StatefulWidget{
  final String weekKey;
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
  final GlobalKey buttonKey = GlobalKey();
  List<int> radioAnswers = [-1,-1,-1,-1]; //Hier deklariert um beim abfragen im Scaffholding keine outOfRange Exception zu bekommen
  List<String> questions = [
    "Konntest du den Termin wahrnehmen?",
    "Wie ist es dir bei dem Termin gegangen?",
    "Warst du dabei aufgeregt?",
    "Hat es dir gut getan den Termin einzuhalten?",
  ];
  TextEditingController textEditingController = TextEditingController();
  bool tapedOnTextBox = false;
  bool isEditable = false;
  late bool istooEarly = false;
  DatabaseHelper databaseHelper = DatabaseHelper();
  late Termin termin;
  String pageTitle = "";
  String timeBeginForDataBase = "";

  @override
  void initState() {
    DateTime begin = DateTime.parse(widget.timeBegin);
    timeBeginForDataBase = begin.toIso8601String();
    getTermin(widget.weekKey, widget.timeBegin, widget.terminName);
    pageTitle = "${widget.terminName} am ${DateFormat("dd.MM.yy").format(begin)} um ${DateFormat("HH:mm").format(begin)}";
    super.initState();
  }

  //Holt sich den Termin und füllt die Questionpage mit den Antworten, falls er schon beantwortet wurde
  void getTermin(String weekKey, String timeBegin, String terminName) async {
     Termin? termin = await databaseHelper.getSpecificTermin(weekKey, timeBeginForDataBase, terminName);
     if(termin != null){
        this.termin = termin;
        if(termin.answered){ //Wenn hier true, müsste isEditable eigentlich immer false sein, da diese Info schon im WeekPlanView abgefragt wird. Diese Datenabfrage hier ist auch eher eine zusätzliche redundanz zur Sicherheit
          setState(() {
            radioAnswers[0] = termin.question0;
            radioAnswers[1] = termin.question1;
            radioAnswers[2] = termin.question2;
            radioAnswers[3] = termin.question3;
            textEditingController.text = termin.comment;

            isEditable = false;
          });
        } else {
          if(DateTime.now().isAfter(termin.timeEnd)){  //2 = Termin war schon, aber wurde noch nicht beantwortet
            isEditable = true;
          } else {
            istooEarly = true;
            isEditable = false;
          }
        }
     }
     setState(() {
       isEditable;
     });

  }

  //Speichert/Updated die Antworten in der Datenbank TODO: Reaktivieren!!!
  void saveAnswers() {
    //Map<String, dynamic> updatedValues = {
    //  "question0": radioAnswers[0],
    //  "question1": radioAnswers[1],
    //  "question2": radioAnswers[2],
    //  "question3": radioAnswers[3],
    //  "comment": textEditingController.text,
    //  "answered": 1,
    //};
    //checkIfExceptional(radioAnswers);
    //databaseHelper.updateEntry(widget.weekKey, timeBeginForDataBase, widget.terminName, updatedValues);
    Navigator.pop(context, "updated");
    //print(databaseHelper.getSpecificTermin(widget.weekKey, timeBeginForDataBase, widget.terminName).toString()); UpdateTest
  }

  void checkIfExceptional(List<int> radioAnswers) {
    for(int i = 1; i < radioAnswers.length; i++){ //starten bei 1 um die ja/später/nein frage zu überspringen
      if(radioAnswers[i] >= 6){
        databaseHelper.saveHelpingActivities(
            widget.terminName,
            i == 1 ? "good" : i == 2 ? "calm" : i == 3 ? "help" : "");
      }
    }
  }

  //TODO: Evtl die Questions über einen for-loop generieren lassen, damit es ein bisschen aufgeräumter aussieht
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text(pageTitle,style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.transparent),
      body: GestureDetector(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(istooEarly) Text("Es war noch nicht Zeit für den Termin, komm bitte später wieder :)"),
                //TODO: Text schöner machen und Falls schon beantwortet wurde evtl mascotchen mit Daumen hoc
                //Erste Frage
                if(!istooEarly) Center(
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
                SizedBox(height: 16),
                //Zweite Frage
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
                  )},
                SizedBox(height: 16),
                if(radioAnswers[3] != -1)...{
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Wenn du Lust hast kannst du hier einen kurzen Kommentar hinzufügen:",
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
                          labelText: "Dein feedback",
                        ),
                        onChanged: !isEditable ? null : (value){
                          setState(() {
                            //enteredText = textEditingController.text.isNotEmpty;
                          });
                        },
                        onTap:() => tapedOnTextBox = true,
                      )],
                  )
                },
                if(tapedOnTextBox && isEditable)...{
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ActionSlider.standard(
                          child: Text("Slide zum speichern", key: buttonKey),
                          action: (controller) async {
                            controller.loading();
                            await Future.delayed(const Duration(seconds: 2));
                            controller.success();
                            controller.reset();
                            RewardPopUp().show(
                                context,
                                "Danke ${Emojis.smile_smiling_face} \n\n "
                                    "Du hast dich mit deinen Emotionen außeinandergesetzt ${Emojis.smile_smiling_face_with_hearts} \n\n "
                                    "Das war wirklich stark von dir ${Emojis.body_flexed_biceps}",
                                buttonKey,
                                saveAnswers
                            );

                          },
                          stateChangeCallback:(actionsliderState1 ,actionSliderState2, actionSliderController1) {
                            print(actionsliderState1);
                            print(actionSliderState2.position); //TODO: Hier ist fortschritt, kann für animation von Baum benutzt werden
                            print(actionSliderController1);
                          },
                        ),
                        SizedBox(height: 16,),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade400),
                          child: Text("Abbrechen", style: TextStyle(fontSize: 16),),
                        ),
                        SizedBox(height: 16)
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
                      ],
                    ),
                  )

                }
              ],
            ),
          ),
        ),
        onTapDown: (ev) => {
          print("TAPPPP"),
          FocusScope.of(context).unfocus(),
        },
      )
    );
  }


}