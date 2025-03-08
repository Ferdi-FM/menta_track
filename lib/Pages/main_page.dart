import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/settings.dart';
import 'package:menta_track/Pages/week_plan_view.dart';
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
  int remeberAnsweredTasks = 0;
  List<WeekTileData> items = [];

  @override
  void initState() {
    super.initState();
    loadTheme();
    loadDatabaseAndNotifications();
  }

  @override
  void didPopNext() {
    updateItems();
    super.didPopNext();
  }

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
    ///Falls die Liste neu geladen werden muss soll nicht noch aufwendig nach benachrichtigungen geschaut werden
    notificationHelper.startListeningNotificationEvents(); //TODO: Aktivieren testen
    notificationHelper.loadAllNotifications(false); //TODO: Aktivieren testen

  }

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
      WeekTileData data = await getWeekTileData(weekKey, title);

      addEntry(data);
    }
    ///Sortiert die Wochen, sodass die neueste oben angezeigt wird
    items.sort((a, b) {
      DateTime dateA = DateTime.parse(a.weekKey);
      DateTime dateB = DateTime.parse(b.weekKey);
      return dateB.compareTo(dateA);
    });
    remeberAnsweredTasks = await databaseHelper.getAllTermineCount(true,true);
    //String testKey = weekPlans[2]["weekKey"];
    //await notificationHelper.scheduleTestNotification(testKey); //Testing
  }

  ///Erzeugt ein WeekTile je nach wann es ist und wie viel Feedback gegeben wurde
  //TODO: verschieben in WekkTile? Gute Idee? WeekTileData nur weekKey und title?
  Future<WeekTileData> getWeekTileData(String weekKey, String title) async {
    final db = await databaseHelper.database;
    int allWeekTasks = await databaseHelper.getWeekTermineCount(weekKey);
    ///Query sucht nach allen bis jetzt noch nicht beantworteten Terminen in der Woche
    String query = "SELECT COUNT(*) FROM Termine WHERE weekKey = ? AND answered = ? AND (datetime(timeBegin) < datetime(CURRENT_TIMESTAMP))";
    int unAnsweredWeekTasks = Sqflite.firstIntValue(await db.rawQuery(query, [weekKey,0])) ?? 0;
    int answeredWeekTasks = Sqflite.firstIntValue(await db.rawQuery(query, [weekKey,1])) ?? 0;

    WeekTileData data;
    DateTime weekKeyDateTime = DateTime.parse(weekKey);
    String subtitle = "${S.current.activities}: $allWeekTasks  ${S.current.open_singular}: $unAnsweredWeekTasks";

    ///aktuelle Woche
    if (DateTime.now().isAfter(weekKeyDateTime) && DateTime.now().isBefore(weekKeyDateTime.add(Duration(days: 6)))) {
      data = WeekTileData(icon: Icon(Icons.today), title: title, weekKey: weekKey, subTitle: subtitle);
    }
    ///Liegt in der Zukunft
    else if (DateTime.now().isBefore(weekKeyDateTime)) {
      subtitle = S.current.not_yet_single;
      data = WeekTileData(icon: Icon(Icons.lock_clock), title: title, weekKey: weekKey, subTitle: subtitle);
    }
    ///Alles beantwortet
    else if (allWeekTasks == answeredWeekTasks) {
      subtitle = S.current.done;
      data = WeekTileData(icon: Icon(Icons.event_available, color: Colors.green), title: title, weekKey: weekKey, subTitle: subtitle);
    }
    ///alles andere
    else {
      if(unAnsweredWeekTasks == 0){
        subtitle ="nichts offen, super! 👍";
      }
      data = WeekTileData(icon: Icon(Icons.free_cancellation), title: title, weekKey: weekKey, subTitle: subtitle);
    }
    return data;
  }

  Future<void> checkForChange() async {
    int newRemember = await databaseHelper.getAllTermineCount(true,true);
    if(remeberAnsweredTasks != newRemember){
      updateItems();
    } else {
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
    DateFormat format = DateFormat("dd.MM.yyyy");
    DateTime displayDateString = format.parse(weekKey.substring(0, 10));
    String correctedDate = DateFormat("yyyy-MM-dd").format(displayDateString);
    databaseHelper.dropTable(correctedDate);
    databaseHelper.updateActivities(weekKey);
  }

  /// Lädt den gespeicherte Settings-Werte
  void loadTheme() async {
    SettingData data = await SettingsPageState().getSettings();
    bool isDarkMode = data.isDarkMode;
    String name = data.name;
    String accentColor = data.accentColor;

    setState(() { //Unschön, aber muss vor themeHelper geladen werden, damit textfarbe je nach darkmode richtig geladen wird
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

  //TODO: Lokalisieren
  Future<void> checkForFirstStart() async {
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getBool("firstStart") == null && mounted){
      Utilities().showHelpDialog(context, "MainPageFirst");
      prefs.setBool("firstStart", true);
    }
  }

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
      }
    }
  }

  ///Öffnet einen Wochenplan. Muss hier sein, damit die Liste geupdatet wird, falls
  void openItem(String weekKey) async{
    var result = await navigatorKey.currentState?.push(
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
    if(result != null){
      if(result == "updated"){
        ///Checkt ob die Woche komplett beantwortet wurde und aktualisiert die Ansicht, wenn es der Fall ist
        checkForChange();
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
            NotAnsweredPage(key: _notAnsweredKey,),
            //Seite 2 (Hauptseite):
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
                        //TODO: Lokalisieren
                        child: Text("Du hast noch keine Wochenpläne ;)\n Tippe auf den Button in der Ecke rechts unten um den QR-Code scanner zu öffnen un einen Plan zu importieren :)", textAlign: TextAlign.center,),
                      ),
                    ),
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
                            onTap: (){
                              openItem(items[index].weekKey);
                            },
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                  ],
                ) : Row(
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
                              }, onTap: () {
                              openItem(items[index].weekKey);
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
            /// Seite "Übersicht":
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
            print(index);
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
          var result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BarcodeScannerSimple(),
            ),
          );
          if(result != null){
            List<WeekTileData> weekLists = await ImportJson().loadDummyDataForQr(result);
            for (WeekTileData data in weekLists) {
              //data.toString();
              addEntry(data);
            }
            ///Sortiert die Wochen
            items.sort((a, b) {
              DateTime dateA = DateTime.parse(a.weekKey);
              DateTime dateB = DateTime.parse(b.weekKey);
              return dateB.compareTo(dateA);
            });
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