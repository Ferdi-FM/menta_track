import 'package:flutter/material.dart';
import 'package:menta_track/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'generated/l10n.dart';

///Klasse für Anzeige/Erstellen des Graphen auf der allgmeinen Übersichtsseite aller Wochen

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
  ScrollController scrollController = ScrollController();
  double legendOffset = 0;
  bool graphLoaded = false;

  @override
  void initState() {
    super.initState();
    setupList();
    scrollController.addListener(() {
      setState(() {
        legendOffset = scrollController.offset;
      });
    });
  }

  Future<void> setupList() async {
    List<SyncGraphData> tempGraphList = widget.weekKey != null ? [] : await getWeekGraphList(); //Schonmal, falls der Graph in DayOverview noch verwendet wird
    setState(() {
      graphList = tempGraphList;
      graphLoaded = true;
    });
  }

 ///Holt die Wochenlisten mit Mittelwerte und passt sie zur anzeige im Graphen an
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

  @override
  Widget build(BuildContext context) {
    return graphList.isNotEmpty ? Scaffold(
      body: graphLoaded ? ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
              stops: [0.0, 0.08, 0.9, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: Container(
              width: graphList.length * 100 > MediaQuery.of(context).size.width * 0.9 ? graphList.length*100 : MediaQuery.of(context).size.width *0.9, // Breite für Scrollbarkeit
              padding: EdgeInsets.all(16),
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  minimum: graphList.isNotEmpty ? graphList.first.dayOrWeek : DateTime.now(),
                  maximum: graphList.length > 1 ? graphList.last.dayOrWeek.add(Duration(days: 7)) : graphList.first.dayOrWeek.add(Duration(days: 7)),
                  intervalType: DateTimeIntervalType.days,
                  dateFormat: DateFormat("dd.MM"),
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
                    legendItemBuilder: //Benötigt um die Legende mitscrollen zu lassen
                        (String name, dynamic series, dynamic point, int index) {
                      return Container(
                          padding: EdgeInsets.only(left: legendOffset+ MediaQuery.of(context).size.width/20),
                          margin: EdgeInsets.only(bottom: index == 2 ? 10 : 0),
                          height: 25,
                          width: graphList.length * 100 > MediaQuery.of(context).size.width * 0.9 ? graphList.length*100 : MediaQuery.of(context).size.width *0.9, // Breite für Scrollbarkeit
                          child: Row(
                              spacing: 10,
                              children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withAlpha(50),
                                      blurRadius: 7,
                                      spreadRadius: 1,
                                      offset: Offset(3, 3)
                                    )
                                  ],
                                  color: index == 0 ? Colors.green : index == 1 ? Colors.orange : index == 2 ? Colors.blue : Colors.transparent,
                                ),
                                width: 10,
                                height: 10,
                              ),
                              FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Text(
                                  index == 0 ? S.current.legend_Msg0 : index == 1 ? S.current.legend_Msg1 : index == 2 ? S.current.legend_Msg2 : "",
                                  style: TextStyle(shadows: [
                                    Shadow(
                                      offset:Offset(3, 3),
                                      blurRadius: 5,
                                      color: Colors.black.withAlpha(50),
                                    )
                                  ]),
                                ),
                              )
                              ,
                          ]
                          ),
                      );
                    }
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  LineSeries<SyncGraphData, DateTime>(
                    name: S.of(context).legend_Msg0,
                    color: Colors.green,
                    dataSource: graphList,
                    xValueMapper: (SyncGraphData data, _) => data.dayOrWeek,
                    yValueMapper: (SyncGraphData data, _) => data.goodMean,
                    markerSettings: MarkerSettings(isVisible: true, shape: DataMarkerType.diamond),
                  ),
                  LineSeries<SyncGraphData, DateTime>(
                    name: S.of(context).legend_Msg1,
                    color: Colors.orange,
                    dataSource: graphList,
                    xValueMapper: (SyncGraphData data, _) => data.dayOrWeek,
                    yValueMapper: (SyncGraphData data, _) => data.calmMean,
                    markerSettings: MarkerSettings(isVisible: true, shape: DataMarkerType.diamond),
                  ),
                  LineSeries<SyncGraphData, DateTime>(
                    name: S.of(context).legend_Msg2,
                    color: Colors.blue,
                    dataSource: graphList,
                    xValueMapper: (SyncGraphData data, _) => data.dayOrWeek,
                    yValueMapper: (SyncGraphData data, _) => data.helpMean,
                    markerSettings: MarkerSettings(isVisible: true, shape: DataMarkerType.diamond),
                  )
                ],
              ),
            ),
          )
      ): CircularProgressIndicator(),
    ) : SizedBox();
  }
}

///Data für den Graphen
class SyncGraphData {
  final DateTime dayOrWeek;
  final double goodMean;
  final double calmMean;
  final double helpMean;

  SyncGraphData(this.dayOrWeek, this.goodMean, this.calmMean, this.helpMean);
}