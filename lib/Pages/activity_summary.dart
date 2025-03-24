import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:menta_track/Pages/week_plan_view.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/sync_graph.dart';
import 'package:sqflite/sqflite.dart';
import 'package:string_similarity/string_similarity.dart';
import '../generated/l10n.dart';
import '../main.dart';

///Seite zum Anzeigen der allgemeinen Übersicht (Besondere Aktivitäten und Graph der Mittelwerte aller Wochen

class ActivitySummary extends StatefulWidget {

  const ActivitySummary({super.key,});

  @override
  ActivitySummaryState createState() => ActivitySummaryState();
}

class ActivitySummaryState extends State<ActivitySummary> {
  Map<String, List<Map<String, String>>> activities = {};
  bool loaded = false;

  @override
  void initState() {
    loadActivities();
    super.initState();
  }

  ///Lädt die besonderen Aktivitäten aus der Datenbank und ordnet sie in einer Liste mit Maps ein
  void loadActivities() async {
    final Database db = await DatabaseHelper().database;
    // Kategorien initialisieren
    activities = {
      "good": [],
      "calm": [],
      "help": [],
    };
    final List<Map<String, dynamic>> specialTasks = await db.query(
      "Termine",
      where: "goodQuestion = 6 OR calmQuestion = 6 OR helpQuestion = 6",
    );
    for(Map specialTask in specialTasks){
      List<String> categories = [];
      if(specialTask["goodQuestion"] == 6){
       categories.add("good");
      }
      if(specialTask["calmQuestion"] == 6){
        categories.add("calm");
      }
      if(specialTask["helpQuestion"] == 6){
          categories.add("help");
      }
      for(String category in categories){
        Map<String, String>  oneEntry = {
          "title": specialTask["terminName"],
          "date": specialTask["timeBegin"],
          "comment": specialTask["comment"],
          "doneTask": specialTask["terminName"] == 2 ? "false" : "true",
          "weekKey": specialTask["weekKey"],
        };

        bool alreadySimilar = false;
        for(Map<String, String> activityMap in activities[category]!){
          if(activityMap["title"]!.similarityTo(specialTask["terminName"]) > 0.8 ){
             alreadySimilar = true;
             activityMap["date"] = "${activityMap["date"]}|${specialTask["timeBegin"]}";
             activityMap["comment"] = "${activityMap["comment"]}|${specialTask["comment"]}";
             activityMap["weekKey"] = "${activityMap["weekKey"]}|${specialTask["weekKey"]}";
             activityMap["doneTask"] = "${activityMap["doneTask"]}|${specialTask["doneTask"]}";
          }
        }
        if(!alreadySimilar){
          activities[category]?.add(oneEntry);
        }
      }
    }
    setState(() {
      loaded = true;
    });
  }

  ///Erstellt ein Widget für eine der drei Kategorien der Besondere Aktivitäten
  Widget buildSingleCategory(String title, List<Map<String,String>> activities) {
    return
      Padding(
          padding: EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (activities.isEmpty) Padding(
                padding: EdgeInsets.only(left: 20),
                child: ListTile(
                    title: Text(S.of(context).summary_no_entries, style: TextStyle(fontSize: 16)),
                    leading: Icon(Icons.radio_button_unchecked, color: Colors.green),
                    tileColor: Theme.of(context).listTileTheme.tileColor?.withAlpha(70),
                  ),
              ),
              for(var map in activities)...{
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Container(
                    decoration: BoxDecoration(color: Theme.of(context).listTileTheme.tileColor?.withAlpha(70)),
                    child: InfoListTile(map: map),
                  ),
                )
              },
              SizedBox(height: 16),
            ],
          )
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                stops: [0.0, 0.05, 0.9, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 16,right: 16,bottom: 15),
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.width * 0.9,
                    minHeight: 10,
                  ),
                  child:  ScrollableWeekGraph()
                ),
                SizedBox(height: 15),
                AutoSizeText(
                    S.current.special_activities,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)
                ),
                SizedBox(height: 10),
                if (loaded) buildSingleCategory(S.of(context).good_activities_desc , activities["good"]!),
                if (loaded) buildSingleCategory(S.of(context).calm_activities_desc , activities["calm"]!),
                if (loaded) buildSingleCategory(S.of(context).help_activities_desc , activities["help"]!),
                SizedBox(height: 15)
              ],
            ),
          ),
        ),
      ],
    );
  }
}

///Custom ListTile um sie erweiterbar für zusätzliche Informationen zu machen
class InfoListTile extends StatefulWidget {
  final Map<String, String> map;
  const InfoListTile({super.key, required this.map});

  @override
  InfoListTileState createState() => InfoListTileState();
}

class InfoListTileState extends State<InfoListTile> {
  bool showInfo = false;
  List<Map<String, String>> datesAndComments = [];
  IconData expandIcon = Icons.expand_more_rounded;

  @override
  void initState() {
    List<String> dates = widget.map["date"]!.split("|");
    List<String> comments = widget.map["comment"]!.split("|");
    List<String> weekKeys = widget.map["weekKey"]!.split("|");
    List<String> doneTasks = widget.map["doneTask"]!.split("|");
    for(int i = 0; i < dates.length; i++){
      DateTime dateTime = DateTime.parse(dates[i]);
      String date = "${S.current.displayADateWithYear(dateTime)} ${S.current.um} ${S.current.displayATime(dateTime)}";
      Map<String,String> singleActivity = {
        "date": date,
        "comment": comments[i],
        "weekKey": weekKeys[i],
        "doneTask": doneTasks[i],
        "timeInHours": dateTime.hour.toString(),
      };
      datesAndComments.add(singleActivity);
    }
    super.initState();
  }

  Future<void> openWeekView(String weekKey, int hour) async {
    await navigatorKey.currentState?.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => WeekPlanView(
              weekKey: weekKey, scrollToSpecificHour: hour,),
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
  Widget build(BuildContext context) {
    return
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            tileColor: Colors.transparent,
            title: Text(widget.map["title"]!),
            leading: Icon(
              Icons.push_pin_outlined,
              size: 22,
              color: Colors.green,
            ),
            trailing: Icon(expandIcon),
            onTap: () {
              setState(() {
                expandIcon = expandIcon == Icons.expand_more_rounded ? Icons.expand_less_rounded : Icons.expand_more_rounded;
                showInfo = !showInfo;
              });
            },
          ),
          if(showInfo) Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for(Map<String,String> map in datesAndComments)...{
                   Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                spacing: 10,
                                children: [
                                  Text("${S.current.am} ${map["date"]}", style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                                  Icon(Icons.check, size: 16, color: map["doneTask"] == "true" ? Colors.lightGreen : Colors.orangeAccent,),
                                ],
                              ),
                            ),
                            SizedBox(height: 3),
                            if(map["comment"]!.isNotEmpty) Container(
                              padding: EdgeInsets.only(left: 10),
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(S.current.comment, style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                  Text(map["comment"]!, style: TextStyle(fontSize: 13, color: Colors.grey), textAlign: TextAlign.left, overflow: TextOverflow.clip, softWrap: true,),
                                ],
                              ),
                            )
                            //if(map["comment"]!.isNotEmpty) ...{
                            //  Text("  ${S.current.comment}", style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic), textAlign: TextAlign.left),
                            //  Text("  ${map["comment"]!}", style: TextStyle(fontSize: 13, color: Colors.grey), textAlign: TextAlign.left, overflow: TextOverflow.clip, softWrap: true,),
                            //}
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              openWeekView(map["weekKey"]!,int.parse(map["timeInHours"]!));
                            },
                            icon: Icon(Icons.shortcut, color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  SizedBox(height: 12,)
                },
              ]
            ),
          ),
        ],
      );
  }
}