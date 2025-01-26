import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../termin.dart';

class WeekOverview extends StatefulWidget {
  final String weekKey;

  const WeekOverview({
    super.key,
    required this.weekKey
  });

  @override
  WeekOverviewState createState() => WeekOverviewState();
}

class WeekOverviewState extends State<WeekOverview> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Termin> termineForThisWeek = [];

  @override
  void initState() {
    getTermineForWeek();

    super.initState();
  }

  //weekKey als "yyyy-MM-dd" format
  void getTermineForWeek() async{
    termineForThisWeek = await databaseHelper.getWeeklyPlan(widget.weekKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Week Key"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Zurück zur vorherigen Seite
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.weekKey,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "75%", // Beispiel-Prozentzahl
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
