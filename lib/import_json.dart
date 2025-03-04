import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/create_dummy_json_for_testing.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/termin.dart';
import 'package:menta_track/week_tile_data.dart';

class ImportJson {
  DatabaseHelper databaseHelper = DatabaseHelper();

    Future<List<WeekTileData>> loadDummyData(String data) async { //ALT
      CreateDummyJsonForTesting dummy = CreateDummyJsonForTesting();

      //Neue Version, die eine reine Liste nimmt
      final dummyData = dummy.getOneDummyData();
      final terminMap = await getWeekMaps(jsonDecode(dummyData) as List<dynamic>); //Old: jsonDecode(dummyData) as Map<String, dynamic>;
      return await createWeekPlanMapFromJson(terminMap);
    }

  Future<List<WeekTileData>> loadDummyDataForQr(String data) async { //Funktioniert
      List<dynamic> decodedData = jsonDecode(decompressData(data));
      final terminMapQR = await getWeekMaps(decodedData); //Old: jsonDecode(dummyData) as Map<String, dynamic>;
      return await createWeekPlanMapFromJson(terminMapQR);
  }
    
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

  //Iteriert durch alle Losen Termine und ordnet diese in eine Map nach dem Schema {startwoche : [Liste an einzelnen Termin-Maps], startwoche+n : [Liste an einzelnen Termin-Maps]} zum Beispiel =>
  //{2025-01-20: [{TerminName: Arztbesuch, TerminBeginn: 2025-01-20 09:00:00, TerminEnde: 2025-01-20 10:00:00}],
  // 2025-01-27: [{TerminName: Hunde gassi, TerminBeginn: 2025-01-27 09:00:00, TerminEnde: 2025-01-27 10:00:00}]}
  Future<Map<String, dynamic>> getWeekMaps(List<dynamic> terminMap) async {
    Map<String, dynamic> newTerminMap = {};

    DateTime firstWeekDay = DateTime.parse(terminMap[0]["TerminBeginn"]);             //Tag des ersten Termins
    String firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstWeekDay);        //formatieren in String für die Map
    firstWeekDay = DateTime.parse(firstWeekDayString);      //Um es auf 0:00 am ersten Tag zu setzen
    print(firstWeekDayString);
    final db = await databaseHelper.database;
    //Checkt ob der neue Termin weniger als eine Woche von einem bereits enthaltenen WeekKey statt findet und setzt dann den weekKey auf die Woche davor, sodass der erste Wochentag beibehalten wird
    String query = '''
      SELECT weekKey FROM WeeklyPlans 
      WHERE date(weekKey) BETWEEN date(?, '-7 days') AND date(?, '+6 days')
      LIMIT 1;
    ''';
    List<Map<String, dynamic>> result = await db.rawQuery(query, [firstWeekDayString, firstWeekDayString]);
    print(result);

    if (result.isNotEmpty) {
      firstWeekDayString = result.first["weekKey"]; // Falls eine Überschneidung existiert, nimm die vorhandene Woche
    }


    for(int i = 0; i < terminMap.length; i++){                                        //Iteriert durch Map
      DateTime terminTime =  DateTime.parse(terminMap[i]["TerminBeginn"]);
      while(terminTime.difference(firstWeekDay).inDays > 6){                             //schaut ob die Difference zum ersten Wochentag größer als 7Tage ist
        //firstWeekDay = firstWeekDay.add(Duration(days: 7));    //geht einfach weiter  // wenn true setzt er die nächste woche als neue referenz
        firstWeekDay = terminTime;
        firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstWeekDay);           // formatiert den neuen ersten Wochentag in String für die Map
      }
      if(!newTerminMap.containsKey(firstWeekDayString)){                              //wenn die Map noch nicht den Wochenkey enthält
        newTerminMap[firstWeekDayString] = [];                                        //wird er eingefügt
      }
      newTerminMap[firstWeekDayString]?.add(terminMap[i]);                            //Dann wird der Eintrag in die nach Wochen geordnete Liste eingefügt
    }
    return newTerminMap;
  }

  Future<List<WeekTileData>> createWeekPlanMapFromJson(Map terminMap) async {
    List<WeekTileData> weekAppointmentList = [];
    for (int i = 0; i < terminMap.length; i++) {
      List<Termin> terminItems = [];
      String firstWeekDay = terminMap.keys.toList()[i].toString(); //nimmt den key der Map aus der Json-Datei um die Woche zu indentifizieren
      List termine = terminMap[firstWeekDay]; //Liste der übertragenen Termine für die Woche

      for (int j = 0; j < termine.length; j++) { //Convertiert die vom Therapeuten erstelle Liste in eine Liste aus Termin-Items für den Patienten
        var termin = termine[j];
        Termin t = Termin(
            terminName: termin["TerminName"],
            timeBegin: DateTime.parse(termin["TerminBeginn"]),
            timeEnd: DateTime.parse(termin["TerminEnde"]),
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

        WeekTileData data = WeekTileData(icon: Icons.new_releases, title: title1, weekKey: firstWeekDay);
        if (existingPlan.isEmpty) weekAppointmentList.add(data);
    }
    return weekAppointmentList;
  }
}

//Alternate all in One: final terminMap =
/*/direktere, aber kompliziertere Version:
  Future<List<WeekTileData>> createWeekPlanMapFromONEJson(List<dynamic> terminMap) async {
    List<WeekTileData> weekAppointmentList = [];
    List<Termin> terminItems = [];

    DateTime firstWeekDay = DateTime.parse(terminMap[0]["TerminBeginn"]);
    String firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstWeekDay);

    for(int i = 0; i < terminMap.length; i++){
      print("ITERATION: $i");
      DateTime termiTime =  DateTime.parse(terminMap[i]["TerminBeginn"]);

      if(termiTime.difference(firstWeekDay).inDays > 6){
        List<Termin> existingPlan = await databaseHelper.getWeeklyPlan(firstWeekDayString);
        //await databaseHelper.insertWeeklyPlan(firstWeekDayString, terminItems); //Fügt nur neue Einträge hinzu, unabhängig von existingPlan

        //Erstellt item für die Liste
        DateTime endOfWeek = DateTime.parse(firstWeekDayString).add(Duration(days: 6));
        String startOfWeekString = DateFormat("dd-MM-yyyy").format(DateTime.parse(firstWeekDayString));
        String endOfWeekString = DateFormat("dd-MM-yyyy").format(endOfWeek);
        String title1 = "$startOfWeekString - $endOfWeekString";

        WeekTileData data = WeekTileData(icon: Icons.abc, title: title1, weekKey: firstWeekDayString);
        print(data);
        //MainPageState().addEntry(data); //Geht das?
        //if (existingPlan.isEmpty)
        weekAppointmentList.add(data);
        print(terminItems.length);

        firstWeekDay = firstWeekDay.add(Duration(days: 7));
        firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstWeekDay);
        terminItems = [];
      }
      Termin t = Termin(
          terminName: terminMap[i]["TerminName"],
          timeBegin: DateTime.parse(terminMap[i]["TerminBeginn"]),
          timeEnd: DateTime.parse(terminMap[i]["TerminEnde"]),
          question0: -1,
          question1: -1,
          question2: -1,
          question3: -1,
          comment: "",
          answered: false);
        if(i == terminMap.length-1){
          //Hier müsste nochmal terminItems hochgeladen un neue dataelement erstellt werden
        }
      terminItems.add(t);
    }
    return weekAppointmentList;
  }*/

/* Alternative version mit for-loop
    List<Map<String, dynamic>> existingWeekPlans = await databaseHelper.getAllWeekPlans();
    if (existingWeekPlans.isNotEmpty){
      bool weekKeyFound = false;
      for(var existingPlan in existingWeekPlans){
        String weekKey = existingPlan["weekKey"];
        if(!weekKeyFound){
          for(int i = 0; i < 7; i++){
            //
            DateTime iterationDateTime = DateTime.parse(weekKey).add(Duration(days: i));
            String iterationWeekKey = DateFormat("yyyy-MM-dd").format(iterationDateTime);
            if(iterationWeekKey == firstWeekDayString){
              firstWeekDayString = weekKey;
              weekKeyFound = true;
              break;
            }
          }
        }
      }
    }*/