import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/termin.dart';

class QuestionPage extends StatefulWidget{
  final String weekKey;
  final String timeBegin;
  final String terminName;
  final bool isEditable;

  const QuestionPage({
    super.key,
    required this.weekKey,
    required this.timeBegin,
    required this.terminName,
    required this.isEditable});

  @override
  QuestionPageState createState() => QuestionPageState();

}

class QuestionPageState extends State<QuestionPage> {
  List<int> radioAnswers = [-1,-1,-1,-1]; //Hier deklariert um beim abfragen im Scaffholding keine outOfRange Exception zu bekommen
  List<String> questions = [
    "Konntest du den Termin wahrnehmen?",
    "Wie ist es dir bei dem Termin gegangen?",
    "Warst du dabei aufgeregt?",
    "Hat es dir gut getan den Termin einzuhalten?",
  ];
  TextEditingController textEditingController = TextEditingController();
  bool enteredText = false;
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
          });
        }
     }

  }

  //Speichert/Updated die Antworten in der Datenbank
  void saveAnswers() {
    Map<String, dynamic> updatedValues = {
      "question0": radioAnswers[0],
      "question1": radioAnswers[1],
      "question2": radioAnswers[2],
      "question3": radioAnswers[3],
      "comment": textEditingController.text,
      "answered": 1,
    };
    databaseHelper.updateEntry(widget.weekKey, timeBeginForDataBase, widget.terminName, updatedValues);
    Navigator.pop(context, "updated");
    //print(databaseHelper.getSpecificTermin(widget.weekKey, timeBeginForDataBase, widget.terminName).toString()); UpdateTest
  }

  //TODO: Evtl die Questions über einen for-loop generieren lassen, damit es ein bisschen aufgeräumter aussieht
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text(pageTitle,style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center( //crossAxisAlignment hat nicht funktioniert
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
                              onChanged: !widget.isEditable ? null : (value) {
                                setState(() {
                                  radioAnswers[0] = value as int;
                                });
                              },
                            ),
                          ],
                        );
                      }),
                    )
                  ],
                ),
              ),
              SizedBox(height: 16),
              if(radioAnswers[0] != -1)...{
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
                                height: 30,
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
                                onChanged: !widget.isEditable ? null : (value) {
                                  setState(() {
                                    print(value);
                                    radioAnswers[1] = value as int;
                                  });
                                },
                              ),
                            ],
                          );
                        }),
                      )
                    ],
                  ),
                )},
              SizedBox(height: 16),
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
                                height: 30,
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
                                onChanged: !widget.isEditable ? null : (value) {
                                  setState(() {
                                    radioAnswers[2] = value as int;
                                  });
                                },
                              ),
                            ],
                          );
                        }),
                      )
                    ],
                  ),
                )},
              SizedBox(height: 16),
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
                                height: 30,
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
                                onChanged: !widget.isEditable ? null : (value) {
                                  setState(() {
                                    radioAnswers[3] = value as int;
                                  });
                                },
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
                      enabled: widget.isEditable ? true : false,
                      maxLines: 5,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Dein feedback",
                      ),
                      onChanged: !widget.isEditable ? null : (value){
                        setState(() {
                          enteredText = textEditingController.text.isNotEmpty;
                        });
                      },
                    )],
                )
              },
              if(enteredText && widget.isEditable)...{
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context,"test"),
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: saveAnswers,
                      child: Text("Save"),
                    ),
                  ],
                ),
              }
            ],
          ),
        ),
      )
    );
  }
}