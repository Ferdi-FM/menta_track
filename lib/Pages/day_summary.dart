import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/question_page.dart';
import 'package:menta_track/Pages/settings.dart';
import 'package:menta_track/database_helper.dart';
import '../answered_tile.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../termin_data.dart';
import '../termin.dart';
import '../theme_helper.dart';

///Übersichtsseite über alle unbeantworteten Aktivitäten

class DaySummary extends StatefulWidget {
  const DaySummary({
    super.key,
  });

  @override
  DaySummaryState createState() => DaySummaryState();
}

class DaySummaryState extends State<DaySummary> with RouteAware {
  List<TerminData> _itemsAnswered = [];
  List<TerminData> _itemsNotAnswered = [];
  Widget _themeIllustration = SizedBox();
  bool _noActivities = false;
  int _activitiesTillNow = 0;
  int _rememberAnsweredTasks = 0;
  int _rememberUnAnsweredTasks = 0;

  bool hapticFeedback = false;

  @override
  void initState() {
    setUpPage();
    super.initState();
  }

  ///Checkt, ob auf die Startseite zurückgekehrt wurde und ob es Änderungen in der Datenbank gab
  @override
  void didPopNext() {
    if(mounted) checkForChange();
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
    int newAnswered = await DatabaseHelper().getDayTermineAnswered(DateFormat("yyyy-MM-dd").format(DateTime.now()), true).then((result) => result.length);
    int newUnAnswered = await DatabaseHelper().getDayTermineAnswered(DateFormat("yyyy-MM-dd").format(DateTime.now()), false).then((result) => result.length);
    if(newAnswered != _rememberAnsweredTasks || newUnAnswered != _rememberUnAnsweredTasks) setUpPage();
  }

  ///Lädt alle Aktivitäten aus der Datenbank für diesen Tag und fügt sie in eine Liste ein
  Future<List<TerminData>> loadTasks(bool answered) async {
    List<TerminData> items = [];
    List<Termin> tasks = await DatabaseHelper().getDayTermineAnswered(DateFormat("yyyy-MM-dd").format(DateTime.now()), answered);
    if(answered) {
      _rememberAnsweredTasks = tasks.length;
    } else {
      _rememberUnAnsweredTasks = tasks.length;
    }
    for (Termin t in tasks) {
      String terminName = t.terminName;
      String weekKey = t.weekKey;
      String timeBegin = t.timeBegin.toIso8601String();
      String timeEnd = t.timeEnd.toIso8601String();
      bool isAfterNow = DateTime.now().isAfter(t.timeBegin);
      if(isAfterNow) _activitiesTillNow += 1;
      TerminData data = TerminData(
          icon: answered ? Icons.check_circle_outline_outlined : isAfterNow ? Icons.help_outline : Icons.pending_actions_outlined,
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
    Offset pos = ev.globalPosition;
    return await navigatorKey.currentState?.push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => QuestionPage( //weitere Daten werden auf QuestionPage geladen
          weekKey: data.weekKey,
          timeBegin: data.dayKey,
          timeEnd: data.timeEnd,
          terminName: data.terminName),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;

        // Erstelle eine Skalierungs-Animation
        var tween =
            Tween<double>(begin: 0.1, end: 1.0).chain(CurveTween(curve: curve));
        var scaleAnimation = animation.drive(tween);

        return ScaleTransition(
          scale: scaleAnimation,
          alignment:
              Alignment(0, pos.dy / MediaQuery.of(context).size.height * 2 - 1),
          child: child,
        );
      },
    ));
  }

  ///lädt thema und items und updatet den State
  void setUpPage() async {
    _itemsNotAnswered = await loadTasks(false);
    _itemsAnswered = await loadTasks(true);
    if(_itemsNotAnswered.length + _itemsAnswered.length == 0){
      _noActivities = true;
    }
    if(mounted){ //Hat wenn schnell durch bottomNavigationBar geclickt wurde teilweise zu "setState() called after dispose()" geführt
      loadTheme();
      setState(() {
        _noActivities;
      });
    }

  }

  ///lädt das App-Theme
  void loadTheme() async {
    Widget image = SizedBox();
    hapticFeedback = await SettingsPageState().getHapticFeedback();
    //Zur sicherheit, da durch await ThemeHelper teilweise setState nach dispose() aufgerufen wurde
    if(mounted) image = await ThemeHelper().getIllustrationImage("TodayPage");
    if (mounted) {
      setState(() {
        _themeIllustration = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isPortrait = constraints.maxWidth < 600;
          return isPortrait
              ? ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                stops: [0.0, 0.05, 0.95, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child:SingleChildScrollView(
                child:  Column(
                    children: [
                      _themeIllustration,
                      Text(S.current.today_Headline1, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).appBarTheme.backgroundColor)),
                      _itemsNotAnswered.isNotEmpty
                          ? Column(
                          children: List.generate(_itemsNotAnswered.length, (index) {
                          return AnsweredTile(
                            answered: false,
                            item: _itemsNotAnswered[index],
                            onItemTap: (ev) async {
                              if(hapticFeedback) HapticFeedback.lightImpact();
                              final result = await openItem(_itemsNotAnswered[index], ev);
                              if (result != null) {
                                setState(() {
                                  setUpPage(); //Aktuallisiert Einfach die gesamte Seite
                                });
                              }
                              },
                            );
                          },
                          )
                      ) : Container(
                        padding: EdgeInsets.all(40),
                        child: _noActivities
                              ? Text(S.current.today_nothingToAnswer)
                              : Text(S.current.today_allAnswered),
                        ),
                        SizedBox(height: 20,),
                        Text(S.current.today_Headline2, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).appBarTheme.backgroundColor), textAlign: TextAlign.center,),
                        _itemsAnswered.isNotEmpty ? Column(
                            children: List.generate(_itemsAnswered.length, (index){
                            return AnsweredTile(
                              answered: true,
                              item: _itemsAnswered[index],
                              onItemTap: (ev) async {
                                if(hapticFeedback) HapticFeedback.lightImpact();
                                final result = await openItem(_itemsAnswered[index], ev);
                                if (result != null) {
                                  setUpPage(); //Aktuallisiert Einfach die gesamte Seite
                                }
                              },
                            );
                          },
                            )
                        ) : Container(
                          padding: EdgeInsets.all(40),
                          child: _noActivities
                              ? Text(S.current.today_hopeForGood)
                              : _activitiesTillNow > 0
                              ? Text(S.current.themeHelper_open_msg1(_itemsNotAnswered.length))
                              : Text(S.current.today_nothingToAnswerYet, textAlign: TextAlign.center,),
                        ),
                      ],
                ),
            ),
          ) : Row(
                  ///Landscape Layout
                  children: [
                    if (_themeIllustration is! SizedBox)SizedBox(width: MediaQuery.of(context).size.width*0.5,child: _themeIllustration)
                    else SizedBox(width: 80,),
                    SizedBox(width: MediaQuery.of(context).size.width*0.5,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                              stops: [0.0, 0.1, 0.90, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child:SingleChildScrollView(
                            child:  Column(
                              children: [
                                SizedBox(height: 10,),
                                Text(S.current.today_Headline1, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).appBarTheme.backgroundColor),),
                                _itemsNotAnswered.isNotEmpty
                                    ? Column(
                                    children: List.generate(_itemsNotAnswered.length, (index) {
                                      return AnsweredTile(
                                        answered: false,
                                        item: _itemsNotAnswered[index],
                                        onItemTap: (ev) async {
                                          if(hapticFeedback) HapticFeedback.lightImpact();
                                          final result = await openItem(_itemsNotAnswered[index], ev);
                                          if (result != null) {
                                            setState(() {
                                              setUpPage(); //Aktuallisiert Einfach die gesamte Seite
                                            });
                                          }
                                        },
                                      );
                                      },
                                    )
                                )
                                : Container(
                              padding: EdgeInsets.all(40),
                              child: _noActivities
                                  ? Text(S.current.today_nothingToAnswer)
                                  : Text(S.current.today_allAnswered),
                            ),
                            SizedBox(height: 20,),
                            Text(S.current.today_Headline2, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).appBarTheme.backgroundColor),),
                            _itemsAnswered.isNotEmpty ? Column(
                                children: List.generate(_itemsAnswered.length, (index){
                                  return AnsweredTile(
                                    answered: true,
                                    item: _itemsAnswered[index],
                                    onItemTap: (ev) async {
                                      if(hapticFeedback) HapticFeedback.lightImpact();
                                      final result = await openItem(_itemsAnswered[index], ev);
                                      if (result != null) {
                                        setUpPage(); //Aktuallisiert Einfach die gesamte Seite
                                      }
                                    },
                                  );
                                },
                                )
                            ) : Container(
                              padding: EdgeInsets.all(40),
                              child: _noActivities
                                  ? Text(S.current.today_hopeForGood)
                                  : _activitiesTillNow > 0
                                  ? Text(S.current.themeHelper_open_msg1(_itemsNotAnswered.length))
                                  : Text(S.current.today_nothingToAnswerYet, textAlign: TextAlign.center,),
                            ),
                            SizedBox(height: 10,)
                          ],
                        ),
                      ),
                    )
                    ),
                    if (_themeIllustration is! SizedBox)
                      SizedBox(
                        width: 0,
                      )
                    else
                      SizedBox(
                        width: 80,
                      ),
                  ],
          );
        },
      ),
    );
  }
}