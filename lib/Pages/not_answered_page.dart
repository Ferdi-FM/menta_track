import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menta_track/Pages/question_page.dart';
import 'package:menta_track/Pages/settings.dart';
import 'package:menta_track/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../termin_data.dart';
import '../not_answered_tile.dart';
import '../theme_helper.dart';

///Übersichtsseite über alle unbeantworteten Aktivitäten

class NotAnsweredPage extends StatefulWidget {
  const NotAnsweredPage({super.key,});

  @override
  NotAnsweredState createState() => NotAnsweredState();
}

class NotAnsweredState extends State<NotAnsweredPage> with RouteAware {
  List<TerminData> _itemsNotAnswered = [];
  Widget _themeIllustration = SizedBox();
  bool _showOnlyOnMainPage = false;
  bool _hapticFeedback = false;
  int _rememberUnAnsweredTasks = 0;

  @override
  void initState() {
    setUpPage();
    super.initState();
  }

  ///Checkt, ob auf die Startseite zurückgekehrt wurde und ob es Änderungen in der Datenbank gab
  @override
  void didPopNext() {
    if(mounted)checkForChange();
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

  ///Checkt ob es Änderungen in der Datenbank gab
  Future<void> checkForChange() async {
    int newUnAnsweredTasks = await DatabaseHelper().getAllTermineCount(false, true);
    if(newUnAnsweredTasks != _rememberUnAnsweredTasks) setUpPage();
  }

  ///Lädt alle unbeantworteten Aktivitäten aus der Datenbank und fügt sie in eine Liste ein
  Future<List<TerminData>> loadNotAnswered() async {
    List<TerminData> items = [];
    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
        "Termine",
        where: "answered = ? AND (datetime(timeBegin) < datetime(CURRENT_TIMESTAMP))",
        whereArgs: [0]
    );
    if(maps.isNotEmpty) {
      _rememberUnAnsweredTasks = maps.length;
    } else {
      _rememberUnAnsweredTasks = 0;
    }
    for (Map<String, dynamic> map in maps) {
      String terminName = map["terminName"];
      String weekKey = map["weekKey"];
      String timeBegin = map["timeBegin"];
      String timeEnd = map["timeEnd"];
      TerminData data = TerminData(
          icon: Icons.priority_high_rounded,
          terminName: terminName,
          dayKey: timeBegin,
          timeEnd: timeEnd,
          weekKey: weekKey);
      items.add(data);
    }
    return items;
  }

  ///Öffnet ein Item via ScaleAnimation, diese lässt die Seite aus dem Listelement "herauswachsen"
  dynamic openItem(TerminData data, var ev) async {
    if(_hapticFeedback) HapticFeedback.lightImpact();
    Offset pos = ev.globalPosition;
    return await navigatorKey.currentState?.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              QuestionPage(
                  weekKey: data.weekKey,
                  timeBegin: data.dayKey,
                  timeEnd: data.timeEnd,
                  terminName: data.terminName),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;

            // Erstelle eine Skalierungs-Animation
            var tween = Tween<double>(begin: 0.1, end: 1.0).chain(CurveTween(curve: curve));
            var scaleAnimation = animation.drive(tween);

            return ScaleTransition(
              scale: scaleAnimation,
              alignment: Alignment(0, pos.dy / MediaQuery.of(context).size.height * 2 - 1),
              child: child,
            );
          },
        )
    );
  }

  ///lädt thema und items und updatet den State
  void setUpPage() async {
    loadTheme();
    _itemsNotAnswered = await loadNotAnswered();

  }

  ///lädt das App-Theme
  void loadTheme() async {
    SettingData data = await SettingsPageState().getSettings();
    _showOnlyOnMainPage = data.themeOnlyOnMainPage;
    _hapticFeedback = await SettingsPageState().getHapticFeedback();
    setState(() {

    });
    Widget image = SizedBox();
    if (mounted) image = await ThemeHelper().getIllustrationImage("OpenPage"); //mounted redundant, kann wrsch. entfernt werden
    setState(() {
      _themeIllustration = image;
      _showOnlyOnMainPage;
      _hapticFeedback;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isPortrait = constraints.maxWidth < 600;
          return isPortrait ? Column(
            children: [
              _themeIllustration,
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
                  child: _itemsNotAnswered.isNotEmpty ? ListView.builder(
                    itemCount: _itemsNotAnswered.length,
                    itemBuilder: (context, index) {
                      return NotAnsweredTile(
                        item: _itemsNotAnswered[index],
                        onItemTap: (ev) async {
                          final result = await openItem(_itemsNotAnswered[index], ev);
                          if (result != null) {
                            setState(() {
                              _itemsNotAnswered.removeAt(index);
                            });
                          }
                        },
                      );
                    },
                  ): Container(
                      padding: EdgeInsets.all(40),
                      child: Text(S.current.themeHelper_open_msg1(0)),
                    ),
                ),
              ),
            ],
          ) : Row( ///Landscape Layout
            children: [
              if(_themeIllustration is! SizedBox) Expanded(
                  child: _themeIllustration
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
                    itemCount: _itemsNotAnswered.length,
                    itemBuilder: (context, index) {
                      return NotAnsweredTile(
                        item: _itemsNotAnswered[index],
                        onItemTap: (ev) async {
                          final result = await openItem(_itemsNotAnswered[index], ev);
                          if (result != null) {
                            setState(() {
                              //Teilweise seltsames Verhalten und aufgerufen, bevor QuestionPage gepopt ist?
                              _itemsNotAnswered.removeAt(index);
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              if(_themeIllustration is! SizedBox) SizedBox(width: 0,) else SizedBox(width: 80,), //Zusätzlicher Abstand, falls keine illustration gewählt wurde
            ],
          );
        },
      ),
    );
  }
}