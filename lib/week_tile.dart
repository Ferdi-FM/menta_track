import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:menta_track/week_tile_data.dart';
import 'package:sqflite/sqflite.dart';
import 'Pages/week_plan_view.dart';
import 'database_helper.dart';
import 'generated/l10n.dart';
import 'main.dart';

///Klasse für Custom-Tile für die Liste mit Wochenplänen

class WeekTile extends StatefulWidget {
  final VoidCallback onDeleteTap;
  final WeekTileData item;

  const WeekTile({
    required this.item,
    required this.onDeleteTap,
    super.key,
  });

  @override
  WeekTileState createState() => WeekTileState();
}

class WeekTileState extends State<WeekTile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  bool pressedLongEnough = false;
  Color? iconColor;



  ///Erzeugt ein WeekTile je nach wann es ist und wie viel Feedback gegeben wurde
  Future<WeekTileData> getWeekTileData(String weekKey, String title) async {
    final db = await DatabaseHelper().database;
    int allWeekTasks = await DatabaseHelper().getWeekTermineCount(weekKey, false);
    ///Query sucht nach allen bis jetzt noch nicht beantworteten Terminen in der Woche
    String query = "SELECT COUNT(*) FROM Termine WHERE weekKey = ? AND answered = ? AND (datetime(timeBegin) < datetime(CURRENT_TIMESTAMP))";
    int unAnsweredWeekTasks = Sqflite.firstIntValue(await db.rawQuery(query, [weekKey,0])) ?? 0;
    int answeredWeekTasks = Sqflite.firstIntValue(await db.rawQuery(query, [weekKey,1])) ?? 0;

    WeekTileData data;
    DateTime weekKeyDateTime = DateTime.parse(weekKey);
    String subtitle = "${S.current.activities}: $allWeekTasks  ${S.current.open_singular}: $unAnsweredWeekTasks";
    data = WeekTileData(icon: Icon(Icons.free_cancellation), title: title, weekKey: weekKey, subTitle: subtitle);
    ///aktuelle Woche
    if (DateTime.now().isAfter(weekKeyDateTime) && DateTime.now().isBefore(weekKeyDateTime.add(Duration(days: 7)))) {
      if(unAnsweredWeekTasks == 0 && answeredWeekTasks > 0){
        subtitle = S.current.noFeedBackOpen;
      }
      data = WeekTileData(icon: Icon(Icons.running_with_errors), title: title, weekKey: weekKey, subTitle: subtitle);
    }
    ///Liegt in der Zukunft
    else if (DateTime.now().isBefore(weekKeyDateTime)) {
      subtitle = S.current.not_yet_single;
      data = WeekTileData(icon: Icon(Icons.lock_clock), title: title, weekKey: weekKey, subTitle: subtitle);
    } else if(unAnsweredWeekTasks != 0) {
      data = WeekTileData(icon: Icon(Icons.free_cancellation), title: title, weekKey: weekKey, subTitle: subtitle);
    }
    ///Alles beantwortet
    if (allWeekTasks == answeredWeekTasks && allWeekTasks != 0) {
      subtitle = S.current.done;
      data = WeekTileData(icon: Icon(Icons.event_available, color: Colors.green), title: title, weekKey: weekKey, subTitle: subtitle);
    }
    if(allWeekTasks == 0){
      subtitle = S.current.noEntriesYet;
      data = WeekTileData(icon: Icon(DateTime.now().isBefore(weekKeyDateTime) ? Icons.lock_clock : Icons.cancel_presentation), title: title, weekKey: weekKey, subTitle: subtitle);

    }
    return data;
  }

  ///Öffnet die Wochen-Plan-Übersicht
  void openItem(String weekKey) async{
    await navigatorKey.currentState?.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => WeekPlanView(
              weekKey: weekKey),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        )
    );
  }

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
    Color tileColor = Theme.of(context).listTileTheme.tileColor!.withAlpha(140);
    DateTime weekKeyDateTime = DateTime.parse(widget.item.weekKey);
    if (DateTime.now().isAfter(weekKeyDateTime) && DateTime.now().isBefore(weekKeyDateTime.add(Duration(days: 7)))) {
      tileColor = Theme.of(context).listTileTheme.tileColor as Color;
    }
    _colorAnimation = ColorTween( //muss hier deklariert werden, da in initState noch kein context vorhanden ist und damit zu crash führt
      begin: tileColor,
      end: Colors.grey,
    ).animate(_animationController);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = Theme.of(context).appBarTheme.backgroundColor as Color;
    DateTime weekKeyDateTime = DateTime.parse(widget.item.weekKey);
    if (DateTime.now().isAfter(weekKeyDateTime) && DateTime.now().isBefore(weekKeyDateTime.add(Duration(days: 7)))) {
      accentColor = Theme.of(context).textTheme.bodyLarge?.color ?? accentColor;
    }
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 10,
          child: GestureDetector(
            onTapUp: (ev){
              //widget.onTap();
              openItem(widget.item.weekKey);
            },
            child: Container(//color: _colorAnimation.value
                decoration: BoxDecoration( //rechte seite
                  border: Border(right: BorderSide(color: _colorAnimation.value as Color, width: 5)),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                ),
                child: Container(
                  decoration: BoxDecoration( //linke Seite
                      border: Border(left: BorderSide(color: widget.item.icon.color ?? accentColor, width: 7)),  //Borderside darf immmer nur einfarbig sein
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                      color: _colorAnimation.value
                  ),
                  child: ListTile(
                    tileColor: _colorAnimation.value,
                    minTileHeight: 72,
                    leading: Icon(widget.item.icon.icon, color: widget.item.icon.color ?? accentColor),
                    title: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        widget.item.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
                      ) ,
                    ),
                    subtitle: AutoSizeText(widget.item.subTitle, maxLines: 1, maxFontSize: 15, minFontSize: 8, softWrap: true,),
                    trailing: GestureDetector(
                      child: Icon(Icons.delete, color: widget.item.icon.color ?? accentColor,),
                      onTap: () => _animationController.reset(),
                      onLongPressDown: (event) {
                        _animationController.forward();
                      },
                      onLongPress: () async {
                        bool? ans = await Utilities().showDeleteDialog(widget.item.title,true,context);
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
