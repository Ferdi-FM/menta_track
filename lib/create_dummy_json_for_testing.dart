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
      {
        "TerminName": "Yoga",
        "TerminBeginn": "2025-01-23 13:30:00",
        "TerminEnde": "2025-01-23 14:30:00",
      },
      {
        "TerminName": "Malen",
        "TerminBeginn": "2025-01-24 14:00:00",
        "TerminEnde": "2025-01-24 15:30:00",
      },
      {
        "TerminName": "Neue Folge Severance",
        "TerminBeginn": "2025-01-25 18:00:00",
        "TerminEnde": "2025-01-25 19:00:00",
      },
      {
        "TerminName": "Enstpannungsbad nehmen",
        "TerminBeginn": "2025-01-26 20:00:00",
        "TerminEnde": "2025-01-26 21:00:00",
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
    final termine3 = [
      {
        "TerminName": "Arztbesuch",
        "TerminBeginn": "2025-03-10 09:00:00",
        "TerminEnde": "2025-03-10 10:00:00"
      },
      {
        "TerminName": "Essen",
        "TerminBeginn": "2025-03-10 12:00:00",
        "TerminEnde": "2025-03-10 13:00:00"
      },
      {
        "TerminName": "Spazieren gehen",
        "TerminBeginn": "2025-03-10 13:30:00",
        "TerminEnde": "2025-03-10 14:30:00"
      },
      {
        "TerminName": "Meeting",
        "TerminBeginn": "2025-03-11 14:00:00",
        "TerminEnde": "2025-03-11 15:30:00"
      },
      {
        "TerminName": "Sport",
        "TerminBeginn": "2025-03-12 18:00:00",
        "TerminEnde": "2025-03-12 19:00:00"
      },
      {
        "TerminName": "Yoga",
        "TerminBeginn": "2025-03-13 13:30:00",
        "TerminEnde": "2025-03-13 14:30:00"
      },
      {
        "TerminName": "Malen",
        "TerminBeginn": "2025-03-14 14:00:00",
        "TerminEnde": "2025-03-14 15:30:00"
      },
      {
        "TerminName": "Neue Folge Severance",
        "TerminBeginn": "2025-03-15 18:00:00",
        "TerminEnde": "2025-03-15 19:00:00"
      },
      {
        "TerminName": "Enstpannungsbad nehmen",
        "TerminBeginn": "2025-03-16 20:00:00",
        "TerminEnde": "2025-03-16 21:00:00"
      }
    ];

    //TODO: Algorithmus, der aus einer einzigen Liste die Wochen herrausliest

    mapItem = {"2025-01-20" : termine, "2025-01-27" : termine2, "2025-03-10" : termine3};
  }

  String getDummyData(){
    return jsonEncode(mapItem);
  }
}