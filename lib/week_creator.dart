import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/database_helper.dart';
import 'generated/l10n.dart';

///Klasse zum manuellen Hinzufügen einer Woche
class WeekDialog {

  const WeekDialog();

  Future<bool?> show(BuildContext context) async {
    DateTime startDate;
    DateTime endDate;
    Color? tileColor;

    startDate = DateTime.now();
    endDate = DateTime.now().add(Duration(days: 6));

    Future<DateTime?> pickDate(DateTime? initialDate) async {
      return await showDatePicker(
        context: context,
        initialDate: startDate,
        barrierDismissible: false, 
        firstDate: DateTime.now(), 
        lastDate: DateTime.now().add(Duration(days: 31)),
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
                        SizedBox(height: 10),
                        ListTile(
                          leading: Text(S.current.weekStart),
                          title: FittedBox(child: Text(DateFormat("dd.MM.yy").format(startDate), textAlign: TextAlign.right,)),
                          trailing: Icon(Icons.calendar_today),
                          onTap: () async {
                            DateTime? picked = await pickDate(startDate);
                            if (picked != null) {
                              setState(() {
                                startDate = picked;
                                endDate = startDate.add(Duration(days: 6));
                              });
                            }
                          },
                        ),
                        ListTile(
                          leading: Text(S.current.weekEnd),
                          title: FittedBox(child: Text(DateFormat("dd.MM.yy").format(endDate), textAlign: TextAlign.right,)),
                          trailing: Icon(Icons.access_time),
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
                                DatabaseHelper().insertSingleWeek(DateFormat("yyyy-MM-dd").format(startDate), context);
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
