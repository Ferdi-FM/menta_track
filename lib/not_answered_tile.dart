import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/not_answered_data.dart';

class NotAnsweredTile extends StatelessWidget {
  final NotAnsweredData item;
  final Function(dynamic ev) onItemTap;

  const NotAnsweredTile({
    required this.item,
    required this.onItemTap(ev),
    super.key,
  });

  String getDateAndTimeFromDay(String dayString){
    DateTime dateTime = DateTime.parse(dayString);
    String correctedString = "am ${DateFormat("dd.MM").format(dateTime)} um ${DateFormat("HH:mm").format(dateTime)}";
    return correctedString;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 10,
          child: Container(
            decoration: BoxDecoration( //rechte seite
              border: Border(right: BorderSide(color: Theme.of(context).primaryColor, width: 7)),
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
                //onTap: (){
                //  print("tapping");
                //  //onItemTap();
                //},
                minTileHeight: 72,
                leading: Icon(item.icon),
                title: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "${item.title} \n", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: getDateAndTimeFromDay(item.dayKey)),
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