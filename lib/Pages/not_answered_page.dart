import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:menta_track/Pages/question_page.dart';
import 'package:menta_track/Pages/settings.dart';
import 'package:menta_track/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../main.dart';
import '../not_answered_data.dart';
import '../not_answered_tile.dart';
import '../theme_helper.dart';

class NotAnsweredPage extends StatefulWidget {
  const NotAnsweredPage({super.key,});

  @override
  NotAnsweredState createState() => NotAnsweredState();
}

class NotAnsweredState extends State<NotAnsweredPage> {
  List<NotAnsweredData> itemsNotAnswered = [];
  bool loaded = false;
  Widget themeIllustration = SizedBox();
  bool _showOnlyOnMainPage = false;
  String name = "";

  @override
  void initState() {
    setUpPage();
    super.initState();
  }

  Future<List<NotAnsweredData>> loadNotAnswered() async {
    List<NotAnsweredData> items = [];
    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
        "Termine",
        where: "answered = ? AND (datetime(timeBegin) < datetime(CURRENT_TIMESTAMP))",
        whereArgs: [0]
    );
    for (Map<String, dynamic> map in maps) {
      String terminName = map["terminName"];
      String weekKey = map["weekKey"];
      String timeBegin = map["timeBegin"];
      NotAnsweredData data = NotAnsweredData(icon: Icons.priority_high_rounded,
          terminName: terminName,
          dayKey: timeBegin,
          weekKey: weekKey);
      items.add(data);
    }
    return items;
  }

  dynamic openItem(NotAnsweredData data, var ev) async {
    Offset pos = ev.globalPosition;

    return await navigatorKey.currentState?.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              QuestionPage(
                  weekKey: data.weekKey,
                  timeBegin: data.dayKey,
                  terminName: data.terminName),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;

            // Erstelle eine Skalierungs-Animation
            var tween = Tween<double>(begin: 0.01, end: 1.0).chain(
                CurveTween(curve: curve));
            var scaleAnimation = animation.drive(tween);

            return ScaleTransition(
              scale: scaleAnimation,
              alignment: Alignment(MediaQuery.of(context).size.width * 0.5, pos.dy / MediaQuery.of(context).size.height * 2 - 1),
              //x-Tap-position = pos.dx / MediaQuery.of(context).size.width * 2 - 1
              child: child,
            );
          },
        )
    );
  }

  void setUpPage() async {
    loadTheme();
    itemsNotAnswered = await loadNotAnswered();
    setState(() {
      loaded = true;
    });
  }

  void loadTheme() async {
    SettingData data = await SettingsPageState().getSettings();
    name = data.name;
    _showOnlyOnMainPage = data.themeOnlyOnMainPage;
    Widget image = SizedBox();
    if (mounted) image = await ThemeHelper().getIllustrationImage("OpenPage"); //Wird probleme mit context geben
    setState(() {
      themeIllustration = image;
      _showOnlyOnMainPage;
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
                  child: itemsNotAnswered.isNotEmpty ? ListView.builder(
                    itemCount: itemsNotAnswered.length,
                    itemBuilder: (context, index) {
                      return NotAnsweredTile(
                        item: itemsNotAnswered[index],
                        onItemTap: (ev) async {
                          final result = await openItem(itemsNotAnswered[index], ev);
                          if (result != null) {
                            setState(() {
                              itemsNotAnswered.removeAt(index);
                            });
                          } else {
                            if (kDebugMode) {
                              print("canceled");
                            }
                          }
                        },
                      );
                    },
                  ): Container(
                      padding: EdgeInsets.all(40),
                      child: Text("Gerade gibts nichts zu beantworten :)"),
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
                    itemCount: itemsNotAnswered.length,
                    itemBuilder: (context, index) {
                      return NotAnsweredTile(
                        item: itemsNotAnswered[index],
                        onItemTap: (ev) async {
                          final result = await openItem(itemsNotAnswered[index], ev);
                          if (result != null) {
                            setState(() {
                              //Teilweise seltsames Verhalten und aufgerufen, bevor QuestionPage gepopt ist?
                              itemsNotAnswered.removeAt(index);
                            });
                          } else {
                            if (kDebugMode) {
                              print("canceled");
                            }
                          }
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
    );
  }
}
      /* TODO! WICHTIG!: Hier scrollt die Illustration mit, dafür ist queres Layout nicht so schön

      CustomScrollView( //Wegen  Einbindung von Illustration über Liste, die mitscrollen soll
        slivers: [
          SliverToBoxAdapter(
              child: themeIllustration
          ),
          loaded ? SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return NotAnsweredTile(
                      item: itemsNotAnswered[index],
                      onItemTap: (ev) async {
                        final result = await openItem(
                            itemsNotAnswered[index],ev);
                        if (result != null) {
                          setState(() {
                            itemsNotAnswered.removeAt(index);
                          });
                        } else {
                          if (kDebugMode) {
                            print("canceled");
                          }
                        }
                      },
                    );
              },
              childCount: itemsNotAnswered.length,
            ),
          ) :  SliverToBoxAdapter(
              child: CircularProgressIndicator()
          ),
        ],
      ),*/

/*Old Build funktion
/*Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child:Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child:
                      ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                          _theme == "mascot" ? Image.asset( "assets/images/mascot/Mascot Klemmbrett Transparent.png", //Image.asset("assets/images/mascot/Mascot Wochenplan Transparent v2.png",
                            //width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.width * 0.4,
                          ):
                          _theme == "illustration" ? Image.asset( "assets/images/illustrations/flat-design illustration.png", //Image.asset("assets/images/mascot/Mascot Wochenplan Transparent v2.png",
                            width: MediaQuery.of(context).size.width * 0.5,
                          ): SizedBox(height: 0,)
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.04,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                            children: [
                              //TextSpan(text: "\n", style: TextStyle(fontSize: 20)),
                              TextSpan(text: "Offen: \n", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ,fontWeight: FontWeight.bold, fontSize: 18)),
                              TextSpan(text: "\n", style: TextStyle(fontSize: 5)),
                              TextSpan(text: "Hier findest du alle Termine angezeigt zu denen du noch kein Feedback gegeben hast ${Emojis.smile_winking_face}", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 17))
                            ]
                        )
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03,),
                ],
              )*/
            /*child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //SizedBox(width: MediaQuery.of(context).size.width * 0.2,),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child:
                        ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                            _theme == "mascot" ? Image.asset( "assets/images/mascot/Mascot Klemmbrett Transparent.png", //Image.asset("assets/images/mascot/Mascot Wochenplan Transparent v2.png",
                              //width: MediaQuery.of(context).size.width * 0.5,
                              height: MediaQuery.of(context).size.width * 0.4,
                            ):
                            _theme == "illustration" ? Image.asset( "assets/images/flat-design illustration.png", //Image.asset("assets/images/mascot/Mascot Wochenplan Transparent v2.png",
                              width: MediaQuery.of(context).size.width * 0.5,
                            ): SizedBox(height: 0,)
                        ),

                  ),
                  SizedBox(
                    width: 150,
                    child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                            children: [
                              TextSpan(text: "Offen: \n", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ,fontWeight: FontWeight.bold, fontSize: 18)),
                              TextSpan(text: "\n", style: TextStyle(fontSize: 5)),
                              TextSpan(text: "Hier findest du alle Termine angezeigt zu denen du noch kein Feedback gegeben hast ${Emojis.smile_winking_face}", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 17))
                            ]
                        )
                    ),
                  )
                ],
              )*/
    ALT loadNotAnswered:
    DatabaseHelper databaseHelper = DatabaseHelper();
    List<Map<String, dynamic>> weekPlans = await databaseHelper.getAllWeekPlans();
    for (var weekPlan in weekPlans) {
      String weekKey = weekPlan["weekKey"];
      List<Termin> weekAppointments = await databaseHelper.getWeeklyPlan(weekKey); //await muss nach den erstellen der CalendarHeader passieren
      for(Termin t in weekAppointments){
        if(!t.answered && DateTime.now().isAfter(t.timeEnd)){
          NotAnsweredData data = NotAnsweredData(icon: Icons.priority_high_rounded,terminName: t.terminName, dayKey: t.timeBegin.toIso8601String(), weekKey: weekKey);
          items.add(data);
        }
      }
    }
    print("forloop length: ${items.length}");
 */
