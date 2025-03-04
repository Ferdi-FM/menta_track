import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'generated/l10n.dart';

class FlChartGraph extends StatelessWidget {

  const FlChartGraph({
    super.key,
    required this.isShowingMainData,
    required this.meanList,
    required this.weekKey,
    required this.context,
  });

  final bool isShowingMainData;
  final List<List<double>> meanList;
  final String weekKey;
  final BuildContext context;


  @override
  Widget build(BuildContext context) {
    return LineChart(
      isShowingMainData ? sampleData(true) : sampleData(false),
      duration: const Duration(milliseconds: 250),
    );
  }


  LineChartData sampleData(bool version1){
    return LineChartData(
      lineTouchData: lineTouchData1,
      gridData: gridData,
      titlesData: titlesData1,
      borderData: borderData,
      lineBarsData: version1 ? lineBarsData(true, true) : lineBarsData(true, false),
      minX: 0,
      maxX: 6,
      maxY: 7,
      minY: 0,
    );
  }

  LineTouchData get lineTouchData1 => LineTouchData(
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (touchedSpot) =>
          Colors.blueGrey.withValues(alpha: 0.8),
    ),
  );

  LineTouchData get lineTouchData2 => const LineTouchData(
    enabled: false,
  );


  FlTitlesData get titlesData1 => FlTitlesData(
    bottomTitles: AxisTitles(
      sideTitles: bottomTitles,
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    leftTitles: AxisTitles(
      sideTitles: leftTitles(),
    ),
  );

  List<LineChartBarData> lineBarsData(bool showDots, bool showCurves){
    List<LineChartBarData> l = [];
    for(int i = 0; i < 3; i++) {
      l.add(lineChartBarData(meanList[i],i, showDots, showCurves));
    }
    return l;
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = "1";
        break;
      case 3:
        text = "3";
        break;
      case 5:
        text = "5";
        break;
      case 7:
        text = "7";
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  SideTitles leftTitles() => SideTitles(
    getTitlesWidget: leftTitleWidgets,
    showTitles: true,
    interval: 1,
    reservedSize: 40,
  );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    DateTime firstWeekDay = DateTime.parse(weekKey);
    int weekDayInt = firstWeekDay.weekday;
    int correctedDayInt = (weekDayInt - 1 + value.toInt() % 7); //wandelt eine Value 0-7 in daszugehörige Liste vom weekDay an um. -1 weil weekDay bei 1 = Montag beginnt. %7 sorgt dafür, dass nach 6 wieder 0 kommt

    Widget text;
    //Sorgt dafür, dass das letzte Feld leer bleibt
    if(value == 7){
      correctedDayInt = 7;
    }
    switch (correctedDayInt) {
      case 0:
        text = Text( S.of(context).monday.substring(0,2), style: style);
        break;
      case 1:
        text = Text( S.of(context).tuesday.substring(0,2), style: style);
        break;
      case 2:
        text = Text( S.of(context).wednesday.substring(0,2), style: style);
        break;
      case 3:
        text = Text( S.of(context).thursday.substring(0,2), style: style);
        break;
      case 4:
        text = Text( S.of(context).friday.substring(0,2), style: style);
        break;
      case 5:
        text = Text( S.of(context).saturday.substring(0,2), style: style);
        break;
      case 6:
        text = Text( S.of(context).sunday.substring(0,2), style: style);
        break;
      default:
        text = Text("");
        break;
    }

    return SideTitleWidget(
      meta: meta,
      space: 10,
      child: text,
    );
  }

  LineChartBarData lineChartBarData(List<double> meanList, int index, bool dotData, bool isCurved) {
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) { //i = jeder Tag der Woche, also jeweils x für FLSpot
      double tableXIndex = i.toDouble();
      if(!meanList[i].isNaN){
        double meanDouble = double.parse(meanList[i].toStringAsFixed(1));
        spots.add(FlSpot(tableXIndex,  meanDouble)); //meanList[i] ist der Durchschnitt des Wochentags i, also i = 0 = Montag, i = 1 = Dienstag, etc.
      }
    }
    //spots.add(FlSpot(6, index+3)); Test letzter Wochentag

    Color c = index == 0 ? Colors.lightBlueAccent : index == 1 ? Colors.lightGreen : index == 2 ? Colors.purple : Colors.black87;

    return LineChartBarData(
      isCurved: isCurved,
      color: c,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: dotData),
      belowBarData: BarAreaData(show: false),
      spots: spots,
    );
  }

  SideTitles get bottomTitles => SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: 1,
    getTitlesWidget: bottomTitleWidgets,
  );

  FlGridData get gridData => const FlGridData(show: true);

  FlBorderData get borderData => FlBorderData(
    show: true,
    border: Border(
      bottom: BorderSide(
          color: Theme.of(context).primaryColor.withAlpha(170), width: 4),
      left: BorderSide(
          color: Theme.of(context).primaryColor.withAlpha(170), width: 4),
      right: const BorderSide(color: Colors.transparent),
      top: const BorderSide(color: Colors.transparent),
    ),
  );
}