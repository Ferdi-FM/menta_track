import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/create_dummy_json_for_testing.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/termin.dart';
import 'package:menta_track/week_plan_view.dart';
import 'package:menta_track/week_tile.dart';
import 'package:menta_track/week_tile_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final dummy = CreateDummyJsonForTesting();
  final Map<String, dynamic> weeklyPlans = {};
  List<WeekTileData> items = [];
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    checkDatabase();
  }

  void addEntry(WeekTileData data){
    setState(() {
      if(!items.contains(data)){
        items.add(data);
      }
    });
  }

  void checkDatabase() async{
    List<Map<String, dynamic>> weekPlans = await databaseHelper.getAllWeekPlans();

    if(weekPlans.isEmpty) return;
    for (var weekPlan in weekPlans) {
      String weekKey = weekPlan["weekKey"];

      //Convert standard DateTime to DE-standard
      DateTime endOfWeek = DateTime.parse(weekKey).add(Duration(days: 6));
      String startOfWeekString = DateFormat("dd-MM-yyyy").format(DateTime.parse(weekKey));
      String endOfWeekString = DateFormat("dd-MM-yyyy").format(endOfWeek);
      String title1 = "$startOfWeekString - $endOfWeekString";

      WeekTileData data = WeekTileData(icon: Icons.abc, title: title1);
      addEntry(data);
    }
  }

  Future<void> createWeekPlanMapFromJson(Map terminMap) async {
    for(int i = 0; i < terminMap.length; i++){
      List<Termin> terminItems = [];
      String firstWeekDay = terminMap.keys.toList()[i].toString(); //nimmt den key der Map aus der Json-Datei um die Woche zu indentifizieren
      List termine = terminMap[firstWeekDay]; //Liste der übertragenen Termine für die Woche

      for(int j = 0; j < termine.length; j++){ //Convertiert die vom Therapeuten erstelle Liste in eine Liste aus Termin-Items für den Patienten
        var termin = termine[j];
        Termin t = Termin(
            terminName: termin["TerminName"],
            timeBegin: DateTime.parse(termin["TerminBeginn"]),
            timeEnd: DateTime.parse(termin["TerminEnde"]),
            question1: -1,
            question2: -1,
            question3: -1,
            comment: "",
            answered: false);

        terminItems.add(t);
      }
      weeklyPlans[firstWeekDay] = terminItems; //fügt die Liste der Termine der Map der Wochenpläne bei Bsp: {"20-01-2025" : {Liste der Termine für Woche 20-01-2025}}
        List<Termin> existingPlan = await databaseHelper.getWeeklyPlan(firstWeekDay);
        if(existingPlan.isEmpty){
          await databaseHelper.insertWeeklyPlan(firstWeekDay, terminItems);
          WeekTileData data = WeekTileData(icon: Icons.abc, title: ("Wochenplan $firstWeekDay")); //alternativer Name, der evtl. einfacher zu handeln ist, als z.B "20-01-2025 - 26-01-2025"
          addEntry(data);
        }
    }
  }

  void _loadDummyData(){
    final dummyData = dummy.getDummyData();
    final terminMap = jsonDecode(dummyData) as Map<String, dynamic>;
    createWeekPlanMapFromJson(terminMap);
  }

  void openItem(String weekKey) async{
    String correctedKey = convertDisplayDateStringToWeekkey(weekKey);
    print(correctedKey);

    List<Termin> weekAppointments = await databaseHelper.getWeeklyPlan(correctedKey);
    for(Termin t in weekAppointments){
      print(t.toString());
    }

    changeActivity(weekKey, weekAppointments, correctedKey); //Hier wegen der Info:"Don't use 'BuildContext's across async gaps"
  }

  //Man soll keinen context in async methode verwenden. Muss später eventuell noch Variabel gemacht werden
  void changeActivity(String weekKey, List<Termin> weekAppointments, String correctedKey) {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) => WeekPlanView(
          title: weekKey,
          termine: weekAppointments,
          weekKey: correctedKey,
        ),
        ),
      );
    }
  }

  //standard DateTime-Format ist (yyyy-MM-dd), deshalb wird hier übergangsweise der DisplayName zu dem in der Datenbank verwendeten key umformatiert
  String convertDisplayDateStringToWeekkey(String displayString){
    DateFormat format = DateFormat("dd-MM-yyyy");
    DateTime displayDateString = format.parse(displayString.substring(0,10));
    String correctedDate = DateFormat("yyyy-MM-dd").format(displayDateString);

    return correctedDate;
  }

  //und anders herum
  String convertWeekkeyToDisplayDateString(String weekKey){
    DateFormat format = DateFormat("yyyy-MM-dd");
    DateTime displayDateString = format.parse(weekKey);
    String correctedDate = DateFormat("dd-MM-yyyy").format(displayDateString);

    return correctedDate;
  }

  void deleteItem(String weekKey) async{
    DateFormat format = DateFormat("dd-MM-yyyy");
    DateTime displayDateString = format.parse(weekKey.substring(0,10));
    String correctedDate = DateFormat("yyyy-MM-dd").format(displayDateString);
    databaseHelper.dropTable(correctedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wochenplan Übersicht'),
        backgroundColor: Colors.cyan,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return WeekTile(
            item: items[index],
            onItemTap: () {
              //print("${items[index].title} Should be opened");
              openItem(items[index].title);
            },
            onDeleteTap: () {
              //print("${items[index].title} SHOULD BE DELETED");
              deleteItem(items[index].title);
              setState(() {
                items.removeAt(index);
              });
            },);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDummyData,
        backgroundColor: Colors.cyan,
        child: Icon(Icons.add_box),
      ),
    );
  }
}