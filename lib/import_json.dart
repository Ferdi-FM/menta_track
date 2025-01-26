import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/create_dummy_json_for_testing.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/termin.dart';
import 'package:menta_track/week_tile_data.dart';

//Evtl um main.dart etwas geordneter und schlanker zu haben. Noch nicht getestet

class ImportJson {
  DatabaseHelper databaseHelper = DatabaseHelper();

  ImportJson();

  Future<List<WeekTileData>> loadDummyData() async {
    CreateDummyJsonForTesting dummy = CreateDummyJsonForTesting();
    final dummyData = dummy.getDummyData();
    final terminMap = jsonDecode(dummyData) as Map<String, dynamic>;
    return await createWeekPlanMapFromJson(terminMap);
  }

  Future<List<WeekTileData>> createWeekPlanMapFromJson(Map terminMap) async {
    List<WeekTileData> weekAppointmentList = [];
    for (int i = 0; i < terminMap.length; i++) {

      List<Termin> terminItems = [];
      String firstWeekDay = terminMap.keys.toList()[i]
          .toString(); //nimmt den key der Map aus der Json-Datei um die Woche zu indentifizieren
      List termine = terminMap[firstWeekDay]; //Liste der übertragenen Termine für die Woche

      for (int j = 0; j < termine.length; j++) { //Convertiert die vom Therapeuten erstelle Liste in eine Liste aus Termin-Items für den Patienten
        var termin = termine[j];
        Termin t = Termin(
            terminName: termin["TerminName"],
            timeBegin: DateTime.parse(termin["TerminBeginn"]),
            timeEnd: DateTime.parse(termin["TerminEnde"]),
            question0: -1,
            question1: -1,
            question2: -1,
            question3: -1,
            comment: "",
            answered: false);

        terminItems.add(t);
      }

      List<Termin> existingPlan = await databaseHelper.getWeeklyPlan(firstWeekDay);
      if (existingPlan.isEmpty) {
        //Erstellt Datenbank Eintrag
        await databaseHelper.insertWeeklyPlan(firstWeekDay, terminItems);

        //Erstellt item für die Liste
        DateTime endOfWeek = DateTime.parse(firstWeekDay).add(Duration(days: 6));
        String startOfWeekString = DateFormat("dd-MM-yyyy").format(DateTime.parse(firstWeekDay));
        String endOfWeekString = DateFormat("dd-MM-yyyy").format(endOfWeek);
        String title1 = "$startOfWeekString - $endOfWeekString";

        WeekTileData data = WeekTileData(icon: Icons.abc, title: title1, weekKey: firstWeekDay);
        //MainPageState().addEntry(data); //Geht das?
        weekAppointmentList.add(data);
      }
    }
    return weekAppointmentList;
  }
}