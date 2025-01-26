import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/import_json.dart';
import 'package:menta_track/not_answered_page_helper.dart';
import 'package:menta_track/not_answered_tile.dart';
import 'package:menta_track/notification_helper.dart';
import 'package:menta_track/termin.dart';
import 'package:menta_track/week_tile.dart';
import 'package:menta_track/week_tile_data.dart';

import 'not_answered_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Menta Track",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        primaryColor: Colors.lightBlueAccent,
        appBarTheme: AppBarTheme(color: Colors.lightBlueAccent),//Evtl darkmode
        useMaterial3: true,
      ),
      darkTheme: ThemeData(

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
  DatabaseHelper databaseHelper = DatabaseHelper();
  NotificationHelper notificationHelper = NotificationHelper();
  //Für Seite "Home"
  List<WeekTileData> items = [];
  //Für Seite "Offen"
  int selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);
  List<NotAnsweredData> itemsNotAnswered = [];

  @override
  void initState() {
    super.initState();
    checkDatabase();
    setUpPageTwo();
  }

  //Plant die Notifications für alle Termine in der Übergebenen Woche. Checkt in den jeweiligen Funktionen erst ob sie schon geplant wurden (Muss noch getestet werden)
  void initializeNotifications(String weekKey) async {
    notificationHelper.startListeningNotificationEvents();
    List<Termin> weekAppointments = await databaseHelper.getWeeklyPlan(weekKey);

    //Notification mit allen Terminen in der Früh
    await notificationHelper.scheduleBeginNotification(weekAppointments, weekKey);
    //Notification für die einzelnen Termine in der Woche
    //for(Termin termin in weekAppointments){
    //  notificationHelper.scheduleNewTerminNotification(termin, weekKey);
    //}
    //Notification mit der Tagesübersicht
    //await notificationHelper.scheduleEndNotification(weekKey);
    await notificationHelper.scheduleTestNotification(weekKey);
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

      WeekTileData data = WeekTileData(icon: Icons.abc, title: title1, weekKey: weekKey);
      addEntry(data);

      //initializeNotifications(weekKey);
    }
    testKey = weekPlans[0]["weekKey"];
    initializeNotifications(testKey); //Testing
  }

 /* void openItem(String weekKey) async{
    //String correctedKey = Utilities().convertDisplayDateStringToWeekkey(weekKey);
    MyApp.navigatorKey.currentState?.push(
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
  }*/

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

  void setUpPageTwo() async{
    itemsNotAnswered = await NotAnsweredPageHelper().loadNotAnswered();
  }

  void addEntryAnswer(NotAnsweredData data){
    setState(() {
      if(!itemsNotAnswered.contains(data)){
        itemsNotAnswered.add(data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  selectedIndex == 0 ?  Text("Unbeantwortete Termine") :
                selectedIndex == 1 ?  Text("Wochenplan Übersicht") :
                                      Text("Übersicht"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (ev) { //links und rechts swipe
          if (ev.primaryVelocity! > 0 && selectedIndex > 0) { //links
            setState(() {
              selectedIndex--;
            });
            _pageController.animateToPage(
              selectedIndex,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else if (ev.primaryVelocity! < 0 && selectedIndex < 2) { //rechts
            setState(() {
              selectedIndex++;
            });
            _pageController.animateToPage(
              selectedIndex,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(), // Deaktiviert Swipe-Gesten, um eigene zu verwenden.
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                itemCount: itemsNotAnswered.length,
                itemBuilder: (context, index) {
                  return NotAnsweredTile(
                    item: itemsNotAnswered[index],
                    onItemTap: () async {
                      final result = await NotAnsweredPageHelper().openItem(itemsNotAnswered[index]);
                      if(result != null){
                        setState(() {
                          itemsNotAnswered.removeAt(index);
                        });
                      } else {
                        print("canceled");
                      }
                    },
                  );
                },
              ),
            ),
            //Seite "Offen" Alternative:
            //FutureBuilder(
            //  future: NotAnsweredPageHelper().loadNotAnswered(),
            //  builder: (context, snapshot) {
            //    if (snapshot.hasData) {
            //      return snapshot.data!;
            //    } else {
            //      return Center(child: CircularProgressIndicator());
            //    }
            //  },
            //),
            //Seite 2:
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return WeekTile(
                    item: items[index],
                    onDeleteTap: () async {
                      deleteItem(items[index].title);
                      setState(() {
                        items.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
            // Seite "Übersicht":
            Center(child: Text("Übersicht", style: TextStyle(fontSize: 24))),
          ],
        ),
      ),
     bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: selectedIndex == 0 ? Icon(Icons.album) : Icon(Icons.album_outlined),
            label: "Offen",
          ),
          BottomNavigationBarItem(
            icon: selectedIndex == 1 ? Icon(Icons.home) : Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: selectedIndex == 2 ? Icon(Icons.summarize) : Icon(Icons.summarize_outlined),
            label: "Übersicht",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("pressed");
          List<WeekTileData> weekLists =
          ImportJson().loadDummyData as List<WeekTileData>;
          for (WeekTileData data in weekLists) {
            addEntry(data);
          }
        },
        backgroundColor: Colors.cyan,
        child: Icon(Icons.add_box),
      ),
    );
  }

  /* Alternative Variante erst ohne BottomBar, ist ein wenig aufgeräumter,
  body: GestureDetector(
        child: Padding(padding: EdgeInsets.only(top: 10),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return WeekTile(
                item: items[index],
                onItemTap: () {
                  openItem(items[index].weekKey);
                },
                onDeleteTap: () async{
                  print("DELETE");
                  deleteItem(items[index].title);
                  setState(() {
                    items.removeAt(index);
                  });
                },
              );
              //return Dismissible( //TODO: Eventuell coole idee zum löschen
              //    key: Key(index.toString()),
              //    onDismissed: (s) async{
              //      _showDeleteDialog(items[index].title);
              //    },
              //    direction: DismissDirection.endToStart,
              //    child: WeekTile(
              //      item: items[index],
              //      onItemTap: () {
              //        openItem(items[index].title);
              //      },
              //      onDeleteTap: () {
              //        deleteItem(items[index].title);
              //        setState(() {
              //          items.removeAt(index);
              //        });
              //      },),
            },
          ),
        ),
        onHorizontalDragEnd: (ev) {
          if (ev.primaryVelocity! > 0){
            print("Swipe right");
            MyApp.navigatorKey.currentState?.push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      NotAnsweredPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation,
                      child) {
                    const begin = Offset(-1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(
                        CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                )
            );
          }
        },
      ),
  }*/
}