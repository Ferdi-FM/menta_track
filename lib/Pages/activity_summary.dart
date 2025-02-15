import 'package:flutter/material.dart';
import 'package:menta_track/database_helper.dart';

class ActivitySummary extends StatefulWidget {

  const ActivitySummary({super.key,});

  @override
  ActivitySummaryState createState() => ActivitySummaryState();
}

class ActivitySummaryState extends State<ActivitySummary> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Map<String, List<String>> activities = {};
  bool loaded = false;

  @override
  void initState() {
    loadActivities();
    super.initState();
  }

  void loadActivities() async {
    final List<Map<String, dynamic>> result = await databaseHelper.getHelpingActivity();

    // Kategorien initialisieren
    activities = {
      "good": [],
      "calm": [],
      "help": [],
    };
    print(result.length);
    // Aktivitäten den Kategorien zuweisen
    for (var row in result) {
      if(row["category"] != null && row["activity"] != null){ //gab beim testen null, da die Table ursprünglich groß geschrieben war...
        String category = row["category"];
        String activity = row["activity"];

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
                    title: Text(" noch Keine Einträge", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    leading: Icon(Icons.radio_button_unchecked, color: Colors.green),
                  ),
              ),
              for(var act in activities)...{
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: ListTile(
                    title: Text(act),
                    leading: Icon(Icons.check_circle, color: Colors.green),
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
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if(loaded) buildSingleCategory("Gute Aktivitäten", activities["good"]!),
            if(loaded) buildSingleCategory("Beruhigende Aktivitäten", activities["calm"]!),
            if(loaded) buildSingleCategory("Gut tuende Aktivitäten", activities["help"]!),
          ],
        );
  }


}
