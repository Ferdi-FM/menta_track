import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menta_track/Pages/settings.dart';
import 'package:menta_track/Pages/week_plan_view.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:menta_track/sync_graph.dart';
import 'package:sqflite/sqflite.dart';
import 'package:string_similarity/string_similarity.dart';
import '../generated/l10n.dart';
import '../main.dart';

///Seite zum Anzeigen der allgemeinen Übersicht (Besondere Aktivitäten und Graph der Mittelwerte aller Wochen

class ActivitySummary extends StatefulWidget {

  const ActivitySummary({super.key,});

  @override
  ActivitySummaryState createState() => ActivitySummaryState();
}

class ActivitySummaryState extends State<ActivitySummary> with RouteAware{
  Map<String, List<Map<String, String>>> _activities = {};
  List<String> _adjectives = [" "," "," "];
  bool _loaded = false;
  bool _circleLoading = false;
  int _selectedButtonIndex = 3;
  int _selectedTimeButtonIndex = 2;
  bool _expandFilters = false;
  bool _hapticFeedback =false;

  @override
  void initState() {
    loadTheme();
    loadActivities(_selectedButtonIndex, 2);
    super.initState();
  }

  ///Checkt, ob auf die Startseite zurückgekehrt wurde und ob es Änderungen in der Datenbank gab
  @override
  void didPopNext() {
    if(mounted)loadActivities(_selectedButtonIndex, _selectedTimeButtonIndex); //Lädt die Seite neu, falls hierher zurückgekehrt wird
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

  void loadTheme() async{
    _hapticFeedback = await SettingsPageState().getHapticFeedback();
  }

  ///Lädt die besonderen Aktivitäten aus der Datenbank und ordnet sie in einer Liste mit Maps ein
  //Könnte in eigene Klasse gesteckt werden und zum Beispiel auch auf Tages/Wochenansicht filterbar gemacht werden
  Future<void> loadActivities(int selectedIndex, int timeButtonIndex) async { //
    final Database db = await DatabaseHelper().database;
    if(selectedIndex > 1) selectedIndex += 3;
    String query = "goodQuestion = ? OR calmQuestion = ? OR helpQuestion = ?";
    switch(timeButtonIndex){
      case 0:
        query = "(goodQuestion = ? OR calmQuestion = ? OR helpQuestion = ?) AND (datetime(timeBegin) > datetime(current_timestamp, '-7 days'))";
        break;
      case 1:
        query = "(goodQuestion = ? OR calmQuestion = ? OR helpQuestion = ?) AND (datetime(timeBegin) > datetime(current_timestamp, '-31 days'))";
        break;
      default:
        break;
    }
    // Kategorien initialisieren und clearen
      _activities = {
        "good": [],
        "calm": [],
        "help": [],
      };
    final List<Map<String, dynamic>> specialTasks = await db.query(
      "Termine",
      where: query,
      whereArgs: [selectedIndex, selectedIndex, selectedIndex]
    );
    for(Map specialTask in specialTasks){
      List<String> categories = [];
      if(specialTask["goodQuestion"] == selectedIndex){
       categories.add("good");
      }
      if(specialTask["calmQuestion"] == selectedIndex){
        categories.add("calm");
      }
      if(specialTask["helpQuestion"] == selectedIndex){
          categories.add("help");
      }
      for(String category in categories){
        Map<String, String>  oneEntry = {
          "title": specialTask["terminName"],
          "date": specialTask["timeBegin"],
          "comment": specialTask["comment"],
          "doneTask": specialTask["doneQuestion"] == 2 ? "false" : "true",
          "weekKey": specialTask["weekKey"],
        };

        bool alreadySimilar = false;
        for(Map<String, String> activityMap in _activities[category]!){
          if(activityMap["title"]!.similarityTo(specialTask["terminName"]) > 0.8 ){
             alreadySimilar = true;
             activityMap["date"] = "${activityMap["date"]}|${specialTask["timeBegin"]}";
             activityMap["comment"] = "${activityMap["comment"]}|${specialTask["comment"]}";
             activityMap["weekKey"] = "${activityMap["weekKey"]}|${specialTask["weekKey"]}";
             activityMap["doneTask"] = "${activityMap["doneTask"]}|${specialTask["doneQuestion"] == 2 ? "false" : "true"}";
          }
        }
        if(!alreadySimilar){
          setState(() {
            _activities[category]?.add(oneEntry);
          });
        }
      }
    }
    setState(() {
      _loaded = true;
      _circleLoading = false;
      _adjectives = Utilities().getActivityAdjective(selectedIndex);
    });
  }

  Future<void> onFilterButtonPressed(int index) async {
    setState(() {
      _selectedButtonIndex = index;
      loadActivities(_selectedButtonIndex, _selectedTimeButtonIndex);
      _circleLoading = true;
    });
  }

  Future<void> onFilterTimeButtonPressed(int index) async {
    setState(() {
      _selectedTimeButtonIndex = index;
      loadActivities(_selectedButtonIndex, _selectedTimeButtonIndex);
      _circleLoading = true;
    });
  }

  ///Erstellt ein Widget für eine der drei Kategorien der Besondere Aktivitäten
  //Hat teils beim testen nicht richtig geupdated
  Widget buildSingleCategory(String title, List<Map<String,String>> activities) {
    return Padding(
          padding: EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 5),
                  child:Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).listTileTheme.tileColor?.withAlpha(80),
                ),
                child: Column(
                  children: [
                    Column(
                      children: List.generate(activities.length, (index) {
                        final map = activities[index];
                        return  Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent //Theme.of(context).listTileTheme.tileColor?.withAlpha(70),
                          ),
                          child: InfoListTile(
                              key: ValueKey("${map["title"]}${map["date"]}${map["comment"]}"), //Dieses Value hat mich 1 Stunde gekostet....
                              map: map),
                        );
                      }),
                    ),
                    if (activities.isEmpty) Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: ListTile(
                        title: _circleLoading ? CircularProgressIndicator() : Text(S.of(context).summary_no_entries, style: TextStyle(fontSize: 16)),
                        leading: Icon(Icons.radio_button_unchecked, color: Colors.green),
                        tileColor: Colors.transparent,
                      ),
                    ),
                  ],
                )
              ),
              ),
              SizedBox(height: 16),
            ],
          )
      );
  }


  @override
  Widget build(BuildContext context) {
    return ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                stops: [0.0, 0.07, 0.9, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(child:
                Padding(
                  padding: EdgeInsets.only(left: 16,right: 16,bottom: 15),
                  child: Column(
                    children: [
                      ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.width * 0.9,
                            minHeight: 10,
                          ),
                          child:  ScrollableWeekGraph()
                      ),
                      SizedBox(height: 15),
                      AutoSizeText(
                          S.current.special_activities,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)
                      ),
                      ///Unischer ob folgende Filtermethode so sinnvol sind, oder nur auf positives beschränkt sein sollte
                      SizedBox(height: 10),
                      Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).listTileTheme.tileColor?.withAlpha(50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).buttonTheme.colorScheme?.primary.withAlpha(70) as Color, width: 1)
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                child: Container(
                                  color: Colors.transparent,
                                  width: double.infinity,
                                  child: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Row(
                                      spacing: 10,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(S.current.activity_filter),
                                        Icon(_expandFilters ? Icons.expand_less_rounded : Icons.expand_more_rounded)
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: (){
                                  setState(() {
                                    _expandFilters = _expandFilters == false ? true : false;
                                  });
                                },
                              ),
                              if(_expandFilters)...{
                                SizedBox(height: 20),
                                AutoSizeText(S.current.activity_filter_desc1 ,textAlign: TextAlign.center, maxLines: 1, minFontSize: 16,),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(3, (index) {
                                      bool isSelected = _selectedTimeButtonIndex == index;
                                      return SizedBox(
                                        width: _selectedTimeButtonIndex == index ? MediaQuery.of(context).size.width*0.27 : MediaQuery.of(context).size.width*0.23,
                                        height: 45,
                                        child: TextButton(
                                          onPressed: () {
                                            if(_hapticFeedback) HapticFeedback.lightImpact();
                                            onFilterTimeButtonPressed(index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(13)
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: isSelected ? 15 : 5),
                                            backgroundColor: isSelected ? Theme.of(context).appBarTheme.backgroundColor?.withAlpha(120) : Theme.of(context).listTileTheme.tileColor?.withAlpha(120), // Farbänderung
                                          ),
                                          child: FittedBox(
                                              child: Padding(padding: EdgeInsets.all(1),
                                                  child: Text(S.current.buttonTimeDisplay(index), textAlign: TextAlign.center,style: Theme.of(context).brightness == Brightness.light ? TextStyle(color: Colors.black87): TextStyle())
                                              )
                                          ), //Utilities().getActivityAdjective(index) style: TextStyle(fontWeight: selectedButtonIndex == index ? FontWeight.bold : FontWeight.normal)
                                        ),
                                      ) ;
                                    }),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    spacing: 5,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(4, (index) {
                                      bool isSelected = _selectedButtonIndex == index;
                                      return SizedBox(
                                        width: _selectedButtonIndex == index ? MediaQuery.of(context).size.width*0.23 : MediaQuery.of(context).size.width*0.19,
                                        height: 45,
                                        child: TextButton(
                                          onPressed: () {
                                            if(_hapticFeedback) HapticFeedback.lightImpact();
                                            onFilterButtonPressed(index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(13)
                                            ), 
                                            padding: EdgeInsets.symmetric(horizontal: isSelected ? 15 : 5),
                                            backgroundColor: isSelected ? Theme.of(context).appBarTheme.backgroundColor?.withAlpha(120) : Theme.of(context).listTileTheme.tileColor?.withAlpha(120), // Farbänderung
                                          ),
                                          child: FittedBox(
                                              child: Padding(padding: EdgeInsets.all(1),
                                                  child:   Text(S.current.buttonDisplay(index), textAlign: TextAlign.center, style: Theme.of(context).brightness == Brightness.light ? TextStyle(color: Colors.black87): TextStyle())
                                              )
                                          ), //Utilities().getActivityAdjective(index) style: TextStyle(fontWeight: selectedButtonIndex == index ? FontWeight.bold : FontWeight.normal)
                                        ),
                                      ) ;
                                    }),
                                  ),
                                ),
                                AutoSizeText(S.current.activity_filter_desc2 ,textAlign: TextAlign.center, minFontSize: 16, maxLines: 1,),
                                SizedBox(height: 16),
                              },

                            ],
                          )
                      ),
                      SizedBox(height: 20),
                      _loaded ? Column(
                        children: [
                          buildSingleCategory(S.current.good_activities_desc_variable(_adjectives[0]) , _activities["good"]!),
                          buildSingleCategory(S.current.calm_activities_desc_variable(_adjectives[1]) , _activities["calm"]!),
                          buildSingleCategory(S.current.help_activities_desc_variable(_adjectives[2]) , _activities["help"]!),],
                      ) : CircularProgressIndicator(),
                      SizedBox(height: 15)
                    ],
                  )
                ),
          ),
        );

  }
}

///Custom ListTile um sie erweiterbar für zusätzliche Informationen zu machen
class InfoListTile extends StatefulWidget {
  final Map<String, String> map;
  const InfoListTile({super.key, required this.map});

  @override
  InfoListTileState createState() => InfoListTileState();
}

class InfoListTileState extends State<InfoListTile> {
  bool showInfo = false;
  List<Map<String, String>> datesAndComments = [];
  bool hapticFeedback = false;

  @override
  void initState() {
    List<String> dates = widget.map["date"]!.split("|");
    List<String> comments = widget.map["comment"]!.split("|");
    List<String> weekKeys = widget.map["weekKey"]!.split("|");
    List<String> doneTasks = widget.map["doneTask"]!.split("|");
    for(int i = 0; i < dates.length; i++){
      DateTime dateTime = DateTime.parse(dates[i]);
      String date = "${S.current.displayADateWithYear(dateTime)} ${S.current.um} ${S.current.displayATime(dateTime)}";
      Map<String,String> singleActivity = {
        "date": date,
        "comment": comments[i],
        "weekKey": weekKeys[i],
        "doneTask": doneTasks[i],
        "timeInHours": dateTime.toIso8601String(),
      };
      datesAndComments.add(singleActivity);
    }
    super.initState();
  }

  void loadTheme() async{
    hapticFeedback = await SettingsPageState().getHapticFeedback();
    setState(() {
      hapticFeedback;
    });
  }

  Future<void> openWeekView(String weekKey, DateTime scrollTo) async {
    await navigatorKey.currentState?.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => WeekPlanView(
              weekKey: weekKey, scrollToSpecificDayAndHour: scrollTo,),
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
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: showInfo ? BorderRadius.only(topLeft: Radius.circular(14),topRight: Radius.circular(14)) : BorderRadius.circular(14), //Damit die Buttonanimation besser passt
            ),
              tileColor: Colors.transparent,
              title: Text(widget.map["title"]!),
              leading: Icon(
                Icons.push_pin_outlined,
                size: 22,
                color: Colors.green,
              ),
              trailing: Icon(showInfo ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: Theme.of(context).appBarTheme.backgroundColor,),
              onTap: ()  {
                if(hapticFeedback) HapticFeedback.lightImpact();
                setState(() {
                  showInfo = !showInfo;
                });
              },
          ),
          if(showInfo) Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            child: FittedBox(
              alignment: Alignment.topCenter,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for(Map<String,String> map in datesAndComments)...{
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 20,
                                  children: [
                                    Text("${S.current.am} ${map["date"]}", style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                                    Icon(Icons.check, size: 16, color: map["doneTask"] == "true" ? Colors.lightGreen :  Colors.orangeAccent),
                                    Container(color: Colors.transparent, width: 15,),
                                    IconButton(
                                        onPressed: () {
                                          openWeekView(map["weekKey"]!,DateTime.parse(map["timeInHours"]!)); //Eventuell lieber zur Feedbackseite
                                        },
                                        icon: Icon(Icons.shortcut, color: Theme.of(context).appBarTheme.backgroundColor)
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 3),
                              if(map["comment"]!.isNotEmpty) Container(
                                padding: EdgeInsets.only(left: 1),
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(S.current.comment, style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                    Text(map["comment"]!, style: TextStyle(fontSize: 13, color: Colors.grey), textAlign: TextAlign.left, overflow: TextOverflow.clip, softWrap: true,),
                                  ],
                                ),
                              )
                            ],
                          ),
                      SizedBox(height: 12,)
                    },
                  ]
              ),
            ),
          ),
        ],
      );
  }
}