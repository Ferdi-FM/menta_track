import 'package:intl/intl.dart';

//Klasse für alle möglichen nützlichen funktionen, die Appübergreifend genutzt werden können

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

}