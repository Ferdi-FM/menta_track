import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//Klasse für alle möglichen nützlichen funktionen, die Appübergreifend genutzt werden können aber keine eigene Klasse rechtfertigen

class Utilities{

  Utilities();

  //standard DateTime-Format ist (yyyy-MM-dd), deshalb wird hier übergangsweise der DisplayName zu dem in der Datenbank verwendeten key umformatiert
  String convertDisplayDateStringToWeekkey(String displayString){
    DateFormat format = DateFormat("dd-MM-yyyy");
    DateTime displayDateString = format.parse(displayString.substring(0,10));
    String correctedDate = DateFormat("yyyy-MM-dd").format(displayDateString);

    return correctedDate;
  }

  //und anders herum
  String convertWeekkeyToDisplayDateString(String weekKey){
    DateFormat format = DateFormat("yyyy-MM-dd");
    DateTime displayDateString = format.parse(weekKey);
    String correctedDate = DateFormat("dd-MM-yyyy").format(displayDateString);

    return correctedDate;
  }

  String convertWeekkeyToDisplayPeriodString(String weekKey){
    DateFormat normFormat = DateFormat("dd.MM.yy");
    DateTime displayDate = DateFormat("yyyy-MM-dd").parse(weekKey);
    DateTime endOfWeekDate= displayDate.add(Duration(days: 6));
    String displayPeriodString = "${normFormat.format(displayDate)}  bis  ${normFormat.format(endOfWeekDate)}";

    return displayPeriodString;
  }


  //Zeigt das HilfeFenster, wollte nicht extra eine neue Klasse für sowas simples anlegen
  void showHelpDialog(BuildContext context,String whichSite){
    TextSpan mainText;

    switch (whichSite) {
      case "MainPage":
        mainText = TextSpan(children: [
          TextSpan(text: "Das ist die Startseite\n"),
          TextSpan(text: "Hier findest du alle gespeicherten Wochenpläne"),
        ],
        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color));
        break;
      case "Offen":
        mainText = TextSpan(
            children: [
              TextSpan(text: "\n"),
              TextSpan(text: ""),
            ],
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color));
        break;
      default:
        mainText = TextSpan(text: "Allgemeine Hilfe.");
        break;
    }

    print(mainText.children);

    showDialog(
        context: context,
        builder: (BuildContext bc){
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Hilfe", style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 16),
                    RichText(text: mainText, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.center,
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

}