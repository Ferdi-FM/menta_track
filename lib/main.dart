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
            selectedItemColor:accentColorOne.shade700 ,
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
          selectedItemColor: accentColorOne.shade400,
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

  ///Setzt die Akzentfarbe der App
  void changeColorDynamic(MaterialColor colorInput) {
      setState(() {
        accentColorTwo = colorInput.shade700;
        accentColorOne = colorInput;
        seedColor = colorInput;
      });
  }

  ///Alte funktion zum Farben speichern
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