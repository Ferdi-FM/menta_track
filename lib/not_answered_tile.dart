import 'package:flutter/material.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:menta_track/termin_data.dart';
import 'generated/l10n.dart';

///Custom-ListTile für die Offen-Seite (Not_answered_page)

class NotAnsweredTile extends StatelessWidget {
  final TerminData item;
  final Function(dynamic ev) onItemTap;

  const NotAnsweredTile({
    required this.item,
    required this.onItemTap(ev),
    super.key,
  });

  ///wandelt Datum in lokalisierte Darstellung um
  String getDateAndTimeFromDay(String dayString, BuildContext context){
    DateTime dateTime = DateTime.parse(dayString);
    String dayDisplay = "${Utilities().getWeekdayName(dateTime)} ${S.current.displayADate(dateTime)}";
    String correctedString = "${S.of(context).am} $dayDisplay ${S.of(context).um} ${S.of(context).displayATime(dateTime)}";
    return correctedString;
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = Theme.of(context).appBarTheme.backgroundColor as Color;
    return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 10,
          child: Container(
            decoration: BoxDecoration( //rechte seite
              border: Border(right: BorderSide(color: accentColor, width: 7)),
              borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
            ),
            child: Container(
              decoration: BoxDecoration( //linke Seite
              border: Border(left: BorderSide(color: Theme.of(context).listTileTheme.tileColor as Color, width: 5)),                    //Borderside darf immmer nur einfarbig sein
              borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
              ),
              child: GestureDetector(
                onTapDown: (ev) => {
                  onItemTap(ev)
                },
                child: ListTile(
                  minTileHeight: 72,
                  leading: Icon(item.icon, color: accentColor,),
                  title: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "${item.terminName} \n", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: getDateAndTimeFromDay(item.dayKey,context)),
                        ]
                      ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}