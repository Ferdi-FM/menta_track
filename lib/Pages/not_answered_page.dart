import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/not_answered_data.dart';
import 'package:menta_track/not_answered_tile.dart';
import 'package:menta_track/Pages/question_page.dart';
import 'package:menta_track/termin.dart';
import '../main.dart';

class NotAnsweredPage extends StatefulWidget{

  const NotAnsweredPage({
    super.key,});

  @override
  NotAnsweredPageState createState() => NotAnsweredPageState();

}

class NotAnsweredPageState extends State<NotAnsweredPage> {
  List<NotAnsweredData> items = [];


  @override
  void initState() {
    loadNotAnswered();
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
            String title = "${t.terminName} am ${DateFormat("dd.MM").format(t.timeBegin)} um ${DateFormat("HH:mm").format(t.timeBegin)}";

            NotAnsweredData data = NotAnsweredData(icon: Icons.priority_high_rounded,title: title, dayKey: t.timeBegin.toString(), weekKey: weekKey, terminName: t.terminName);

              items.add(data);

          }
      }
    }
    return items;
  }

  void openItem(NotAnsweredData data) async{
    MyApp.navigatorKey.currentState?.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => QuestionPage(
              weekKey: data.weekKey,
              timeBegin: data.dayKey,
              terminName: data.terminName,
              isEditable: true),
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

    //MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
    //  builder: (context) => WeekPlanView(
    //    weekKey: correctedKey,
    //  ),
    //),);
    //changeActivity(weekKey, correctedKey); //Hier wegen der Info:"Don't use 'BuildContext's across async gaps"
  }

  //Fügt der Liste einen Eintrag hinzu
  void addEntryAnswer(NotAnsweredData data){
    setState(() {
      if(!items.contains(data)){
        items.add(data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unbeantwortete Termine"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))), //Vielleicht, tendiere zu anderer Lösung
      ),
      body:
      GestureDetector(
        child: Padding(padding: EdgeInsets.only(top: 10),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return NotAnsweredTile(
                item: items[index],
                onItemTap: () {
                  openItem(items[index]);
                },
              );
            },
          ),
        ),
        onHorizontalDragEnd: (ev) {
          if (ev.primaryVelocity! < 0) {
            print("Swipe left");
            Navigator.pop(context);
          }
        },
      ),
      bottomNavigationBar:
      BottomNavigationBar(items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.album),
            label: "Offen"),
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.summarize_outlined),
            label: "Übersicht")
      ],),
    );
  }


}