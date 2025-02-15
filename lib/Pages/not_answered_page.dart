import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/question_page.dart';
import 'package:menta_track/database_helper.dart';

import '../main.dart';
import '../not_answered_data.dart';
import '../not_answered_tile.dart';
import '../termin.dart';

class NotAnsweredPage extends StatefulWidget {

  const NotAnsweredPage({super.key,});

  @override
  NotAnsweredState createState() => NotAnsweredState();
}

class NotAnsweredState extends State<NotAnsweredPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<NotAnsweredData> itemsNotAnswered = [];
  bool loaded = false;

  @override
  void initState() {
    setUpPage();
    super.initState();
  }

  Future<List<NotAnsweredData>> loadNotAnswered() async{
    DatabaseHelper databaseHelper = DatabaseHelper();
    List<Map<String, dynamic>> weekPlans = await databaseHelper.getAllWeekPlans();
    List<NotAnsweredData> items = [];

    for (var weekPlan in weekPlans) {
      String weekKey = weekPlan["weekKey"];

      List<Termin> weekAppointments = await databaseHelper.getWeeklyPlan(weekKey); //await muss nach den erstellen der CalendarHeader passieren
      for(Termin t in weekAppointments){

        if(!t.answered && DateTime.now().isAfter(t.timeEnd)){
          //String title = "$t.terminName  \n am ${DateFormat("dd.MM").format(t.timeBegin)} um ${DateFormat("HH:mm").format(t.timeBegin)}";

          NotAnsweredData data = NotAnsweredData(icon: Icons.priority_high_rounded,title: t.terminName, dayKey: t.timeBegin.toString(), weekKey: weekKey, terminName: t.terminName);
          items.add(data);
        }
      }
    }
    return items;
  }

  dynamic openItem(NotAnsweredData data,var ev) async{
    Offset pos = ev.globalPosition;

    return await MyApp.navigatorKey.currentState?.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => QuestionPage(
              weekKey: data.weekKey,
              timeBegin: data.dayKey,
              terminName: data.terminName),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;

            // Erstelle eine Skalierungs-Animation
            var tween = Tween<double>(begin: 0.01, end: 1.0).chain(CurveTween(curve: curve));
            var scaleAnimation = animation.drive(tween);

            return ScaleTransition(
              scale: scaleAnimation,
              alignment: Alignment(pos.dx / MediaQuery.of(context).size.width * 2 - 1,
                  pos.dy / MediaQuery.of(context).size.height * 2 - 1),
              child: child,
            );
          },
        )
    );
  }

  void setUpPage() async {
    itemsNotAnswered = await loadNotAnswered();
    setState(() {
      loaded = true;
    });
  }

  void addEntryAnswer(NotAnsweredData data) {
    setState(() {
      if (!itemsNotAnswered.contains(data)) {
        itemsNotAnswered.add(data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        itemCount: itemsNotAnswered.length,
        itemBuilder: (context, index) {
          return NotAnsweredTile(
            item: itemsNotAnswered[index],
            onItemTap: (ev) async {
              final result = await openItem(
                  itemsNotAnswered[index],ev);
              if (result != null) {
                setState(() {
                  itemsNotAnswered.removeAt(index);
                });
              } else {
                print("canceled");
              }
            },
          );
        },
      ),
    );
  }


}
