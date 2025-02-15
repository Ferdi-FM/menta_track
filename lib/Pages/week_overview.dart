import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/helper_utilities.dart';

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
  List<List<double>> meanLists = [[], [], []];
  List<String> responses = [
    "Sehr gut gemacht ${Emojis.smile_smiling_face_with_hearts}",
    "Auch wenn es nach wenig aussieht, du hast etwas für deine Besserung gemacht \n Du kannst stolz auf dich sein ${Emojis.body_flexed_biceps}",
    "Du hast diese Woche keine Termine gehabt oder noch kein Feedback gegeben, komm später wieder ${Emojis.smile_winking_face}"
  ];
  double doneTasksPercent = 0;
  int overallAnswered = 0;
  bool isShowingMainData = true;
  bool isLoading = true;
  bool isListAvailabe = false;


  @override
  void initState() {
    getTermineForWeek();
    super.initState();
  }

  //weekKey als "yyyy-MM-dd" format
  void getTermineForWeek() async{
    DateTime firstDay = DateTime.parse(widget.weekKey);
    List<Termin> wholeWeekTerminNumber = await DatabaseHelper().getWeeklyPlan(widget.weekKey);
    int overallAnsweredCounter = 0;


    for(int i = 0; i < 7;i++){
      String weekDayKey = DateFormat("dd.MM.yy").format(firstDay.add(Duration(days: i, hours: 1)));
      List<Termin> termine = await DatabaseHelper().getDayTermine(widget.weekKey, weekDayKey); //weekDayKey als dd.MM.yy
      //int dayTermineMean = 0;
      int answeredCounter = 0;

      double goodMean = 0;
      double calmMean = 0;
      double didGoodMean = 0;

      for(Termin t in termine){
        if(t.answered){
          answeredCounter++;
          overallAnswered++; //muss eigentlich question0 abfragen;
          goodMean = goodMean + (t.question1+1);
          calmMean = calmMean + (t.question2+1);
          didGoodMean = didGoodMean + (t.question3+1);
        }
      }
      goodMean = goodMean/answeredCounter;
      calmMean = calmMean/answeredCounter;
      didGoodMean = didGoodMean/answeredCounter;

      meanLists[0].add(goodMean);
      meanLists[1].add(calmMean);
      meanLists[2].add(didGoodMean);
    }

    print(meanLists.toString());
    setState(() {
      doneTasksPercent = overallAnswered/wholeWeekTerminNumber.length*100;
      isListAvailabe = true;
    });
  }

  Widget createDescription(String text, Color color){
    return Row(
        spacing: 15,
        children: [
          const SizedBox(width: 8),
          Container(
            width: 12,  // Größe des Kreises
            height: 12,
            decoration: BoxDecoration(
              color: color, // Farbe des Punktes
              shape: BoxShape.circle,  // Kreisform
            ),
          ),
          // Abstand zwischen dem Punkt und dem Text
          Text(
            text,
            style: TextStyle(fontSize: 16),  // Textstil nach Wunsch anpassen
          ),
        ]
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Utilities().convertWeekkeyToDisplayPeriodString(widget.weekKey)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Zurück zur vorherigen Seite
          },
        ),
      ),
      body: !isListAvailabe ? Center(child: CircularProgressIndicator()) : SingleChildScrollView( //wenn Liste noch nicht geladen ist, wird ladekreis angezeigt
        physics: ScrollPhysics(),
        child: Padding(padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 16,),
            Text(
              widget.weekKey,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            overallAnswered > 0 ? RichText(
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[700],
                  ),
                  children:  [
                    TextSpan(text: "Du hast diese Woche \n"),
                    TextSpan(text: "  \n", style: TextStyle(fontSize: 5)),//Lücke,Spacing
                    TextSpan(text: "$overallAnswered \n", style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)),
                    TextSpan(text: "  \n", style: TextStyle(fontSize: 5)), //Lücke,Spacing
                    TextSpan(text: "Termine bewältigt\n\n"),
                    TextSpan(text:  doneTasksPercent >= 50 ? responses[0] : doneTasksPercent == 0 ? responses[2] : responses[1], style: TextStyle(fontWeight: FontWeight.bold)
                    )
                  ]
              ),
              textAlign: TextAlign.center,
            ) : RichText(
                text: TextSpan(
                  children: [],
                )),
            SizedBox(height: 32,),
            const Text(
              'Wöchentliche Werte',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            createDescription("Wie gut ginge es dir", Colors.lightBlueAccent),
            createDescription("Wie ruhig warst du", Colors.lightGreen),
            createDescription("Wie gut hat es getan", Colors.purple),
            const SizedBox(
              height: 12,
            ),
            Stack(
              children: [
                Padding(padding: EdgeInsets.only(top: 15),
                child: SizedBox(
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6, left: 6),
                    child: isListAvailabe == true ? _LineChart(isShowingMainData: isShowingMainData, meanList: meanLists) : SizedBox.shrink(),),
                ),
                ),

                Positioned(
                  top: 0,
                  right: 10,
                  child: IconButton(
                    iconSize: 40,
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).primaryColor.withValues(alpha: isShowingMainData ? 1.0 : 0.5),
                    ),
                    onPressed: () {
                      setState(() {
                        isShowingMainData = !isShowingMainData;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 36,)
          ],
        ),
      ),
      ),


    );
  }
}

class _LineChart extends StatelessWidget { //TODO: eigene Klasse mit Variabeln um sie auch für eine gesamtübersicht zu verwenden
  const _LineChart({
    required this.isShowingMainData,
    required this.meanList,
  });

  final bool isShowingMainData;
  final List<List<double>> meanList;


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
      maxX: 7,
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
      print("in lineBarsData: ${meanList[i]} + ${meanList.length} ");
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
        text = '1';
        break;
      case 3:
        text = '3';
        break;
      case 5:
        text = '5';
        break;
      case 7:
        text = '7';
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
    print(value.toString()); //TODO: Adjust for firstWeekDay
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Mo', style: style);
        break;
      case 1:
        text = const Text('Di', style: style);
        break;
      case 2:
        text = const Text('Mi', style: style);
        break;
      case 3:
        text = const Text('Do', style: style);
        break;
      case 4:
        text = const Text('Fr', style: style);
        break;
      case 5:
        text = const Text('Sa', style: style);
        break;
      case 6:
        text = const Text('So', style: style);
        break;
      default:
        text = const Text('');
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
      print("${meanList.length} + ${meanList[i]}");

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
            color: AppColors.primary.withValues(alpha: 0.2), width: 4),
        left: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.2), width: 4),
        right: const BorderSide(color: Colors.transparent),
        top: const BorderSide(color: Colors.transparent),
      ),
    );
}

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}
