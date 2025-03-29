// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/notification_helper.dart';
import 'package:menta_track/termin.dart';
import 'package:menta_track/week_tile_data.dart';

///Klasse zum importieren von Json-Terminen vom QR-Code

class ImportJson {
  DatabaseHelper databaseHelper = DatabaseHelper();

  ///Nimmt data vom QR-Scanner -> dekomremiert sie -> wandelt sie in eine Liste mit WeekTileData um und speichert in der Datenbank
  Future<List<WeekTileData>> loadDummyDataForQr(String data) async {
      List<dynamic> decodedData = jsonDecode(decompressData(data));
      final terminMapQR = await getWeekMaps(decodedData);
      return await createWeekPlanMapFromJson(terminMapQR);
  }

  ///Dekompremiert die vom QR-Code gescannten String
  String decompressData(String base64Data) {
    //Decode von Base64 String in List<int>
    List<int> compressedData = base64Decode(base64Data);
    //GZip-Dekomression mit GZipCodec();
    var codec = GZipCodec();
    List<int> decompressedData = codec.decode(compressedData);
    //List<int> zu String
    String utf8DecodedIntList = utf8.decode(decompressedData);
    return utf8DecodedIntList;
  }

  ///Checkt den Anfänglichen firstWeekDay ob er sich mit schon existierenden Überschneidet
  Future<DateTime> checkWeekKeyRange(DateTime firstWeekDay) async {
    String firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstWeekDay);      //Um es auf 0:00 am ersten Tag zu setzen

    final db = await databaseHelper.database;
    //Checkt ob der neue Termin weniger als eine Woche von einem bereits enthaltenen WeekKey statt findet und setzt dann den weekKey auf die Woche davor, sodass der erste Wochentag beibehalten wird
    String query = '''
      SELECT weekKey FROM WeeklyPlans 
      WHERE date(weekKey) BETWEEN date(?, '-7 days') AND date(?, '+6 days')
      LIMIT 1;
    ''';

    List<Map<String, dynamic>> result = await db.rawQuery(query, [firstWeekDayString, firstWeekDayString]);

    ///Wenn der neue WeekKey in eine Bereits erkannte Zeitspanne fallen würde, wird errechnet, ob er sie einschneiden würde (isNegative) => Dann wird der weekKey auf die Woche davor gesetzt, ansonsten wird der weekKey auf die schon existente Woche gelegt
    if (result.isNotEmpty) {
      if(DateTime.parse(result.first["weekKey"]).difference(firstWeekDay).isNegative){
        firstWeekDay = DateTime.parse(result.first["weekKey"]);
      } else {
        firstWeekDay = DateTime.parse(result.first["weekKey"]).subtract(Duration(days: 7));
      }
    }
    return firstWeekDay;
  }

  //Der Gesamte import kann vereinfacht werden, sobald die App zur Wochenplanerstellung geschrieben wurde, gerade muss noch jeder Fall beachtet werden
  ///Checkt während dem durchiterieren nach Überschneidungen, da "-7days" zur unendlichen Schleife führen würde
  Future<DateTime> checkWeekKeyRangeInLoop(DateTime firstWeekDay) async {
    String firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstWeekDay);
    final db = await databaseHelper.database;
    String query = '''
      SELECT weekKey FROM WeeklyPlans 
      WHERE date(weekKey) BETWEEN date(?, '-7 days') AND date(?, '+6 days')
      LIMIT 1;
    ''';
    List<Map<String, dynamic>> result = await db.rawQuery(query, [firstWeekDayString, firstWeekDayString]);
    ///Wenn der neue WeekKey in eine Bereits erkannte Zeitspanne fallen würde, wird errechnet, ob er sie einschneiden würde (isNegative) => Dann wird der weekKey auf die Woche davor gesetzt, ansonsten wird der weekKey auf die schon existente Woche gelegt
    if (result.isNotEmpty) {
      if(DateTime.parse(result.first["weekKey"]).difference(firstWeekDay).isNegative){
        firstWeekDay = DateTime.parse(result.first["weekKey"]).add(Duration(days: 1));
      } else {
        firstWeekDay = DateTime.parse(result.first["weekKey"]).add(Duration(days: 6));
      }
    }
    return firstWeekDay;
  }

  ///Checkt während dem durchiterieren nach Überschneidungen, da "-7days" zur unendlichen Schleife führen würde
  Future<DateTime> checkWeekKeyRangeVariable(DateTime firstWeekDay, bool inLoop, Map<String, dynamic> newTerminMap) async {
    String firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstWeekDay);
    print(firstWeekDay);
    final db = await databaseHelper.database;
    String query = '''
      SELECT weekKey FROM WeeklyPlans 
      WHERE date(weekKey) BETWEEN date(?, '-7 days') AND date(?, '+6 days')
      LIMIT 1;
    ''';
    List<Map<String, dynamic>> result = await db.rawQuery(query, [firstWeekDayString, firstWeekDayString]);
    ///Wenn der neue WeekKey in eine Bereits erkannte Zeitspanne fallen würde, wird errechnet, ob er sie einschneiden würde (isNegative) => Dann wird der weekKey auf die Woche davor gesetzt, ansonsten wird der weekKey auf die schon existente Woche gelegt
    if (result.isNotEmpty) {
      if(DateTime.parse(result.first["weekKey"]).difference(firstWeekDay).inDays == 0) {
        firstWeekDay = DateTime.parse(result.first["weekKey"]);
      } else if(DateTime.parse(result.first["weekKey"]).difference(firstWeekDay).isNegative){
        firstWeekDay = inLoop ? DateTime.parse(result.first["weekKey"]).add(Duration(days: 7)) : DateTime.parse(result.first["weekKey"]);
      } else {
        firstWeekDay = inLoop ? DateTime.parse(result.first["weekKey"]).add(Duration(days: 6)) : DateTime.parse(result.first["weekKey"]).subtract(Duration(days: 7));
      }
    }
    ///Es müssen 7 Tage zwischen den starttagen liegen, sodass zur not noch die Woche eingefügt werden kann!
    ///Falls es wie ursprünglich gehandelt werden soll, können "checkWeekKeyRange" & "checkWeekKeyRangeInLoop" wieder verwendet werden.
    ///Dann muss jedoch Sichergestellt werden, dass in den Importierten Plänen keine Lücke, die länger als 7Tage ist, ist!!!
    else if (inLoop){
      String testDate2 = DateFormat("yyyy-MM-dd").format(firstWeekDay.subtract(Duration(days: 7)));
      String query = '''
      SELECT weekKey FROM WeeklyPlans 
      WHERE date(weekKey) BETWEEN date(?, '-7 days') AND date(?)
      LIMIT 1;
    ''';
      List<Map<String, dynamic>> result = await db.rawQuery(query, [testDate2, testDate2]);
      if (result.isNotEmpty && !newTerminMap.containsKey(result.first["weekKey"])) {
        firstWeekDay = DateTime.parse(result.first["weekKey"]).add(Duration(days: 6));
      }
    }
    return firstWeekDay;
  }

  ///Iteriert durch alle Losen Termine und ordnet diese in eine Map nach dem Schema {startwoche : [Liste an einzelnen Termin-Maps], startwoche+7*n : [Liste an einzelnen Termin-Maps]} zum Beispiel =>
  //{2025-01-20: [{TerminName: Arztbesuch, TerminBeginn: 2025-01-20 09:00:00, TerminEnde: 2025-01-20 10:00:00}],
  // 2025-01-27: [{TerminName: Hunde gassi, TerminBeginn: 2025-01-27 09:00:00, TerminEnde: 2025-01-27 10:00:00}]}
  ///Entschuldigung im vorraus, das ist ein richtiger Hirnzwirbler
  Future<Map<String, dynamic>> getWeekMaps(List<dynamic> terminMap) async {
    Map<String, dynamic> newTerminMap = {};
    DateTime firstWeekDay = DateTime.parse(terminMap[0]["tB"]);                             //Tag des ersten Termins
    String firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstWeekDay);              //formatieren in String für die Map

    firstWeekDay = DateTime.parse(firstWeekDayString);                                      //Um es auf 0:00 am ersten Tag zu setzen
    firstWeekDay = await checkWeekKeyRangeVariable(firstWeekDay,false, newTerminMap);                     //Checkt das erste mal ob es in einen schon vorhanden Plan fällt
    firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstWeekDay);                     //Wandelt die transformierte Zeit in einen String zum vergleichen um
    for(int i = 0; i < terminMap.length; i++){                                              //Iteriert durch Map
      DateTime terminTime =  DateTime.parse(terminMap[i]["tB"]);
      while(terminTime.difference(firstWeekDay).inDays > 6){                                //schaut ob die Difference zum ersten Wochentag größer als 7Tage ist, wenn true setzt er die nächste woche als neue referenz
        firstWeekDay = await checkWeekKeyRangeVariable(terminTime,true,newTerminMap);       //Checkt ob es sich in der neuen Range mit einem existierenden Plan überschneidet
        firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstWeekDay);
      }
      if(!newTerminMap.containsKey(firstWeekDayString)){//wenn die Map noch nicht den Wochenkey enthält
        newTerminMap[firstWeekDayString] = [];                                              //wird er eingefügt
      }
      if(DateTime.parse(terminMap[i]["tB"]).isBefore(DateTime.parse(terminMap[i]["tE"]))){  //Wenn der Begin vor dem Ende liegt
        newTerminMap[firstWeekDayString]?.add(terminMap[i]);                                //Dann wird der Eintrag in die nach Wochen geordnete Liste eingefügt
      }
    }
    return newTerminMap;
  }

  ///wandelt eine Map mit Terminen in eine Liste für die Startseite um und speichert sie gleichzeitig in der Datenbank
  Future<List<WeekTileData>> createWeekPlanMapFromJson(Map terminMap) async {
    List<WeekTileData> weekAppointmentList = [];
    for (int i = 0; i < terminMap.length; i++) {
      List<Termin> terminItems = [];
      String firstWeekDay = terminMap.keys.toList()[i].toString(); //nimmt den key der Map aus der Json-Datei um die Woche zu indentifizieren
      List termine = terminMap[firstWeekDay]; //Liste der übertragenen Termine für die Woche

      for (int j = 0; j < termine.length; j++) { //Convertiert die vom Therapeuten erstelle Liste in eine Liste aus Termin-Items für den Patienten
        var termin = termine[j];
        Termin t = Termin(
            weekKey: firstWeekDay,
            terminName: termin["tN"], //tM = TerminName
            timeBegin: DateTime.parse(termin["tB"]), //tB = TerminBeginn
            timeEnd: DateTime.parse(termin["tE"]), //tE = TerminEnde
            doneQuestion: -1,
            goodMean: -1,
            calmMean: -1,
            helpMean: -1,
            comment: "",
            answered: false);

        terminItems.add(t);
      }
        List<Termin> existingPlan = await databaseHelper.getWeeklyPlan(firstWeekDay); //Checkt ob es schon einen Eintrag für die Woche gibt

        //Erstellt Datenbank Eintrag
        await databaseHelper.insertWeeklyPlan(firstWeekDay, terminItems); //Fügt nur neue Einträge hinzu, unabhängig von existingPlan

        //Erstellt item für die Liste
        DateTime endOfWeek = DateTime.parse(firstWeekDay).add(Duration(days: 6));
        String startOfWeekString = DateFormat("dd.MM.yyyy").format(DateTime.parse(firstWeekDay));
        String endOfWeekString = DateFormat("dd.MM.yyyy").format(endOfWeek);
        String title1 = "$startOfWeekString - $endOfWeekString";

        WeekTileData data = WeekTileData(icon: Icon(Icons.new_releases), title: title1, weekKey: firstWeekDay, subTitle: "Aktivitäten: ${termine.length}");
        if (existingPlan.isEmpty) {
          weekAppointmentList.add(data);
          NotificationHelper().loadNewNotifications(firstWeekDay);
        }
    }
    return weekAppointmentList;
  }
}