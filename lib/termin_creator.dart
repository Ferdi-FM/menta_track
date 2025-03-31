import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/main.dart';
import 'generated/l10n.dart';

///Klasse zum manuellen Hinzufügen von Aktivitäten zu einer Woche

class TerminDialog {
  final String weekKey;

  final String? existingName;
  final DateTime? existingStartTime;
  final DateTime? existingEndTime;
  final bool? updatingEntry;
  //Option zum verschieben von Terminen einfügen

  const TerminDialog({
    required this.weekKey,
    this.existingStartTime,
    this.existingEndTime,
    this.existingName,
    this.updatingEntry
  });

  Future<Map<String,dynamic>?> show(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate;
    TimeOfDay startTime;
    TimeOfDay endTime;
    bool isNameValid = true;
    Color? tileColor;

    if(existingStartTime != null){
      selectedDate = DateTime(existingStartTime!.year, existingStartTime!.month, existingStartTime!.day, 0,0);
      startTime = TimeOfDay.fromDateTime(existingStartTime!);
      endTime = TimeOfDay.fromDateTime(existingEndTime!);
      nameController.text = existingName!;
    } else {
      DateTime weekKeyDate = DateTime.parse(weekKey);
      selectedDate = DateTime.parse(weekKey);
      if(DateTime.now().isAfter(weekKeyDate) && DateTime.now().isBefore(weekKeyDate.add(Duration(days: 7)))){
          selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0);
      }

      startTime = TimeOfDay.fromDateTime(DateTime.now());
      endTime = TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 30)));
    }

    Future<DateTime?> pickDate(DateTime? initialDate) async {
      return await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.parse(weekKey),
        lastDate: DateTime.parse(weekKey).add(Duration(days: 6)),
        barrierDismissible: false,
      );
    }

    Future<TimeOfDay?> pickTime(TimeOfDay? initialTime) async {
      return await showTimePicker(
        context: context,
        initialTime: initialTime ?? TimeOfDay.now(),
      );
    }

    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                  actionsOverflowAlignment: OverflowBarAlignment.center,
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  title: Text(updatingEntry != null ? S.current.change_Activity : S.current.createTermin),
                  content: SingleChildScrollView(
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: S.current.terminName,
                            errorText: isNameValid ? null : S.current.notEmpty,
                            focusedBorder: !isNameValid ? OutlineInputBorder(
                              borderSide: BorderSide(
                                color: isNameValid ? Colors.blue : Colors.red,
                              ),
                            ) : null,
                          ),
                          onChanged: (event){
                            setState((){
                              isNameValid = true;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        ListTile(
                          leading: Text(S.current.date),
                          title: Text(DateFormat('dd.MM.yy').format(selectedDate), textAlign: TextAlign.right),
                          trailing: Icon(Icons.calendar_today),
                          onTap: () async {
                            DateTime? picked = await pickDate(selectedDate);
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                        ListTile(
                          leading: Text(S.current.beginTime),
                          title: Text(startTime.format(context), textAlign: TextAlign.right),
                          trailing: Icon(Icons.access_time),
                          onTap: () async {
                            TimeOfDay? picked = await pickTime(startTime);
                            if (picked != null) {
                              startTime = picked;
                              setState(() {
                                if(startTime.isAfter(endTime)){
                                  int hour = startTime.hour+1 > 23 ? 23 : startTime.hour+1;
                                  int minute = startTime.hour+1 > 23 ? 59 : startTime.minute;
                                  endTime = TimeOfDay(hour: hour, minute: minute);
                                } else {
                                  tileColor = null;
                                }

                              });
                            }
                          },
                          tileColor: tileColor,
                        ),
                        ListTile(
                          leading: Text(S.current.endTime),
                          title: Text("${endTime.format(context)}  ", textAlign: TextAlign.right,),
                          trailing: Icon(Icons.access_time),
                          onTap: () async {
                            TimeOfDay? picked = await pickTime(endTime);
                            if (picked != null) {
                              endTime = picked;
                              setState(() {
                                if(startTime.isAfter(endTime)){
                                  tileColor = Color.fromARGB(90, 220, 172, 107);
                                } else {
                                  tileColor = null;
                                }
                              });
                            }
                          },
                          tileColor: tileColor,
                        ),
                      ],
                    )
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: FittedBox(
                                  child: Text(S.current.cancel,),
                                )
                              ),
                        ),
                        Expanded(
                            child: TextButton(
                              onPressed: () {
                                if (nameController.text.isNotEmpty) {
                                  if(startTime.isBefore(endTime)){
                                    DateTime timeStart = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      startTime.hour,
                                        startTime.minute
                                    );
                                    DateTime timeEnd = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      endTime.hour,
                                      endTime.minute,
                                    );
                                    if(updatingEntry != null){
                                      if(updatingEntry!){
                                        Map<String,dynamic> updateMap = {
                                            "terminName" : nameController.text ,
                                            "timeBegin" : timeStart.toIso8601String(),
                                            "timeEnd" : timeEnd.toIso8601String(),
                                          };

                                        if(existingEndTime != null && existingEndTime != null){
                                          String originalTimeBegin = existingStartTime!.toIso8601String();
                                          existingStartTime!.toIso8601String();
                                          String originalName = existingName!;
                                          DatabaseHelper().updateEntry(weekKey, originalTimeBegin,originalName, updateMap);
                                        }
                                      }
                                    } else {
                                      DatabaseHelper().insertSingleTermin(weekKey, nameController.text, timeStart, timeEnd);
                                    }
                                    Map<String,dynamic> results = {
                                      "timeBegin": timeStart,
                                      "timeEnd": timeEnd,
                                      "terminName": nameController.text,
                                    };
                                    navigatorKey.currentState?.pop(results);
                                    //Für mehrtägige implementation: Wenn über eine WOche hinweg ein Termin vergeben wird, sollte dieser zu beiden Wochen hinzugefügt werden
                                  } else {
                                    setState(() {
                                      tileColor = Color.fromARGB(90, 220, 172, 107);
                                    });
                                  }
                                } else {
                                  setState((){
                                    isNameValid = false;
                                  });
                                }
                              },
                              child: FittedBox(
                                child: Text(S.current.save),
                              ),
                            )
                        ),
                      ],
                    )
                  ],
                );
          },
        );
      },
    );

  }
}
