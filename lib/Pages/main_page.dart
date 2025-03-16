import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menta_track/Pages/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../generated/l10n.dart';
import '../helper_utilities.dart';
import '../import_json.dart';
import '../main.dart';
import '../notification_helper.dart';
import '../theme_helper.dart';
import '../week_tile.dart';
import '../week_tile_data.dart';
import 'activity_summary.dart';
import 'barcode_scanner_simple.dart';
import 'not_answered_page.dart';

//TODO: RANDOMISIERTE ANTWORTEN VERBESSERN

//TODO STUDY: Erste Benachrichtigung 1 min nach schließen des Hilfe-Dialogs
//TODO STUDY: Zweite Benachrichtigung 30 sek nach zurückkehren von Settings
///Startseite der Anwendung mit PageView

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with WidgetsBindingObserver, RouteAware{
  DatabaseHelper databaseHelper = DatabaseHelper();
  NotificationHelper notificationHelper = NotificationHelper();
  final PageController _pageController = PageController(initialPage: 1);
  final GlobalKey<NotAnsweredState> _notAnsweredKey = GlobalKey<NotAnsweredState>();
  Widget themeIllustration = SizedBox();
  int selectedIndex = 1;
  int rememberAnsweredTasks = 0;
  int rememberTotalTasks = 0;
  int openTasks = 0;
  List<WeekTileData> items = [];



  @override
  void initState() {
    super.initState();
    loadTheme();
    loadDatabaseAndNotifications();
  }

  ///Checkt, ob auf die Startseite zurückgekehrt wurde und ob es Änderungen in der Datenbank gab
  @override
  void didPopNext() {
    checkForChange();
    //updateItems();
    super.didPopNext();
  }

  ///Subscribed zu dem Routeobserver
  @override
  void didChangeDependencies() {
    if (ModalRoute.of(context)?.isCurrent == true) {
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    }
    super.didChangeDependencies();
  }

  ///prüft die Datenbank auf Einträge, lädt sie in die Listenansicht und plant Notifications (TO_DO?: Datenbankeintrag mit „Notificationssheduled“ zur WeeklyPlans-Table hinzufügen, damit keine tatsächlichen Benachrichtigungen geprüft werden müssen, der Nachteil ist, dass es nur indirekt überprüft wird)
  void loadDatabaseAndNotifications()  {
    checkForFirstStart();
    updateItems();
    ///Nur beim start sollen benachrichtigungen gecheckt/geladen werden
    notificationHelper.startListeningNotificationEvents();
    notificationHelper.loadAllNotifications(false);

  }

  ///Lädt die Liste neu
  Future<void> updateItems() async {
    items.clear();
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
      String title = "${weekPlan["startOfWeekString"]} - ${weekPlan["endOfWeekString"]}";
      WeekTileData data = await WeekTileState().getWeekTileData(weekKey, title); //Genriert Daten für die Tiles

      addEntry(data);
    }

    ///Sortiert die Wochen, sodass die aktuellste oben angezeigt wird
    items.sort((a, b) {
      DateTime dateA = DateTime.parse(a.weekKey);
      DateTime dateB = DateTime.parse(b.weekKey);
      return dateB.compareTo(dateA);
    });
    rememberAnsweredTasks = await databaseHelper.getAllTermineCount(true,true);
    rememberTotalTasks = await databaseHelper.getAllTermineCountUnconditional();
    openTasks = await DatabaseHelper().getAllTermineCount(false, true);
    //String testKey = weekPlans[2]["weekKey"];
    //await notificationHelper.scheduleTestNotification(testKey); //Testing
  }

  ///Checkt ob es Änderungen in der Datenbank gab
  Future<void> checkForChange() async {
    int newRememberAnsweredTasks = await databaseHelper.getAllTermineCount(true,true);
    int newRememberTotalTasks = await databaseHelper.getAllTermineCountUnconditional();
    if(rememberAnsweredTasks != newRememberAnsweredTasks || rememberTotalTasks != newRememberTotalTasks){
      updateItems();
    }
  }

  ///Fügt der Liste einen Eintrag hinzu
  void addEntry(WeekTileData data) {
    setState(() {
      if (!items.contains(data)) {
        items.add(data);
      }
    });
  }

  ///löscht Eintrag aus der Liste
  void deleteItem(String weekKey) async {
    databaseHelper.dropTable(weekKey);
    NotificationHelper().loadAllNotifications(true); //Reload Notifications
  }

  /// Lädt die gespeicherte Settings-Werte
  void loadTheme() async {
    SettingData data = await SettingsPageState().getSettings();
    bool isDarkMode = data.isDarkMode;
    String name = data.name;
    String accentColor = data.accentColor;

    setState(() { //muss vor themeHelper geladen und angewendet werden, damit textfarbe je nach darkmode richtig geladen wird
      MyApp.of(context).changeTheme(isDarkMode ? ThemeMode.dark : ThemeMode.light);
      MyApp.of(context).changeColor(accentColor);
    });

    Widget image = SizedBox();
    if(mounted) image = await ThemeHelper().getIllustrationImage("MainPage");
    setState(() {
      MyApp.of(context).changeTheme(isDarkMode ? ThemeMode.dark : ThemeMode.light);
      themeIllustration = image;
      name;
    });
  }

  ///Checkt nach erstem Start und zeigt ein Tutorial an
  Future<void> checkForFirstStart() async {
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getBool("firstStart") == null && mounted){
      Utilities().showHelpDialog(context, "MainPageFirst");
      prefs.setBool("firstStart", true);
    }
  }

  ///Öffnet die Settings-Seite und schaut ob eine Einstellung verändert wurde
  Future<void> openSettings() async {
    bool? changed = await navigatorKey.currentState?.push(
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
        //NotificationHelper().scheduleStudyDayNotification(); //TODO !STUDY!: 2te Benachrichtigung FÜR STUDIE
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, result) {
      if (!didPop) {
        if(selectedIndex == 0 || selectedIndex == 2){ //Während des testen wurde die App mehrmals ausversehen geschlossen, wenn man auf der Übersichtsseite war
          setState(() {
            selectedIndex = 1;
          });
          _pageController.animateToPage(
            selectedIndex,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
           SystemNavigator.pop(); //Funktioniert nicht auf IOS, in IOS soll einfach nichts gemacht werden, es ist intended, dass Apps durch den HOME-Button geschlossen werden
        }
      }
    },
    child: Scaffold(
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
                  /// # QR-Code generator
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
                  //)
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
            if(selectedIndex == 0){
              if(selectedIndex+1 == 1){
                checkForChange();
              }
            }
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
            ///Seite 1 (OffenSeite)
            NotAnsweredPage(key: _notAnsweredKey,),
            ///Seite 2 (Hauptseite):
            LayoutBuilder(
              builder: (context, constraints) {
                bool isPortrait = constraints.maxWidth < 600;
                return isPortrait ? CustomScrollView(
                  slivers: [
                    // Das Bild als "Sliver" für das Scrollen
                    SliverToBoxAdapter(
                        child: themeIllustration
                    ),
                    // Der ListView als Sliver
                    if(items.isEmpty)SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.all(40),
                        child: Text(S.current.mainPage_noEntries_text, textAlign: TextAlign.center,),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          return WeekTile(
                            item: items[index],
                            onDeleteTap: () async {
                              deleteItem(items[index].weekKey);
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
                ) : Row( ///Horizontales Layout
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
                                deleteItem(items[index].weekKey);
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
            /// Seite 3 "ÜbersichtsSeite":
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
          //backgroundColor: MyApp.of(context).themeMode == ThemeMode.dark ? Colors.transparent : Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          currentIndex: selectedIndex,
          onTap: (int index) {
            if(selectedIndex == 0){
              if(index == 1){
                checkForChange();
              }
            }
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
              icon: openTasks > 0 ? Badge(
                isLabelVisible: true,
                label: Text(openTasks.toString()),
                offset: Offset(8, 8),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: selectedIndex == 0 ?
                  Icon(Icons.inventory_rounded) :
                  Icon(Icons.inventory_outlined)
              ) : openTasks == 0 && selectedIndex == 0 ?
                  Icon(Icons.inventory_rounded) :
                  Icon(Icons.inventory_outlined),
              label: S.of(context).open,
            ),
            BottomNavigationBarItem(
              icon: selectedIndex == 1 ? Icon(Icons.home) : Icon(
                  Icons.home_outlined),
              label:  S.of(context).home,
            ),
            BottomNavigationBarItem(
              icon: selectedIndex == 2 ? Icon(Icons.insights) : Icon(
                  Icons.insights_outlined),
              label:  S.of(context).overview,
            ),
          ],
        ),
      ),
      floatingActionButton: selectedIndex == 1 ? FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BarcodeScannerSimple(),
            ),
          );
          if(result != null){
            await ImportJson().loadDummyDataForQr(result);
            updateItems();
            NotificationHelper().loadAllNotifications(true); //Reload Benachrichtigungen
          }
        },
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        child: Icon(Icons.add_box),
      ) : SizedBox(),
    )
    );
  }
}