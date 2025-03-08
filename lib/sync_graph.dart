import 'package:flutter/material.dart';
import 'package:menta_track/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import 'generated/l10n.dart';

class ScrollableWeekGraph extends StatefulWidget {
  final String? weekKey;

  const ScrollableWeekGraph({
    super.key,
    this.weekKey
  });

  @override
  ScrollableWeekGraphState createState() => ScrollableWeekGraphState();
}

class ScrollableWeekGraphState extends State<ScrollableWeekGraph> {
  List<SyncGraphData> graphList = [];
  bool graphLoaded = false;

  @override
  void initState() {
    super.initState();
    setupList();
  }

  Future<void> setupList() async {
    List<SyncGraphData> tempGraphList = widget.weekKey != null ? [] : await getWeekGraphList(); //Schonmal, falls der Graph in DayOverview noch verwendet wird
    setState(() {
      graphList = tempGraphList;
      graphLoaded = true;
    });
  }


  Future<List<SyncGraphData>> getWeekGraphList() async {
    Database db = await DatabaseHelper().database;
    List<SyncGraphData> graphList = [];
    List<Map<String, dynamic>> weekPlans = List.from(await db.query( //List.from, da die List aus der query sonst read-only ist
        "WeeklyPlans",
        where: "goodMean > -1 AND calmMean > -1 AND helpingMean > -1",
      )
    );

    ///Liste nach datum sortieren, da die Anzeige nach erstem und letztem Tag in der Liste funktioniert
    weekPlans.sort((a, b) {
      DateTime dateA = DateTime.parse(a["weekKey"]);
      DateTime dateB = DateTime.parse(b["weekKey"]);
      return dateA.compareTo(dateB);
    });

    for (var weekPlan in weekPlans) {
      String weekKey = weekPlan["weekKey"];
      DateTime weekData = DateTime.parse(weekKey);
      double goodMean = (weekPlan["goodMean"] ?? -1).toDouble();
      double calmMean = (weekPlan["calmMean"] ?? -1).toDouble();
      double helpingMean = (weekPlan["helpingMean"] ?? -1).toDouble();

      if(weekPlan["goodMean"] != -1 && weekPlan["goodMean"] != -1 && weekPlan["goodMean"] != -1) {
        graphList.add(SyncGraphData(
            weekData,
            double.parse((goodMean + 1).toStringAsFixed(1)), //Double mit einer Nachkommastelle für bessere lesbarkeit
            double.parse((calmMean + 1).toStringAsFixed(1)),
            double.parse((helpingMean + 1).toStringAsFixed(1))
        )); //Da Datebank Werte 0-6 enthält, aber Werte 1-7 darstellen sollen
      }
    }
    return graphList;
  }

  //Falls in WeekOVerview eingefügt werden sollte, wahrscheinlich eh nicht
  //Future<List<SyncGraphData>> getDayGraphList(String? weekKey) async {
  //  Database db = await DatabaseHelper().database;
  //  List<SyncGraphData> graphList = [];
  //  List<Map<String, dynamic>> weekPlans = await db.query(
  //    "Termine",
  //    where: "weekKey = ? AND answered = 1",
  //  );
//
  //  print(weekPlans);
//
  //  for (var weekPlan in weekPlans) {
  //    String weekKey = weekPlan["weekKey"];
  //    DateTime weekData = DateTime.parse(weekKey);
  //    double goodMean = (weekPlan["goodMean"] ?? 1).toDouble();
  //    double calmMean = (weekPlan["calmMean"] ?? 1).toDouble();
  //    double helpingMean = (weekPlan["helpingMean"] ?? 1).toDouble();
//
  //    if(weekPlan["goodMean"] != -1 && weekPlan["goodMean"] != -1 && weekPlan["goodMean"] != -1) {
  //      graphList.add(SyncGraphData(weekData, goodMean+1, calmMean+1, helpingMean+1));
  //    }
  //  }
//
  //  return graphList;
  //}

  @override
  Widget build(BuildContext context) {
    return graphList.isNotEmpty ? Scaffold(
      body: graphLoaded ? SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: graphList.length * 100 > MediaQuery.of(context).size.width * 0.9 ? graphList.length*100 : MediaQuery.of(context).size.width *0.9, // Breite für Scrollbarkeit
          padding: EdgeInsets.all(16),
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              minimum: graphList.isNotEmpty ? graphList.first.dayOrWeek : DateTime.now(),
              maximum: graphList.length > 1 ? graphList.last.dayOrWeek.add(Duration(days: 7)) : graphList.first.dayOrWeek.add(Duration(days: 7)),
              intervalType: DateTimeIntervalType.days,
              dateFormat: DateFormat("dd.MM"), // Wochen-Datum formatieren
              edgeLabelPlacement: EdgeLabelPlacement.none,
              interval: 7, // Jede Woche anzeigen
            ),
            primaryYAxis: NumericAxis(
              minimum: 1, maximum: 7, interval: 2,
            ),
            legend: Legend(
                isVisible: true,
                position: LegendPosition.top,
                alignment: ChartAlignment.center,
                orientation: LegendItemOrientation.vertical,
                height: "50%",
                padding: 15,

            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              LineSeries<SyncGraphData, DateTime>(
                name: S.of(context).legend_Msg0,
                dataSource: graphList,
                xValueMapper: (SyncGraphData data, _) => data.dayOrWeek,
                yValueMapper: (SyncGraphData data, _) => data.goodMean,
                markerSettings: MarkerSettings(isVisible: true),
              ),
              LineSeries<SyncGraphData, DateTime>(
                name: S.of(context).legend_Msg1,
                dataSource: graphList,
                xValueMapper: (SyncGraphData data, _) => data.dayOrWeek,
                yValueMapper: (SyncGraphData data, _) => data.calmMean,
                markerSettings: MarkerSettings(isVisible: true),
              ),
              LineSeries<SyncGraphData, DateTime>(
                name: S.of(context).legend_Msg2,
                dataSource: graphList,
                xValueMapper: (SyncGraphData data, _) => data.dayOrWeek,
                yValueMapper: (SyncGraphData data, _) => data.helpMean,
                markerSettings: MarkerSettings(isVisible: true),
              ),
            ],
          ),
        ),
      ): CircularProgressIndicator(),
    ) : SizedBox();
  }
}
class SyncGraphData {
  final DateTime dayOrWeek;
  final double goodMean;
  final double calmMean;
  final double helpMean;

  SyncGraphData(this.dayOrWeek, this.goodMean, this.calmMean, this.helpMean);
}