import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/activity_summary.dart';
import 'package:menta_track/Pages/not_answered_page.dart';
import 'package:menta_track/Pages/settings.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:menta_track/import_json.dart';
import 'package:menta_track/notification_helper.dart';
import 'package:menta_track/termin.dart';
import 'package:menta_track/theme_helper.dart';
import 'package:menta_track/week_tile.dart';
import 'package:menta_track/week_tile_data.dart';
import 'package:sqflite/sqflite.dart';
import 'Pages/barcode_scanner_simple.dart';
import 'generated/l10n.dart';

//TODO: - Aufräumen
//TODO - Lokal für DayOverview, WeekOverview, NotificationHelper(+test to Release)

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
  ThemeMode themeMode = ThemeMode.dark;//Darkmode als standard
  MaterialColor accentColorOne = Colors.lightBlue;
  Color accentColorTwo = Colors.lightBlue;
  MaterialColor seedColor = Colors.cyan;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'),
        Locale('de', 'DE'),
        // Füge hier weitere Sprachen hinzu
      ],
      title: "Menta Track",
      theme: ThemeData(
        fontFamily: "Comfortaa",
        colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light),
        primaryColor: accentColorTwo,
        appBarTheme: AppBarTheme(color: accentColorOne.shade300),
        scaffoldBackgroundColor: accentColorOne.shade50,
        listTileTheme: ListTileThemeData(
          tileColor: Colors.white,
          textColor: Colors.black,
          iconColor: accentColorTwo,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: accentColorOne.shade100,
            selectedItemColor:accentColorTwo ,
            unselectedItemColor: Colors.black87),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        fontFamily: "Comfortaa",
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        primaryColor: accentColorTwo,
        appBarTheme: AppBarTheme(color: accentColorTwo),
        scaffoldBackgroundColor: Colors.blueGrey.shade800,
        listTileTheme: ListTileThemeData(
          tileColor: Colors.grey.shade600,
          textColor: Colors.white,
          iconColor: accentColorTwo,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blueGrey.shade700,
          selectedItemColor: accentColorTwo,
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

  void changeColor(String colorString) {
        setState(() {
      if(colorString == "blue"){
        accentColorOne = Colors.lightBlue;
        accentColorTwo = Colors.lightBlueAccent;
        seedColor = Colors.cyan;
      }
      if(colorString == "orange"){
        accentColorOne = Colors.orange;
        accentColorTwo = Colors.orangeAccent.shade400;
        seedColor = Colors.orange;
      }
    });
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with WidgetsBindingObserver {
  DatabaseHelper databaseHelper = DatabaseHelper();
  NotificationHelper notificationHelper = NotificationHelper();
  final PageController _pageController = PageController(initialPage: 1);
  final GlobalKey<NotAnsweredState> _notAnsweredKey = GlobalKey<NotAnsweredState>();
  Widget themeIllustration = SizedBox();
  int selectedIndex = 1;
  List<WeekTileData> items = [];

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
    for(Termin termin in weekAppointments) {
      notificationHelper.scheduleNewTerminNotification(termin, weekKey);
    }

    //Notification mit der Tagesübersicht und Wochenübersicht
    await notificationHelper.scheduleEndNotification(weekKey);
  }

  //prüft die Datenbank auf Einträge, lädt sie in die Listenansicht und plant Notifications (TO_DO?: Datenbankeintrag mit „Notificationssheduled“ zur WeeklyPlans-Table hinzufügen, damit keine tatsächlichen Benachrichtigungen geprüft werden müssen, der Nachteil ist, dass es nur indirekt überprüft wird)
  void checkDatabase() async {
    //funktion direkt in SQLite
    Database db = await databaseHelper.database;
    String query = '''
      SELECT 
        weekKey, 
        strftime('%d.%m.%Y', weekKey) AS startOfWeekString,
        strftime('%d.%m.%Y', date(weekKey, '+6 days')) AS endOfWeekString
      FROM WeeklyPlans
    ''';
    List<Map<String, dynamic>> weekPlans = await db.rawQuery(query);
    if (weekPlans.isEmpty) return;

    for (var weekPlan in weekPlans) {
      String weekKey = weekPlan["weekKey"];
      String title1 = "${weekPlan["startOfWeekString"]} - ${weekPlan["endOfWeekString"]}";
      WeekTileData data = WeekTileData(icon: Icons.date_range, title: title1, weekKey: weekKey);
      addEntry(data);
      //TODO: zukunftscheck sinnvoll? Was wenn App dann länger nicht geöffnet wurde und deshalb keine neuen Benachrichtigungen kommen?

      //Wird dann nochmals genauer in Notificationhelper getestet, aber man spart sich einige funktionen und iterationen es hier zu checken
      if(DateTime.parse(weekKey).difference(DateTime.now()).isNegative){ //Checkt ob die gesamte Woche in der Vergangenheit liegt
        print("Week already passed");
      } else if(DateTime.parse(weekKey).difference(DateTime.now()) > Duration(days: 14)){ //Checkt ob der Wochenstart mehr als eine Woche in der Zukunft liegt
        print("Week more than a two weeks in the future");
      }else {
        initializeNotifications(weekKey);
      }

      DatabaseHelper().updateActivities(weekKey); //Checkt den Wochendurchschnitt für die Anzeige auf der Übersichtsseite
    }
    String testKey = weekPlans[0]["weekKey"];
    await notificationHelper.scheduleTestNotification(testKey); //Testing
    //notificationHelper.startListeningNotificationEvents(); //TODO: Aktivieren
    //notificationHelper.loadAllNotifications(false); //TODO: Aktivieren
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
    //print(weekKey);
    DateFormat format = DateFormat("dd.MM.yyyy");
    DateTime displayDateString = format.parse(weekKey.substring(0, 10));
    //print(displayDateString);
    String correctedDate = DateFormat("yyyy-MM-dd").format(displayDateString);
    //print(correctedDate);
    databaseHelper.dropTable(correctedDate);
  }

  // Lädt den gespeicherte Settings-Werte
  void loadTheme() async {
    SettingData data = await SettingsPageState().getSettings();
    bool isDarkMode = data.isDarkMode;
    String name = data.name;
    setState(() { //Unschön, aber muss vor themeHelper geladen werden, damit textfarbe je nach darkmode richtig geladen wird
      MyApp.of(context).changeTheme(isDarkMode ? ThemeMode.dark : ThemeMode.light);
    });
    Widget image = SizedBox();
    if(mounted) image = await ThemeHelper().getIllustrationImage("MainPage");
    setState(() {
      MyApp.of(context).changeTheme(isDarkMode ? ThemeMode.dark : ThemeMode.light);
      themeIllustration = image;
      name;
    });
    //notificationHelper.loadAllNotifications(true); //TODO: Aktivieren
  }

  Future<void> openSettings() async {
    bool? changed = await MyApp.navigatorKey.currentState?.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => SettingsPage(),
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
    if(changed != null){
      if(changed){
        setState(() {
          loadTheme();
        });
        _notAnsweredKey.currentState?.loadTheme();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectedIndex == 0 ? Text(S.of(context).unanswered) :
        selectedIndex == 1 ? Text(S.of(context).home) :
        Text(S.of(context).bestActivities),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        actions: [
        Padding(
          padding: EdgeInsets.only(right: 5),
          child: MenuAnchor(
               menuChildren: <Widget>[
                 MenuItemButton(
                   child: Center(
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.start,
                       children: [
                         Icon(Icons.help_rounded),
                         SizedBox(width: 10),
                         Text(S.of(context).help)
                       ],
                     ),
                   ),
                   onPressed: () => Utilities().showHelpDialog(
                       context,
                       selectedIndex ==  0 ? "Offen" :
                       selectedIndex == 1 ? "MainPage" :
                       "ActivitySummary"),
                 ),
                 MenuItemButton(
                   child: Center(
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.start,
                       children: [
                         Icon(Icons.settings),
                         SizedBox(width: 10),
                         Text(S.of(context).settings)
                       ],
                     ),
                   ),
                   onPressed: () => openSettings(),
                 ),
                  //QR-Code generator fürs testen TODO: WICHTIG
                  //MenuItemButton(
                  //  child: Center(
                  //    child: Row(
                  //      mainAxisAlignment: MainAxisAlignment.start,
                  //      children: [
                  //        Icon(Icons.settings),
                  //        SizedBox(width: 10),
                  //        Text("ShowQrCode")
                  //      ],
                  //    ),
                  //  ),
                  //  onPressed: () => Utilities().showQrCode(context),
                 // )
               ],
               builder: (BuildContext context, MenuController controller, Widget? child) {
                 return TextButton(
                   focusNode: FocusNode(),
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
            NotAnsweredPage(key: GlobalKey<NotAnsweredState>(),), //_notAnsweredKey TODO? testen ersetzen mit GlobalKey<NotAnsweredState>()
            //Seite 2 (Hauptseite):
            CustomScrollView( //Wegen Evtl Einbindung von Illustration über Liste, die mitscrollen soll
            slivers: [
              // Das Bild als "Sliver" für das Scrollen
               SliverToBoxAdapter(
                child: themeIllustration
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
      bottomNavigationBar:
        Container(
          padding: EdgeInsets.only(top:0),
          decoration: BoxDecoration(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15) ,topRight:Radius.circular(15) )
          ),
          child: BottomNavigationBar(
            elevation: 15,
            backgroundColor: MyApp.of(context).themeMode == ThemeMode.dark ? Colors.transparent : Theme.of(context).appBarTheme.foregroundColor,
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
                label: S.of(context).open,
              ),
              BottomNavigationBarItem(
                icon: selectedIndex == 1 ? Icon(Icons.home) : Icon(
                    Icons.home_outlined),
                label:  S.of(context).home,
              ),
              BottomNavigationBarItem(
                icon: selectedIndex == 2 ? Icon(Icons.summarize) : Icon(
                    Icons.summarize_outlined),
                label:  S.of(context).overview,
              ),
            ],
          ),
        ),
      floatingActionButton: selectedIndex == 1 ? FloatingActionButton(
        onPressed: () async {
          //print(CreateDummyJsonForTesting().toJsonString());
         var result = await Navigator.of(context).push(
           MaterialPageRoute(
             builder: (context) => BarcodeScannerSimple(),
           ),
         );
         print("RESULT: $result");
         if(result != null){
             List<WeekTileData> weekLists = await ImportJson().loadDummyDataForQr(result);
             for (WeekTileData data in weekLists) {
               data.toString();
               addEntry(data);
             }
         }
         //ImportJson().loadDummyDataForQr(CreateDummyJsonForTesting().toCompressedIntList());
         //List<WeekTileData> weekLists = await ImportJson().loadDummyData(""); //Testing version
         //for (WeekTileData data in weekLists) {
         //  data.toString();
         //  addEntry(data);
         //}
        },
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        child: Icon(Icons.add_box),
      ) : SizedBox(),
    );
  }
}

/*TODO! WICHTIG: TESTEN WELCHE VERSION BELIEBTER IST: Das hier ist version mit fester illustration, bietet sich für Querformat an
LayoutBuilder(
              builder: (context, constraints) {
                bool isPortrait = constraints.maxWidth < 600;
                return isPortrait ? Column(
                  children: [
                    themeIllustration,
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black,
                              Colors.black,
                              Colors.transparent
                            ],
                            stops: [0.0, 0.03, 0.95, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
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
                    ),
                  ],
                )
                    : Row(
                  children: [
                    if(themeIllustration is! SizedBox) Expanded(
                        child: themeIllustration
                    ) else SizedBox(width: 80,),
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black,
                              Colors.black,
                              Colors.transparent
                            ],
                            stops: [0.0, 0.03, 0.95, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
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
                    ),
                    if(themeIllustration is! SizedBox) SizedBox(width: 0,) else SizedBox(width: 80,),
                  ],
                );
              },
            ),
 */
/*
TODO: Alternative zum laden der Wochenpläne die nicht auf weekKey und Weeklytable-Datenbanktabelle beruht
void checkDatabaseAlternative() async {
    Database db = await databaseHelper.database;
    List<Termin> termine1 = await DatabaseHelper().getAllTermine();
    DateTime firstDay = termine1.first.timeBegin;
    String firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstDay); // Format for use in the query
    DateTime endDay = firstDay.add(Duration(days: 6));
    String endWeekDayString = DateFormat("yyyy-MM-dd").format(endDay);

    for (Termin t in termine1) {
      if(t.timeBegin.difference(firstDay) > Duration(days: 6)){
        String query = '''
        SELECT *
        FROM Termine
        WHERE date(timeBegin) BETWEEN date(?) AND date(?);
         ''';
        List<Map<String, dynamic>> oneWeek = await db.rawQuery(query, [firstWeekDayString, endWeekDayString]);
        List<Termin> oneWeekTermine = DatabaseHelper().mapToTerminList(oneWeek);
        for (Termin te in oneWeekTermine) {
          print(te.toString());
        }
        String title1 = "$firstWeekDayString - $endWeekDayString";
        WeekTileData data = WeekTileData(icon: Icons.date_range, title: title1, weekKey: firstWeekDayString);
        addEntry(data);
        if(DateTime.parse(firstWeekDayString).difference(DateTime.now()).isNegative){ //Checkt ob die gesamte Woche in der Vergangenheit liegt
          //print("Week already passed");
        } else {
          initializeNotifications(firstWeekDayString);
        }
        //else if(DateTime.parse(weekKey).difference(DateTime.now()) > Duration(days: 7)){ //Checkt ob der Wochenstart mehr als eine Woche in der Zukunft liegt
        //  print("Week more than a week in the future");
        //}
        DatabaseHelper().updateActivities(firstWeekDayString);
    }
      while (t.timeBegin.difference(firstDay) > Duration(days: 6)) {
        firstDay = t.timeBegin;
        firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstDay);
        endDay = firstDay.add(Duration(days: 6));
        endWeekDayString = DateFormat("yyyy-MM-dd").format(endDay);
      }

    }
  }
 */

//PageView alternate Children
/*          Column(
              children: [
                themeIllustration,
                Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                        }),
                )
              ],
            ),
*/
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
                  builder: (context) => AlertDialog(
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
          ),*/
//SQLITE unabhängige funktion, falls Wochen-Durchschnittswerte noch relevant werden
/*List<Map<String, dynamic>> weekPlans = await databaseHelper.getAllWeekPlans();
    if (weekPlans.isEmpty) return;

    print("weekplanLength: ${weekPlans.length}");
    for (var weekPlan in weekPlans) {
      String weekKey = weekPlan["weekKey"];

      //Konvertiert standard DateTime in  DE-standard
      DateTime endOfWeek = DateTime.parse(weekKey).add(Duration(days: 6));
      String startOfWeekString = DateFormat("dd-MM-yyyy").format(DateTime.parse(weekKey));
      String endOfWeekString = DateFormat("dd-MM-yyyy").format(endOfWeek);
      String title1 = "$startOfWeekString - $endOfWeekString";

      WeekTileData data = WeekTileData(icon: Icons.date_range, title: title1, weekKey: weekKey);
      addEntry(data);

      initializeNotifications(weekKey);
    }*/
//testKey = weekPlans[1]["weekKey"];
//await notificationHelper.scheduleTestNotification(testKey); //Testing