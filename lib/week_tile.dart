import 'dart:async';
import 'package:flutter/material.dart';
import 'package:menta_track/week_tile_data.dart';
import 'Pages/week_plan_view.dart';
import 'main.dart';

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

  Future<bool?> _showDeleteDialog(String title) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Löschen"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Willst du den Wochenplan für :", textAlign: TextAlign.center,),
                Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
                Text("wirklich löschen?", textAlign: TextAlign.center),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Löschen",style: TextStyle(color: Colors.redAccent),),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text("Zurück"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },),
          ],
        );
      },
    );
  }

  void openItem(String weekKey) async{
    //String correctedKey = Utilities().convertDisplayDateStringToWeekkey(weekKey);
    MyApp.navigatorKey.currentState?.push(
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
              print("tapping");
              openItem(widget.item.weekKey);
            },
            child:
              Container(//color: _colorAnimation.value
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
                    leading: Icon(widget.item.icon),
                    title: Text(
                      widget.item.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    trailing: GestureDetector( //TODO?: Auf ListTile verschieben und mit Longpress direkt auf Tile löschen lassen, dieses Icon benutzen um die WeekÜbersicht zu öffnen
                      child: Icon(Icons.delete),
                      onTap: () => _animationController.reset(),
                      onLongPressDown: (event) {
                        _animationController.forward();
                      },
                      onLongPress: () async {
                        bool? ans = await _showDeleteDialog(widget.item.title);
                        if(ans == true){
                          _animationController.reset(); //reset weil sonst das vorherige ListItem rot ist
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
