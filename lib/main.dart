import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:menta_track/create_dummy_json_for_testing.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/import_json.dart';
import 'package:menta_track/notification_helper.dart';
import 'package:menta_track/termin.dart';
import 'package:menta_track/week_plan_view.dart';
import 'package:menta_track/week_tile.dart';
import 'package:menta_track/week_tile_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan), //Evtl darkmode
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
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
  List<WeekTileData> items = [];
  DatabaseHelper databaseHelper = DatabaseHelper();
  NotificationHelper notificationHelper = NotificationHelper();

  @override
  void initState() {
    super.initState();
    checkDatabase();
  }

  //Plant die Notifications für alle Termine in der Übergebenen Woche. Checkt in den jeweiligen Funktionen erst ob sie schon geplant wurden (Muss noch getestet werden)
  void initializeNotifications(String weekKey) async {
    notificationHelper.startListeningNotificationEvents();

    List<Termin> weekAppointments = await databaseHelper.getWeeklyPlan(weekKey);

    //Notification mit allen Terminen in der Früh
    await notificationHelper.scheduleBeginNotification(weekAppointments, weekKey);

    //for(Termin termin in weekAppointments){ //TODO: Testing
      //notificationHelper.scheduleNewTerminNotification(termin, weekKey);
    //}

    await notificationHelper.scheduleEndNotification(weekKey);
  }

  //prüft die Datenbank auf Einträge, lädt sie in die Listenansicht und plant Notifications (TO_DO?: Datenbankeintrag mit „Notificationssheduled“ zur WeeklyPlans-Table hinzufügen, damit keine tatsächlichen Benachrichtigungen geprüft werden müssen, der Nachteil ist, dass es nur indirekt überprüft wird)
  void checkDatabase() async{
    List<Map<String, dynamic>> weekPlans = await databaseHelper.getAllWeekPlans();
    String testKey = "";
    if(weekPlans.isEmpty) return;
    for (var weekPlan in weekPlans) {
      String weekKey = weekPlan["weekKey"];

      //Konvertiert standard DateTime in  DE-standard
      DateTime endOfWeek = DateTime.parse(weekKey).add(Duration(days: 6));
      String startOfWeekString = DateFormat("dd-MM-yyyy").format(DateTime.parse(weekKey));
      String endOfWeekString = DateFormat("dd-MM-yyyy").format(endOfWeek);
      String title1 = "$startOfWeekString - $endOfWeekString";

      WeekTileData data = WeekTileData(icon: Icons.abc, title: title1);
      addEntry(data);

      testKey = weekKey;
    }
    initializeNotifications(testKey); //Testing
  }

  //Falls import_json.dart nicht funktioniert
  /*Future<void> createWeekPlanMapFromJson(Map terminMap) async {
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
            question0: -1,
            question1: -1,
            question2: -1,
            question3: -1,
            comment: "",
            answered: false);

        terminItems.add(t);
      }
        List<Termin> existingPlan = await databaseHelper.getWeeklyPlan(firstWeekDay);
        if(existingPlan.isEmpty){
          //Erstellt Datenbank Eintrag
          await databaseHelper.insertWeeklyPlan(firstWeekDay, terminItems);

          //Erstellt item für die Liste
          DateTime endOfWeek = DateTime.parse(firstWeekDay).add(Duration(days: 6));
          String startOfWeekString = DateFormat("dd-MM-yyyy").format(DateTime.parse(firstWeekDay));
          String endOfWeekString = DateFormat("dd-MM-yyyy").format(endOfWeek);
          String title1 = "$startOfWeekString - $endOfWeekString";

          WeekTileData data = WeekTileData(icon: Icons.abc, title: title1);
          addEntry(data);
        }
    }
  }

  void _loadDummyData(){
    final dummyData = dummy.getDummyData();
    final terminMap = jsonDecode(dummyData) as Map<String, dynamic>;
    createWeekPlanMapFromJson(terminMap);
  }*/

  void openItem(String weekKey) async{
    String correctedKey = Utilities().convertDisplayDateStringToWeekkey(weekKey);
    MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => WeekPlanView(
        weekKey: correctedKey,
      ),
    ),);
    //changeActivity(weekKey, correctedKey); //Hier wegen der Info:"Don't use 'BuildContext's across async gaps"
  }

  //Man soll keinen context in async methode verwenden. Muss später eventuell noch Variabel gemacht werden
  void changeActivity(String weekKey, String correctedKey) {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) => WeekPlanView(
          weekKey: correctedKey,
        ),
        ),
      );
    }
  }

  //Fügt der Liste einen Eintrag hinzu
  void addEntry(WeekTileData data){
    setState(() {
      if(!items.contains(data)){
        items.add(data);
      }
    });
  }

  //löscht Eintrag aus der Liste
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))), //Vielleicht, tendiere zu anderer Lösung
      ),
      body: Padding(padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return WeekTile(
              item: items[index],
              onItemTap: () {
                openItem(items[index].title);
              },
              onDeleteTap: () {
                deleteItem(items[index].title);
                setState(() {
                  items.removeAt(index);
                });
              },);
          },
        ),)
      ,
      floatingActionButton: FloatingActionButton(
        onPressed: ImportJson().loadDummyData,
        backgroundColor: Colors.cyan,
        child: Icon(Icons.add_box),
      ),
    );
  }
}