import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/not_answered_data.dart';
import 'package:menta_track/Pages/question_page.dart';
import 'package:menta_track/termin.dart';

import '../main.dart';

class NotAnsweredPageHelper{

  const NotAnsweredPageHelper();


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

    //Padding p = Padding(padding: EdgeInsets.only(top: 10),
    // child: ListView.builder(
    //   itemCount: items.length,
    //   itemBuilder: (context, index) {
    //     return NotAnsweredTile(
    //       item: items[index],
    //       onItemTap: () {
    //         NotAnsweredPageHelper().openItem(items[index]);
    //       },
    //     );
    //   },
    // ),
    //;
    return items;
  }

  dynamic openItem(NotAnsweredData data) async{
    return await MyApp.navigatorKey.currentState?.push(
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
  }

}