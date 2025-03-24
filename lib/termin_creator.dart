import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/main.dart';
import 'generated/l10n.dart';

///Klasse zum manuellen Hinzufügen von Aktivitäten zu einer Woche

class TerminDialog {
  final String weekKey;

  final DateTime? existingStartTime;
  final DateTime? existingEndTime;

  const TerminDialog({
    required this.weekKey,
    this.existingStartTime,
    this.existingEndTime
  });

  Future<bool?> show(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate;
    TimeOfDay startTime;
    TimeOfDay endTime;
    bool isNameValid = true;
    Color? tileColor;

    if(existingStartTime != null){
      selectedDate = existingStartTime!;
      startTime = TimeOfDay.fromDateTime(existingStartTime!);
      endTime = TimeOfDay.fromDateTime(existingEndTime!);
    } else {
      selectedDate = DateTime.parse(weekKey);
      startTime = TimeOfDay.fromDateTime(DateTime.now());
      endTime = TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 30)));
    }

    Future<DateTime?> pickDate(DateTime? initialDate) async {
      return await showDatePicker(
        context: context,
        initialDate: DateTime.parse(weekKey),
        firstDate: DateTime.parse(weekKey),
        lastDate: DateTime.parse(weekKey).add(Duration(days: 6)),
        barrierDismissible: false,
      );
    }

    Future<TimeOfDay?> pickTime(TimeOfDay? initialTime) async {
      //TODO: Durch DateTime-Picker ersetzen um über Tage hinweg Termine einfügen zu können
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
                  title: Text(S.current.createTermin),
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
                                    navigatorKey.currentState?.pop(true);
                                    DateTime timeStart = selectedDate.add(Duration(hours: startTime.hour, minutes: startTime.minute));
                                    DateTime timeEnd = selectedDate.add(Duration(hours: endTime.hour, minutes: endTime.minute));
                                    DatabaseHelper().insertSingleTermin(weekKey, nameController.text, timeStart, timeEnd);
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
