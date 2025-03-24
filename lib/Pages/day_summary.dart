import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/question_page.dart';
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

class DaySummaryState extends State<DaySummary> {
  List<TerminData> itemsAnswered = [];
  List<TerminData> itemsNotAnswered = [];
  bool loaded = false;
  Widget themeIllustration = SizedBox();
  bool noActivities = false;
  int activitiesTillNow = 0;

  @override
  void initState() {
    setUpPage();
    super.initState();
  }

  ///Lädt alle Aktivitäten aus der Datenbank für diesen Tag und fügt sie in eine Liste ein
  Future<List<TerminData>> loadTasks(bool answered) async {
    List<TerminData> items = [];
    List<Termin> tasks = await DatabaseHelper().getDayTermineAnswered(DateFormat("yyyy-MM-dd").format(DateTime.now()), answered);

    for (Termin t in tasks) {
      String terminName = t.terminName;
      String weekKey = t.weekKey;
      String timeBegin = t.timeBegin.toIso8601String();
      String timeEnd = t.timeEnd.toIso8601String();
      bool isAfterNow = DateTime.now().isAfter(t.timeBegin);
      if(isAfterNow) activitiesTillNow += 1;
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
    //TODO: Checken ob Termin gelöscht wurde
  }

  ///lädt thema und items und updatet den State
  void setUpPage() async {
    loadTheme();
    itemsNotAnswered = await loadTasks(false);
    itemsAnswered = await loadTasks(true);
    if(itemsNotAnswered.length + itemsAnswered.length == 0){
      noActivities = true;
    }
    setState(() {
      loaded = true; //damit wenn nicht geladen ein ladesymbol angezeigt werden kann
      noActivities;
    });
  }

  ///lädt das App-Theme
  void loadTheme() async {
    Widget image = SizedBox();
    if (mounted) image = await ThemeHelper().getIllustrationImage("TodayPage"); //mounted redundant, kann wrsch. entfernt werden
    setState(() {
      themeIllustration = image;
    });
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
                      themeIllustration,
                      Text(S.current.today_Headline1, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).appBarTheme.backgroundColor)),
                      itemsNotAnswered.isNotEmpty
                          ? Column(
                          children: List.generate(itemsNotAnswered.length, (index) {
                          return AnsweredTile(
                            answered: false,
                            item: itemsNotAnswered[index],
                            onItemTap: (ev) async {
                              final result = await openItem(itemsNotAnswered[index], ev);
                              if (result != null) {
                                setState(() {
                                  setUpPage(); //Aktuallisiert Einfach die gesamte Seite
                                  //itemsAnswered.add(itemsNotAnswered[index]); //TODO: testen
                                  //itemsNotAnswered.removeAt(index);
                                  //loadTheme(); //Updated Anzeige in Überschrift
                                });
                              }
                              },
                            );
                          },
                          )
                      ) : Container(
                        padding: EdgeInsets.all(40),
                        child: noActivities
                              ? Text(S.current.today_nothingToAnswer)
                              : Text(S.current.today_allAnswered),
                        ),
                        SizedBox(height: 20,),
                        Text(S.current.today_Headline2, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).appBarTheme.backgroundColor), textAlign: TextAlign.center,),
                        itemsAnswered.isNotEmpty ? Column(
                            children: List.generate(itemsAnswered.length, (index){
                            return AnsweredTile(
                              answered: true,
                              item: itemsAnswered[index],
                              onItemTap: (ev) async {
                                final result = await openItem(itemsAnswered[index], ev);
                                if (result != null) {
                                  setUpPage(); //Aktuallisiert Einfach die gesamte Seite
                                }
                              },
                            );
                          },
                            )
                        ) : Container(
                          padding: EdgeInsets.all(40),
                          child: noActivities
                              ? Text(S.current.today_hopeForGood)
                              : activitiesTillNow > 0
                              ? Text(S.current.themeHelper_open_msg1(itemsNotAnswered.length))
                              : Text(S.current.today_nothingToAnswerYet, textAlign: TextAlign.center,),
                        ),
                      ],
                ),
            ),
          ) : Row(
                  ///Landscape Layout
                  children: [
                    if (themeIllustration is! SizedBox)SizedBox(width: MediaQuery.of(context).size.width*0.5,child: themeIllustration)
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
                                itemsNotAnswered.isNotEmpty
                                    ? Column(
                                    children: List.generate(itemsNotAnswered.length, (index) {
                                      return AnsweredTile(
                                        answered: false,
                                        item: itemsNotAnswered[index],
                                        onItemTap: (ev) async {
                                          final result = await openItem(itemsNotAnswered[index], ev);
                                          if (result != null) {
                                            setState(() {
                                              setUpPage(); //Aktuallisiert Einfach die gesamte Seite
                                              //itemsAnswered.add(itemsNotAnswered[index]); //TODO: testen
                                              //itemsNotAnswered.removeAt(index);
                                              //loadTheme(); //Updated Anzeige in Überschrift
                                            });
                                          }
                                        },
                                      );
                                      },
                                    )
                                )
                                : Container(
                              padding: EdgeInsets.all(40),
                              child: noActivities
                                  ? Text(S.current.today_nothingToAnswer)
                                  : Text(S.current.today_allAnswered),
                            ),
                            SizedBox(height: 20,),
                            Text(S.current.today_Headline2, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).appBarTheme.backgroundColor),),
                            itemsAnswered.isNotEmpty ? Column(
                                children: List.generate(itemsAnswered.length, (index){
                                  return AnsweredTile(
                                    answered: true,
                                    item: itemsAnswered[index],
                                    onItemTap: (ev) async {
                                      final result = await openItem(itemsAnswered[index], ev);
                                      if (result != null) {
                                        setUpPage(); //Aktuallisiert Einfach die gesamte Seite
                                      }
                                    },
                                  );
                                },
                                )
                            ) : Container(
                              padding: EdgeInsets.all(40),
                              child: noActivities
                                  ? Text(S.current.today_hopeForGood)
                                  : activitiesTillNow > 0
                                  ? Text(S.current.themeHelper_open_msg1(itemsNotAnswered.length))
                                  : Text(S.current.today_nothingToAnswerYet, textAlign: TextAlign.center,),
                            ),
                            SizedBox(height: 10,)
                          ],
                        ),
                      ),
                    )
                    ),
                    if (themeIllustration is! SizedBox)
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