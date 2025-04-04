import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/create_dummy_json_for_testing.dart';
import 'package:menta_track/generated/l10n.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

///Klasse für alle möglichen nützlichen funktionen, die Appübergreifend genutzt werden können aber keine eigene Klasse rechtfertigen

class Utilities{

  Utilities();

  ///Erzeugt einen Wochen-Range-String von einem weekKey
  String convertWeekKeyToDisplayPeriodString(String weekKey){
    //DateFormat normFormat = DateFormat("dd.MM.yy");
    DateTime displayDate = DateFormat("yyyy-MM-dd").parse(weekKey);
    DateTime endOfWeekDate= displayDate.add(Duration(days: 6));
    String displayPeriodString = "${S.current.displayADateWithYear(displayDate)} ${S.current.till} ${S.current.displayADateWithYear(endOfWeekDate)}";

    return displayPeriodString;
  }

  ///Checkt ob ein DateTime-String im originalen oder formatierten Zustand ist
  String checkDateFormat(String weekDayKey){
    DateTime checkFormatDate;
    try{
      checkFormatDate = DateFormat("dd.MM.yy").parse(weekDayKey);
    } catch(e){
      checkFormatDate = DateTime.parse(weekDayKey);
    }
    String checkedFormatDateString = DateFormat("yyyy-MM-dd").format(checkFormatDate);
    return checkedFormatDateString;
  }

  ///Wandelt dateTime.weekDay in einen String um
  String getWeekdayName(DateTime dateTime) {
    List<String> weekdays = [
      S.current.monday,
      S.current.tuesday,
      S.current.wednesday,
      S.current.thursday,
      S.current.friday,
      S.current.saturday,
      S.current.sunday
    ];
    return weekdays[dateTime.weekday - 1]; //-1 weil index bei 0 beginnt aber weekday bei 1 beginnt
  }

  ///Zeigt den Dialog zum abermaligen bestätigen einer Löschung
  Future<bool?> showDeleteDialog(String title, bool weekPlan, BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.current.delete),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                weekPlan ? Text(S.current.delete_week_plan, textAlign: TextAlign.center,) : Text(S.current.delete_Termin, textAlign: TextAlign.center,),
                Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
                Text(S.current.delete_week_plan2, textAlign: TextAlign.center),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(S.current.delete,style: TextStyle(color: Colors.redAccent),),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text(S.current.back),
              onPressed: () {
                Navigator.of(context).pop(false);
              },),
          ],
        );
      },
    );
  }


  Future<void> checkAndShowFirstHelpDialog(BuildContext context, String whichSite) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> seenPages = prefs.getStringList("seenPages") ?? [];

    if (!seenPages.contains(whichSite)) {
      if(context.mounted) showHelpDialog(context, whichSite);
      seenPages.add(whichSite);
      await prefs.setStringList("seenPages", seenPages);
    }
  }


  ///Zeigt das HilfeFenster
  //Die Texte sind etwas seltsam aufgebaut, hat so vom Style und den Möglichkeiten aber am besten gepasst
  void showHelpDialog(BuildContext context, String whichSite, [String? name]) {
    TextSpan mainText;
    final localizations = S.of(context);

    switch (whichSite) {
      case "MainPage":
        mainText = TextSpan(children: [
          WidgetSpan(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(localizations.mainPageDescription, textAlign: TextAlign.center),
                    Text(localizations.mainPageInstructions, textAlign: TextAlign.center),
                    Text(localizations.mainPageQrScanner, textAlign: TextAlign.center),
                    Text(localizations.mainPageTapOnPlan, textAlign: TextAlign.center),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.event_available, size: 30, color: Colors.green,),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            S.current.iconHelp1,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.left,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.free_cancellation, size: 30, color: Theme.of(context).iconTheme.color),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            S.current.iconHelp2,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.left,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.today, size: 30),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            S.current.iconHelp3,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.left,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.lock_clock, size: 30, color: Theme.of(context).iconTheme.color,),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            S.current.iconHelp4,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.left,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(localizations.mainPageDeleteWeek, textAlign: TextAlign.center),
                    Text(localizations.mainPageSwipeOrButton, textAlign: TextAlign.center)
                  ],
                ),
              )
          )
        ]);
        break;
      case "Offen":
        mainText = TextSpan(
            children: [
              TextSpan(text: "${localizations.unansweredActivities}\n"),
            ],
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color));
        break;
      case "WeekPlanView":
        mainText = TextSpan(
            children: [
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(localizations.weekPlanDescription, textAlign: TextAlign.center),
                      Text(localizations.weekPlanInstructions, textAlign: TextAlign.center),
                      Text("\n${localizations.weekPlanGrayActivities}"),
                      Text(localizations.weekPlanGreenActivities),
                      Text("${localizations.weekPlanActivitiesWithExclamation}\n"),
                      Text(localizations.weekPlanTapForDayView, textAlign: TextAlign.center),
                      Text(localizations.weekPlanTapForWeekView, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ],
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color));
        break;
      case "ActivitySummary":
        mainText = TextSpan(
            children: [
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(localizations.activitySummaryDescription, textAlign: TextAlign.center),
                      Text(localizations.activitySummaryGraphDescription, textAlign: TextAlign.center),
                      Text(localizations.activitySummaryGoodFeedback, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ],
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color));
        break;
      case "MainPageFirst":
        mainText = TextSpan(
            children: [
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(S.current.firstStartUp_Message1, textAlign: TextAlign.center),
                      Text(S.current.firstStartUp_Message2, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ],
          style: TextStyle(fontSize: 10)
        );
        break;
      case "QuestionPage":
        mainText = TextSpan(
            children: [
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(S.current.questionPageHelpDialog1, textAlign: TextAlign.center),
                      Text(S.current.questionPageHelpDialog2(name ?? ""), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
                      Text(S.current.questionPageHelpDialog3, textAlign: TextAlign.center),
                      Text(S.current.questionPageHelpDialog4, textAlign: TextAlign.center),
                      Text("\n${S.current.questionPageHelpDialog5}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
              ),
            ],
            style: TextStyle(fontSize: 10),
        );
        break;
      case "Settings":
        mainText = TextSpan(
          children: [
            WidgetSpan(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(S.current.settingsText1, textAlign: TextAlign.center),
                    Text(S.current.settingsText2, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
                    Text(S.current.settingsText3, textAlign: TextAlign.center),
                    Text(S.current.settingsText4, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
          style: TextStyle(fontSize: 10),
        );
        break;
      case "DayOverView":
        mainText = TextSpan(
          children: [
            WidgetSpan(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(S.current.dayOverViewText1, textAlign: TextAlign.center),
                    Text(S.current.dayOverViewText2, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
                    Text(S.current.dayOverViewText3, textAlign: TextAlign.center),
                    Text(S.current.dayOverViewText4, textAlign: TextAlign.center),
                    Text(S.current.dayOverViewText5, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
          style: TextStyle(fontSize: 10),
        );
        break;
      case "WeekOverView":
        mainText = TextSpan(
          children: [
            WidgetSpan(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(S.current.weekOverViewText1, textAlign: TextAlign.center),
                    Text(S.current.weekOverViewText2, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
                    Text(S.current.weekOverViewText3, textAlign: TextAlign.center),
                    Text(S.current.weekOverViewText4, textAlign: TextAlign.center),
                    Text(S.current.weekOverViewText5, textAlign: TextAlign.center),
                    Text(S.current.weekOverViewText6, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
          style: TextStyle(fontSize: 10),
        );
        break;
      case "DayPage":
        mainText = TextSpan(
          children: [
            WidgetSpan(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Text(S.current.todayHelpMessage1, textAlign: TextAlign.center),
                    Text(S.current.todayHelpMessage2, textAlign: TextAlign.center)
                  ],
                ),
              ),
            ),
          ],
          style: TextStyle(fontSize: 10),
        );
        break;
      default:
        mainText = TextSpan(children: [
          WidgetSpan(child: Text(localizations.generalHelp))
        ] );
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext bc) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(localizations.help, style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 16),
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
                          stops: [0.0, 0.03, 0.9, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: RichText(
                              text: mainText,
                              textAlign: TextAlign.center,
                            ),
                        )
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context, "confirmed");
                      },
                      child: const Text("OK"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ///Manuelle Funktion, da die .arb datei diesen Syntax nicht checkt und die einzelenen wörter für Variabeln hält
  ///  "activity_adjective": "{count, plural, =0{garnicht} =1{weniger} =2{eher weniger} =3{neutral} =4{eher gut} =5{gut} =6{besonders gut} other{unbekannt}}",
  List<String> getActivityAdjective(int index){
    switch(index){
      case 0:
        return [
          S.current.activity_good_adjective1,
          S.current.activity_calm_adjective1,
          S.current.activity_help_adjective1,
        ];
      case 1:
        return [
          S.current.activity_good_adjective2,
          S.current.activity_calm_adjective2,
          S.current.activity_help_adjective2
        ];
      case 5:
        return [
          S.current.activity_good_adjective3,
          S.current.activity_calm_adjective3,
          S.current.activity_help_adjective3
        ];
      case 6:
        return [
          S.current.activity_good_adjective4,
          S.current.activity_calm_adjective4,
          S.current.activity_help_adjective4
        ];
      default:
        return ["","",""];
    }
  }


  /// Funktion, die den QR-Code in einem Dialog anzeigt
  void showQrCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("QR Code"),
          content:  SizedBox(
            width: 400,
                  height: 400,
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: QrImageView(
                      backgroundColor: Colors.white,
                      version: QrVersions.auto,
                      data: CreateDummyJsonForTesting().toCompressedStudyList(),
                    ),
                  ),
                ),
          actions: [
            TextButton(
              child: Text(S.current.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String getRandomisedEncouragement(bool fromNotification, String name){
    List<String> strings = [];

    final local = S.current;

      strings = name == "" ? [
        local.helper_activities0,
        local.helper_activities1,
        local.helper_activities2,
        local.helper_activities3,
        local.helper_activities4,
        local.helper_activities5,
        local.helper_activities6,
        local.helper_activities7,
        local.helper_activities8,
        local.helper_activities9,
        local.helper_activities10,
        local.helper_activities11,
      ] : [
        local.helper_activities0_name(name),
        local.helper_activities1_name(name),
        local.helper_activities2_name(name),
        local.helper_activities3_name(name),
        local.helper_activities4_name(name),
        local.helper_activities5_name(name),
        local.helper_activities6_name(name),
        local.helper_activities7_name(name),
        local.helper_activities8_name(name),
        local.helper_activities9_name(name),
        local.helper_activities10_name(name),
        local.helper_activities11_name(name),
      ];

    return strings[Random().nextInt(strings.length)];
  }

  Widget getHelpBurgerMenu(BuildContext context, String pageKey){
    return Padding(
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
              onPressed: () => Utilities().showHelpDialog(context, pageKey),
            ),
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
              child: Icon(Icons.menu, size: 30, color: Theme.of(context).appBarTheme.foregroundColor,),
            );
          }
      ),
    );
  }

  Widget favoriteItems(int i, List<String> favoriteAnswers, BuildContext context) {
    List<String> favoriteComments = [
      S.of(context).favorite_comments0,
      S.of(context).favorite_comments1,
      S.of(context).favorite_comments2
    ];

    if(favoriteAnswers.isNotEmpty){
      if(favoriteAnswers[i] != ""){
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              child: Text(favoriteComments[i],textAlign: TextAlign.start, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            ),
            Padding(
                padding: EdgeInsets.only(left: 20,bottom: 10,top: 10),
                child: Text(favoriteAnswers[i],style: TextStyle(fontSize: 15),textAlign: TextAlign.start,)
            )
          ],
        );
      }
    }
    return SizedBox(height: 0,);
  }
}