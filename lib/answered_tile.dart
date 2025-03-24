import 'package:flutter/material.dart';
import 'package:menta_track/termin_data.dart';
import 'generated/l10n.dart';

class AnsweredTile extends StatelessWidget {
  ///Custom-ListTile für die Offen-Seite (Not_answered_page)
  final TerminData item;
  final Function(dynamic ev) onItemTap;
  final bool answered;


  const AnsweredTile({
    required this.item,
    required this.onItemTap(ev),
    required this.answered,
    super.key,
  });

  ///wandelt Datum in lokalisierte Darstellung um
  String getTimeFromDay(String dayString, BuildContext context) {
    DateTime dateTime = DateTime.parse(dayString);
    Duration tillActivity = dateTime.difference(DateTime.now());
    TimeOfDay tillActivityTimeOfDay = TimeOfDay(hour: tillActivity.inMinutes ~/60, minute: tillActivity.inMinutes % 60);
    String correctedString = "${S.of(context).um} ${S.of(context).displayATime(dateTime)} ${tillActivity.isNegative ? "" : "${tillActivityTimeOfDay.hour == 0 ? "in" : "in ${tillActivityTimeOfDay.hour}h &"} ${tillActivityTimeOfDay.minute}min"}";
    return correctedString;
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = answered ? Colors.green : Theme.of(context).appBarTheme.backgroundColor as Color;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
          //rechte seite
          border: Border(right: BorderSide(color: accentColor, width: 7)),
          borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
        ),
        child: Container(
          decoration: BoxDecoration(
            //linke Seite
            border: Border(
                left: BorderSide(color: accentColor, width: 7)), //Borderside darf immmer nur einfarbig sein
            borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
          ),
          child: GestureDetector(
            onTapDown: (ev) => {onItemTap(ev)},
            child: ListTile(
              minTileHeight: 72,
              leading: Icon(item.icon, color: accentColor,),
              title: Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: "${item.terminName} \n",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: "${getTimeFromDay(item.dayKey, context)} ${answered ? S.current.done : ""}"),
                ]),
              ),
              trailing: answered ? Icon(Icons.emoji_events_outlined, size: 42, color: accentColor,): SizedBox(),
            ),
          ),
        ),
      ),
    );
  }
}