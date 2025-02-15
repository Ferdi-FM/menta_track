import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/activity_summary.dart';
import 'package:menta_track/Pages/not_answered_page.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:menta_track/import_json.dart';
import 'package:menta_track/notification_helper.dart';
import 'package:menta_track/termin.dart';
import 'package:menta_track/week_tile.dart';
import 'package:menta_track/week_tile_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'not_answered_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  MyAppState createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Menta Track",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.cyan,
            brightness: Brightness.light),
        primaryColor: Colors.lightBlueAccent,
        appBarTheme: AppBarTheme(color: Colors.lightBlue.shade300),//Evtl darkmode
        scaffoldBackgroundColor: Colors.lightBlue.shade50,
        listTileTheme: ListTileThemeData(
          tileColor: Colors.white,
          textColor: Colors.black,
          iconColor: Colors.lightBlueAccent,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.lightBlue.shade100,
            selectedItemColor:Colors.lightBlueAccent.shade400 ,
            unselectedItemColor: Colors.black87),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        fontFamily: "Comfortaa",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
        primaryColor: Colors.lightBlueAccent,
        appBarTheme: AppBarTheme(color: Colors.lightBlueAccent.shade400),
        scaffoldBackgroundColor: Colors.blueGrey.shade800,
        listTileTheme: ListTileThemeData(
          tileColor: Colors.grey.shade600,
          textColor: Colors.white,
          iconColor: Colors.lightBlueAccent,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blueGrey.shade700,
          selectedItemColor: Colors.lightBlueAccent,
          unselectedItemColor: Colors.white70,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      navigatorKey: MyApp.navigatorKey,
      home: MainPage(),
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      this.themeMode = themeMode;
    });
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
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  bool isDarkMode = false;
  final PageController _pageController = PageController(initialPage: 1);

  //Für Seite "Home"
  List<WeekTileData> items = [];

  //Für Seite "Offen"
  int selectedIndex = 1;

  List<NotAnsweredData> itemsNotAnswered = [];

  @override
  void initState() {
    super.initState();
    loadTheme();
    checkDatabase();
  }

  //Plant die Notifications für alle Termine in der Übergebenen Woche. Checkt in den jeweiligen Funktionen erst ob sie schon geplant wurden (Muss noch getestet werden)
  void initializeNotifications(String weekKey) async {
    notificationHelper.startListeningNotificationEvents();
    List<Termin> weekAppointments = await databaseHelper.getWeeklyPlan(weekKey);

    //Notification mit allen Terminen in der Früh
    await notificationHelper.scheduleBeginNotification(weekAppointments, weekKey);
    //Notification für die einzelnen Termine in der Woche
    for(Termin termin in weekAppointments){
      notificationHelper.scheduleNewTerminNotification(termin, weekKey);
    }
    //Notification mit der Tagesübersicht
    await notificationHelper.scheduleEndNotification(weekKey);
    await notificationHelper.scheduleTestNotification(weekKey);
  }

  //prüft die Datenbank auf Einträge, lädt sie in die Listenansicht und plant Notifications (TO_DO?: Datenbankeintrag mit „Notificationssheduled“ zur WeeklyPlans-Table hinzufügen, damit keine tatsächlichen Benachrichtigungen geprüft werden müssen, der Nachteil ist, dass es nur indirekt überprüft wird)
  void checkDatabase() async {
    List<Map<String, dynamic>> weekPlans = await databaseHelper.getAllWeekPlans();
    String testKey = "";
    if (weekPlans.isEmpty) return;

    for (var weekPlan in weekPlans) {
      String weekKey = weekPlan["weekKey"];

      //Konvertiert standard DateTime in  DE-standard
      DateTime endOfWeek = DateTime.parse(weekKey).add(Duration(days: 6));
      String startOfWeekString = DateFormat("dd-MM-yyyy").format(
          DateTime.parse(weekKey));
      String endOfWeekString = DateFormat("dd-MM-yyyy").format(endOfWeek);
      String title1 = "$startOfWeekString - $endOfWeekString";

      WeekTileData data = WeekTileData(
          icon: Icons.abc, title: title1, weekKey: weekKey);
      addEntry(data);

      //initializeNotifications(weekKey);
    }
    testKey = weekPlans[1]["weekKey"];
    initializeNotifications(testKey); //Testing
  }

  //Fügt der Liste einen Eintrag hinzu
  void addEntry(WeekTileData data) {
    setState(() {
      if (!items.contains(data)) {
        items.add(data);
      }
    });
  }

  //löscht Eintrag aus der Liste
  void deleteItem(String weekKey) async {
    DateFormat format = DateFormat("dd-MM-yyyy");
    DateTime displayDateString = format.parse(weekKey.substring(0, 10));
    String correctedDate = DateFormat("yyyy-MM-dd").format(displayDateString);
    databaseHelper.dropTable(correctedDate);
  }

  // Lädt den gespeicherten Darkmode-Wert
  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("darkMode") ?? false;
      print(isDarkMode);
      ThemeMode mode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      MyApp.of(context).changeTheme(mode);
    });

  }

  Future<void> toggleDarkMode(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", val);
    print(val);
    setState(() {
      isDarkMode = val;
      ThemeMode mode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      MyApp.of(context).changeTheme(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectedIndex == 0 ? Text("Unbeantwortete Termine") :
        selectedIndex == 1 ? Text("Wochenplan Übersicht") :
        Text("Übersicht"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        actions: [ //TODO: Reaktivieren, implementation ist fertig
      Padding(
      padding: EdgeInsets.only(right: 5),
      child: MenuAnchor(
                menuChildren: <Widget>[
                  MenuItemButton(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.help_rounded),
                          SizedBox(width: 10),
                          Text("Hilfe")
                        ],
                      ),
                    ),
                    onPressed: () => Utilities().showHelpDialog(context, "MainPage"),
                  ),
                  MenuItemButton(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Darkmode"),
                          SizedBox(width: 5),
                          Switch(
                            value: isDarkMode,
                            onChanged: (value) {
                              isDarkMode = isDarkMode;
                              toggleDarkMode(value);
                            },
                          ),
                        ]
                    ),
                    onPressed: () => print("Two"),
                  ),
                ],
                builder: (BuildContext context, MenuController controller, Widget? child) {
                  return TextButton(
                    focusNode: _buttonFocusNode,
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    child: const Icon(Icons.menu, size: 30),
                  );
                }
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (ev) { //links und rechts swipe Logik
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
            NotAnsweredPage(),
            //Seite 2 (Hauptseite):
          CustomScrollView( //Wegen Evtl Einbindung von Illustration über Liste, die mitscrollen soll
            slivers: [
              // Das Bild als "Sliver" für das Scrollen
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //SizedBox(width: MediaQuery.of(context).size.width * 0.2,),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 16,),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset("assets/images/flat-design illustration.png",//"assets/images/test.jpg",
                              width: MediaQuery.of(context).size.width * 0.4,
                            ),
                          ),
                          SizedBox(height: 30,)
                        ]
                    ),
                    Container(
                      width: 150,
                      child: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                              children: [
                                TextSpan(text: "Startseite: \n", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                                TextSpan(text: "Das ist ein Test um zu sehen wie es aussieht", style: TextStyle(color: Colors.black))
                              ]
                          )
                      ),
                    )

                  ],
                )  
              ),
              // Der ListView als Sliver
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
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
                  childCount: items.length,
                ),
              ),
            ],
          ),
            // Seite "Übersicht":
            ActivitySummary(),
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
            icon: selectedIndex == 0 ? Icon(Icons.album) : Icon(
                Icons.album_outlined),
            label: "Offen",
          ),
          BottomNavigationBarItem(
            icon: selectedIndex == 1 ? Icon(Icons.home) : Icon(
                Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: selectedIndex == 2 ? Icon(Icons.summarize) : Icon(
                Icons.summarize_outlined),
            label: "Übersicht",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<WeekTileData> weekLists = await ImportJson().loadDummyData();
          for (WeekTileData data in weekLists) {
            addEntry(data);
          }
        },
        backgroundColor: Colors.cyan,
        child: Icon(Icons.add_box),
      ),
    );
  }
}

//PageView alternate CHildren
/*Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                itemCount: itemsNotAnswered.length,
                itemBuilder: (context, index) {
                  return NotAnsweredTile(
                    item: itemsNotAnswered[index],
                    onItemTap: () async {
                      final result = await NotAnsweredPageHelper().openItem(
                          itemsNotAnswered[index]);
                      if (result != null) {
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
            ),*/
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
/* DropDown Menu
MenuAnchor(
            childFocusNode: _buttonFocusNode,
            menuChildren: <Widget>[
              MenuItemButton(
                child: Text("Hilfe?"),
                onPressed: () => print("ONE"),
              ),
              MenuItemButton(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text("Darkmode"),
                    Switch(
                      value: isDarkMode,
                        onChanged: (value) {
                          isDarkMode = isDarkMode; // Darkmode umschalten
                        },
                      ),
                    ]
                ),
                onPressed: () => print("Two"),
              ),
            ],
            builder:
            (BuildContext context, MenuController controller, Widget? child) {
              return TextButton(
                focusNode: _buttonFocusNode,
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: const Icon(Icons.menu),
              );
            }
          )
 */

/*PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "hilfe") {
                // Zeige Hilfe-Dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog( //TODO: in Klasse verlegen, die text annimmt und je nach Seite Hilfe ändert
                    title: Text("Hilfe"),
                    content: Text("Hier könnte Hilfe stehen."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "hilfe",
                child: Text("Hilfe?"),
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Darkmode"),
                    Switch(
                      value: isDarkMode,
                      onChanged: (val) {
                        toggleDarkMode(val);
                      }
                    ),
                  ],
                ),
              ),
            ],
          ),

 */