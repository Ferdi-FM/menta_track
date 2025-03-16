import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:menta_track/Pages/week_plan_view.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/sync_graph.dart';
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
    final List<Map<String, dynamic>> result = await DatabaseHelper().getHelpingActivity();

    // Kategorien initialisieren
    activities = {
      "good": [],
      "calm": [],
      "help": [],
    };
    // Aktivitäten den Kategorien zuweisen
    for (var row in result) {
      if(row["category"] != null && row["activity"] != null){ //gab beim testen null, da die Table ursprünglich groß geschrieben war...
        String category = row["category"];
        String activity = row["activity"];
        DateTime dateTime = DateTime.parse(row["date"]);
        String date = "${S.current.displayADateWithYear(dateTime)} ${S.current.um} ${S.current.displayATime(dateTime)}";
        String comment = row["comment"];
        String doneTask = row["doneTask"] == 1 ? "true" : "false";
        String weekKey = row["weekKey"];

        Map<String, String>  oneEntry = {
          "title": activity,
          "date": date,
          "comment": comment,
          "doneTask": doneTask,
          "weekKey": weekKey,
        };

        activities[category]?.add(oneEntry);
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
                stops: [0.0, 0.08, 0.9, 1.0],
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
                    style: TextStyle(color: Theme.of(context).primaryColor.withAlpha(200), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2,)
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

  Future<void> openWeekView(String weekKey) async {
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
  Widget build(BuildContext context) {
    return
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            tileColor: Colors.transparent,
            title: Text(widget.map["title"]!),
            leading: Icon(
              Icons.check_circle,
              color: widget.map["doneTask"] == "false" ? Colors.orangeAccent : Colors.green,
            ),
            trailing: IconButton(
                onPressed: () {
                  openWeekView(widget.map["weekKey"]!);
                },
                icon: Icon(Icons.shortcut)),
            onTap: () {
              setState(() {
                showInfo = !showInfo;
              });
            },
          ),
          if(showInfo) Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${S.current.am} ${widget.map["date"]}", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                SizedBox(height: 5,),
                if(widget.map["comment"]!.isNotEmpty)...{
                  Text(S.current.comment, style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic), textAlign: TextAlign.left),
                  Text(widget.map["comment"]!, style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.left, overflow: TextOverflow.clip, softWrap: true, maxLines: 5,),
                }
               ],
              ),
            )
        ],
      );
  }
}