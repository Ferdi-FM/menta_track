import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/create_dummy_json_for_testing.dart';
import 'package:menta_track/generated/l10n.dart';
import 'package:qr_flutter/qr_flutter.dart';

//Klasse für alle möglichen nützlichen funktionen, die Appübergreifend genutzt werden können aber keine eigene Klasse rechtfertigen

class Utilities{

  Utilities();

  //standard DateTime-Format ist (yyyy-MM-dd), deshalb wird hier übergangsweise der DisplayName zu dem in der Datenbank verwendeten key umformatiert
  String convertDisplayDateStringToWeekkey(String displayString){
    DateFormat format = DateFormat("dd.MM.yyyy");
    DateTime displayDateString = format.parse(displayString.substring(0,10));
    String correctedDate = DateFormat("yyyy-MM-dd").format(displayDateString);

    return correctedDate;
  }

  //und anders herum
  String convertWeekkeyToDisplayDateString(String weekKey){
    DateFormat format = DateFormat("yyyy-MM-dd");
    DateTime displayDateString = format.parse(weekKey);
    String correctedDate = DateFormat("dd.MM.yyyy").format(displayDateString);

    return correctedDate;
  }

  String convertWeekkeyToDisplayPeriodString(String weekKey){
    //DateFormat normFormat = DateFormat("dd.MM.yy");
    DateTime displayDate = DateFormat("yyyy-MM-dd").parse(weekKey);
    DateTime endOfWeekDate= displayDate.add(Duration(days: 6));
    String displayPeriodString = "${S.current.displayADateWithYear(displayDate)} ${S.current.till} ${S.current.displayADateWithYear(endOfWeekDate)}";

    return displayPeriodString;
  }

  String checkDateFormat(String weekDayKey){
    print("VOR dem Check: $weekDayKey");
    DateTime checkFormatDate;
    try{
      checkFormatDate = DateFormat("dd.MM.yy").parse(weekDayKey);
    } catch(e){
      checkFormatDate = DateTime.parse(weekDayKey);
    }
    String checkedFormatDateString = DateFormat("yyyy-MM-dd").format(checkFormatDate);
    print("NACH dem Check: $checkedFormatDateString");

    return checkedFormatDateString;
  }


  //Zeigt das HilfeFenster, wollte nicht extra eine neue Klasse für sowas simples anlegen, wird aber wrsch. noch gemacht
  void showHelpDialog(BuildContext context, String whichSite) {
    TextSpan mainText;

    final localizations = S.of(context);

    switch (whichSite) {
      case "MainPage":
        mainText = TextSpan(children: [
          TextSpan(text: "${localizations.mainPageDescription}\n"),
          TextSpan(text: "${localizations.mainPageInstructions}\n"),
          TextSpan(text: localizations.mainPageQrScanner),
          TextSpan(text: "\n${localizations.mainPageTapOnPlan}"),
          TextSpan(text: localizations.mainPageDeleteWeek),
          TextSpan(text: localizations.mainPageSwipeOrButton)
        ], style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color));
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
                      Text(localizations.weekPlanGrayActivities),
                      Text(localizations.weekPlanGreenActivities),
                      Text(localizations.weekPlanActivitiesWithExclamation),
                      Text(localizations.weekPlanTapForDayView),
                      Text(localizations.weekPlanTapForWeekView),
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
                      Text(localizations.activitySummaryGoodFeedback),
                    ],
                  ),
                ),
              ),
            ],
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color));
        break;
      default:
        mainText = TextSpan(text: localizations.generalHelp);
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
                    child: SingleChildScrollView(
                      child: RichText(
                        text: mainText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
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


  // Funktion, die den QR-Code in einem Dialog anzeigt
  void showQrCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("QR Code"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                backgroundColor: Colors.white,
                version: QrVersions.auto,
                data: CreateDummyJsonForTesting().toCompressedIntListTwoTermine(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Schließen"),
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

    /*else { TODO:Neutralere aussagen
      strings = name == "" ? [
        "Super 🎉",
        "Toll 🌟",
        "Großartig 🔥",
        "Richtig gut 🏅",
        "Weiter so! 🚀",
        "Du verdienst Glück! 🥇",
        "Toll, wie du dich anstrengst! 🎯",
        "Jeder Tag ein weiterer Schritt! 🚶‍♀️",
        "Wirklich stark! 💪",
        "Du bist auf dem richtigen Weg! 🌟",
        "Großartige Arbeit 🌟"
      ] : [
        "Super $name🎉",
        "Toll $name🌟",
        "Großartig $name🔥",
        "Richtig gut $name🏅",
        "Weiter so $name🚀",
        "Du verdienst Glück $name🥇",
        "Toll, dass du dich anstrengst $name🎯",
        "Jeder Tag ein weiterer Schritt🚶",
        "Wirklich stark $name💪",
        "Du bist auf dem richtigen Weg $name🌟",
        "Großartige Arbeit $name🌟"
      ];
    }*/


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
            if(pageKey == "weekPlanView") MenuItemButton( //Könnte zum manuellen hinzufügen dienen
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.help_rounded),
                    SizedBox(width: 10),
                    Text("Eintrag hinzufügen") //TODO Evtl
                  ],
                ),
              ),
            )
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