import 'package:flutter/material.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/sync_graph.dart';

import '../generated/l10n.dart';

class ActivitySummary extends StatefulWidget {

  const ActivitySummary({super.key,});

  @override
  ActivitySummaryState createState() => ActivitySummaryState();
}

class ActivitySummaryState extends State<ActivitySummary> {
  Map<String, List<String>> activities = {};
  bool loaded = false;

  @override
  void initState() {
    loadActivities();
    super.initState();
  }

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
        if(row["doneTask"] == 0){
          //Der Termin wurde nicht eingehalten
          activity = "$activity (es nicht zu tun)";
        }

        activities[category]?.add(activity);
      }
    }
    setState(() {
      loaded = true;
    });
  }

  Widget buildSingleCategory(String title, List<String> activities) {
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
                  padding: EdgeInsets.only(left: 30),
                  child:
                  ListTile(
                    title: Text(S.of(context).summary_no_entries, style: TextStyle(fontSize: 16)),
                    leading: Icon(Icons.radio_button_unchecked, color: Colors.green),
                  ),
              ),
              for(var act in activities)...{
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Container(
                    decoration: BoxDecoration(color: Theme.of(context).listTileTheme.tileColor),
                    child: ListTile(
                      tileColor: Colors.transparent,
                      title: Text(act),
                      leading: Icon(Icons.check_circle, color: act.contains("es nicht zu tun") ? Colors.orangeAccent : Colors.green),
                    ),
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
        SizedBox(height: 10,),
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
              padding: const EdgeInsets.all(16),
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.width * 0.9,
                    minHeight: 10,
                  ),
                  child:  ScrollableWeekGraph()
                ),
                SizedBox(height: 15,),
                Text(
                    S.current.special_activities,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).primaryColor.withAlpha(200), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2,)
                ),
                if (loaded) buildSingleCategory(S.of(context).good_activities_desc , activities["good"]!),
                if (loaded) buildSingleCategory(S.of(context).calm_activities_desc , activities["calm"]!),
                if (loaded) buildSingleCategory(S.of(context).help_activities_desc , activities["help"]!),
              ],
            ),
          ),
        ),
      ],
    );
  }


}
