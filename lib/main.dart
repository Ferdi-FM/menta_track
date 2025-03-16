import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Pages/main_page.dart';
import 'generated/l10n.dart';

//TODO: - Aufräumen

///Oberste App-Seite, verwendet für Themes & Navigation

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
        navigatorObservers: [routeObserver],
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("en", "US"),
        Locale("en", "GB"),
        Locale("de", "DE"),
        // Füge hier weitere Sprachen hinzu
      ],
      title: "Menta Track",
      theme: ThemeData(
        fontFamily: "Comfortaa",
        colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light),
        primaryColor: accentColorTwo,
        appBarTheme: AppBarTheme(color: accentColorOne.shade300,foregroundColor: Colors.black87),
        scaffoldBackgroundColor: accentColorOne.shade50,
        listTileTheme: ListTileThemeData(
          tileColor: Colors.white,
          textColor: Colors.black,
          iconColor: accentColorTwo,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: accentColorOne.shade100,
            selectedItemColor:accentColorTwo ,
            unselectedItemColor: Colors.black87,
            enableFeedback: true,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        fontFamily: "Comfortaa",
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        primaryColor: accentColorTwo,
        appBarTheme: AppBarTheme(color: accentColorOne.shade400, foregroundColor: Colors.black87, iconTheme: IconThemeData(color: Colors.black87)),
        scaffoldBackgroundColor: Colors.blueGrey.shade800,
        listTileTheme: ListTileThemeData(
          tileColor: Colors.grey.shade600,
          textColor: Colors.white,
          iconColor: accentColorTwo,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,  //Colors.blueGrey.shade700.withAlpha(100),
          selectedItemColor: accentColorTwo,
          unselectedItemColor: Colors.white70,
          enableFeedback: true
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      navigatorKey: navigatorKey,
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