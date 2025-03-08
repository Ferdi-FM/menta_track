import 'dart:async';
import 'package:flutter/material.dart';
import 'package:menta_track/week_tile_data.dart';
import 'package:sqflite/sqflite.dart';
import 'Pages/week_plan_view.dart';
import 'database_helper.dart';
import 'generated/l10n.dart';
import 'main.dart';

class WeekTile extends StatefulWidget {
  final VoidCallback onDeleteTap;
  final VoidCallback onTap;
  final WeekTileData item;

  const WeekTile({
    required this.item,
    required this.onDeleteTap,
    super.key,
    required this.onTap,
  });

  @override
  WeekTileState createState() => WeekTileState();
}

class WeekTileState extends State<WeekTile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  bool pressedLongEnough = false;
  Color? iconColor;

  Future<bool?> _showDeleteDialog(String title) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.current.delete),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(S.current.delete_week_plan, textAlign: TextAlign.center,),
                Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
                Text(S.current.delete_week_plan2, textAlign: TextAlign.center),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(S.current.delete,style: TextStyle(color: Colors.redAccent),),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text(S.current.back),
              onPressed: () {
                Navigator.of(context).pop(false);
              },),
          ],
        );
      },
    );
  }

  Future<WeekTileData> getWeekTileData(String weekKey, String title) async {
    final db = await DatabaseHelper().database;
    int allT = await DatabaseHelper().getWeekTermineCount(weekKey);
    int ansT = await DatabaseHelper().getWeekTermineCountAnswered(weekKey, true);
    String query = "SELECT COUNT(*) FROM Termine WHERE weekKey = ? AND answered = ? AND (datetime(timeBegin) < datetime(CURRENT_DATE))";
    int ansTTillNow = Sqflite.firstIntValue(await db.rawQuery(query, [weekKey,0])) ?? 0;
    String subtitle ="";
    DateTime weekKeyDateTime = DateTime.parse(weekKey);
    WeekTileData data;

    subtitle = "Aktivitäten: $allT   Offen: $ansTTillNow";
    if (DateTime.now().isAfter(weekKeyDateTime) && DateTime.now().isBefore(weekKeyDateTime.add(Duration(days: 6)))) {
      data = WeekTileData(icon: Icon(Icons.today), title: title, weekKey: weekKey, subTitle: subtitle);
    } else if (DateTime.now().isBefore(weekKeyDateTime)) {
      subtitle = "Noch nicht soweit 😉";
      data = WeekTileData(icon: Icon(Icons.lock_clock), title: title, weekKey: weekKey, subTitle: subtitle);
    } else if (allT == ansT) {
      subtitle = "Geschafft! 🏆";
      data = WeekTileData(icon: Icon(Icons.event_available, color: Colors.green), title: title, weekKey: weekKey, subTitle: subtitle);
    } else {
      data = WeekTileData(icon: Icon(Icons.free_cancellation), title: title, weekKey: weekKey, subTitle: subtitle);
    }

    return data;
  }

  //void openItem(String weekKey) async{
  //  //String correctedKey = Utilities().convertDisplayDateStringToWeekkey(weekKey);
  //  var result = await navigatorKey.currentState?.push(
  //      PageRouteBuilder(
  //        pageBuilder: (context, animation, secondaryAnimation) => WeekPlanView(
  //            weekKey: weekKey),
  //        transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //          const begin = Offset(1.0, 0.0);
  //          const end = Offset.zero;
  //          const curve = Curves.easeInOut;
  //          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  //          var offsetAnimation = animation.drive(tween);
//
  //          return SlideTransition(
  //            position: offsetAnimation,
  //            child: child,
  //          );
  //        },
  //      )
  //  );
  //  if(result != null){
  //    if(result == "updated"){
  //      print("UPDATED");
  //    }
  //  }
  //}

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorAnimation = ColorTween(
      begin: Theme.of(context).listTileTheme.tileColor ?? Colors.blueGrey, // Fallback-Wert
      end: Colors.grey,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 10,
          child: GestureDetector(
            onTapUp: (ev){
              widget.onTap();
              //openItem(widget.item.weekKey);
            },
            child: Container(//color: _colorAnimation.value
                decoration: BoxDecoration( //rechte seite
                  border: Border(right: BorderSide(color: _colorAnimation.value as Color, width: 5)),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                ),
                child: Container(
                  decoration: BoxDecoration( //linke Seite
                      border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 7)),  //Borderside darf immmer nur einfarbig sein
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                      color: _colorAnimation.value
                  ),
                  child: ListTile(
                    minTileHeight: 72,
                    leading: Icon(widget.item.icon.icon, color: widget.item.icon.color),
                    title: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        widget.item.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
                      ) ,
                    ),
                    subtitle: Text(widget.item.subTitle),
                    trailing: GestureDetector(
                      child: Icon(Icons.delete),
                      onTap: () => _animationController.reset(),
                      onLongPressDown: (event) {
                        _animationController.forward();
                      },
                      onLongPress: () async {
                        bool? ans = await _showDeleteDialog(widget.item.title);
                        if(ans == true){
                          _animationController.reset(); //reset weil sonst das vorherige ListItem gefärbt ist
                          widget.onDeleteTap();
                        } else {
                          _animationController.reverse();
                        }
                      },
                      onLongPressUp: () async {
                      },
                    ),
                  ),
                ),
            ),
          ),
        );
      },
    );
  }
}
