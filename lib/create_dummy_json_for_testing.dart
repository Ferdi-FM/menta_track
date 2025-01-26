import 'dart:convert';

//Klasse, die Termine simulieren soll, neue Wochen können variabel hinzugefügt werden
//Es ist angedacht, dass der Therapeut eine Map mit Key=Das erste Datum der Woche und Value=Liste der Termine

class CreateDummyJsonForTesting{
  Map<String, dynamic> mapItem = {};

  CreateDummyJsonForTesting(){
    final termine = [
      {
        "TerminName": "Arztbesuch",
        "TerminBeginn": "2025-01-20 09:00:00",
        "TerminEnde": "2025-01-20 10:00:00",
      },
      {
        "TerminName": "Essen",
        "TerminBeginn": "2025-01-20 12:00:00",
        "TerminEnde": "2025-01-20 13:00:00",
      },
      {
        "TerminName": "Spazieren gehen",
        "TerminBeginn": "2025-01-20 13:30:00",
        "TerminEnde": "2025-01-20 14:30:00",
      },
      {
        "TerminName": "Meeting",
        "TerminBeginn": "2025-01-21 14:00:00",
        "TerminEnde": "2025-01-21 15:30:00",
      },
      {
        "TerminName": "Sport",
        "TerminBeginn": "2025-01-22 18:00:00",
        "TerminEnde": "2025-01-22 19:00:00",
      },
    ];
    final termine2 = [
      {
        "TerminName": "Hunde gassi",
        "TerminBeginn": "2025-01-27 09:00:00",
        "TerminEnde": "2025-01-27 10:00:00",
      },
      {
        "TerminName": "Kochen",
        "TerminBeginn": "2025-01-28 14:00:00",
        "TerminEnde": "2025-01-28 15:30:00",
      },
      {
        "TerminName": "Hobby",
        "TerminBeginn": "2025-01-29 18:00:00",
        "TerminEnde": "2025-01-29 19:00:00",
      },
    ];

    mapItem = {"2025-01-20" : termine, "2025-01-27" : termine2};
  }

  String getDummyData(){
    return jsonEncode(mapItem);
  }
}