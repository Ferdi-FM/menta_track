import 'dart:convert';
import 'dart:io';

//Klasse, die Termine simulieren soll, neue Wochen können variabel hinzugefügt werden
//Es ist angedacht, dass der Therapeut eine Map mit Key=Das erste Datum der Woche und Value=Liste der Termine

class CreateDummyJsonForTesting{
  Map<String, dynamic> mapItem = {};
  List<Map<String, String>> oneTermine = [];
  List<Map<String, String>> twoTermine = [];

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

    ///Keys abgekürzt um QR-Code Größe zu reduzieren
    oneTermine = [
      {
        "tN": "Arztbesuch",
        "tB": "2025-01-20 09:00:00",
        "tE": "2025-01-20 10:00:00"
      },
      {
        "tN": "Essen",
        "tB": "2025-01-20 12:00:00",
        "tE": "2025-01-20 13:00:00"
      },
      {
        "tN": "Spazieren gehen",
        "tB": "2025-01-20 13:30:00",
        "tE": "2025-01-20 14:30:00"
      },
      {
        "tN": "Meeting",
        "tB": "2025-01-21 14:00:00",
        "tE": "2025-01-21 15:30:00"
      },
      {
        "tN": "Sport",
        "tB": "2025-01-22 18:00:00",
        "tE": "2025-01-22 19:00:00"
      },
      {
        "tN": "Yoga",
        "tB": "2025-01-23 13:30:00",
        "tE": "2025-01-23 14:30:00"
      },
      {
        "tN": "Malen",
        "tB": "2025-01-24 14:00:00",
        "tE": "2025-01-24 15:30:00"
      },
      {
        "tN": "Neue Folge Severance",
        "tB": "2025-01-25 18:00:00",
        "tE": "2025-01-25 19:00:00"
      },
      {
        "tN": "Enstpannungsbad nehmen",
        "tB": "2025-01-26 20:00:00",
        "tE": "2025-01-26 21:00:00"
      },
      {
        "tN": "Hunde gassi",
        "tB": "2025-01-27 09:00:00",
        "tE": "2025-01-27 10:00:00"
      },
      {
        "tN": "Kochen",
        "tB": "2025-01-28 14:00:00",
        "tE": "2025-01-28 15:30:00"
      },
      {
        "tN": "Hobby",
        "tB": "2025-01-29 18:00:00",
        "tE": "2025-01-29 19:00:00"
      },
      {
        "tN": "Arztbesuch",
        "tB": "2025-03-10 09:00:00",
        "tE": "2025-03-10 10:00:00"
      },
      {
        "tN": "Essen",
        "tB": "2025-03-10 12:00:00",
        "tE": "2025-03-10 13:00:00"
      },
      {
        "tN": "Spazieren gehen",
        "tB": "2025-03-10 13:30:00",
        "tE": "2025-03-10 14:30:00"
      },
      {
        "tN": "Meeting",
        "tB": "2025-03-11 14:00:00",
        "tE": "2025-03-11 15:30:00"
      },
      {
        "tN": "Sport",
        "tB": "2025-03-12 18:00:00",
        "tE": "2025-03-12 19:00:00"
      },
      {
        "tN": "Yoga",
        "tB": "2025-03-13 13:30:00",
        "tE": "2025-03-13 14:30:00"
      },
      {
        "tN": "Malen",
        "tB": "2025-03-14 14:00:00",
        "tE": "2025-03-14 15:30:00"
      },
      {
        "tN": "Neue Folge Severance",
        "tB": "2025-03-15 18:00:00",
        "tE": "2025-03-15 19:00:00"
      },
      {
        "tN": "Enstpannungsbad nehmen",
        "tB": "2025-03-16 20:00:00",
        "tE": "2025-03-16 21:00:00"
      }
    ];

    twoTermine = [
      {
        "tN": "Auf Mount Everest klettern",
        "tB": "2025-03-05 09:00:00",
        "tE": "2025-03-05 10:00:00"
      },
      {
        "tN": "App Testen",
        "tB": "2025-03-05 15:00:00",
        "tE": "2025-03-05 15:30:00"
      },
      {
        "tN": "Speisen",
        "tB": "2025-03-06 12:00:00",
        "tE": "2025-03-06 13:00:00"
      },
      {
        "tN": "Sonnen",
        "tB": "2025-03-07 13:30:00",
        "tE": "2025-03-07 14:30:00"
      },
      {
        "tN": "Tierarzt",
        "tB": "2025-03-08 11:00:00",
        "tE": "2025-03-08 13:30:00"
      },
      {
        "tN": "Schneidern",
        "tB": "2025-03-09 12:00:00",
        "tE": "2025-03-09 13:00:00"
      },
      {
        "tN": "Pilatis",
        "tB": "2025-03-10 09:30:00",
        "tE": "2025-03-10 10:30:00"
      },
      {
        "tN": "Tanzen",
        "tB": "2025-03-11 16:00:00",
        "tE": "2025-03-11 17:30:00"
      }
    ];
  //TODO: JSON-Keys abkürzen => tM, tB, tE
    mapItem = {"2025-01-20" : termine, "2025-01-27" : termine2, "2025-03-10" : termine3};
  }

  String toCompressedIntList(){
    //Json zu String
    String unCompressedString = jsonEncode(oneTermine);
    // String in Bytes
    List<int> bytes = utf8.encode(unCompressedString);
    // GZip-Kompression mit GZipCodec
    var codec = GZipCodec();
    List<int> compressedData = codec.encode(bytes);
    // Komprimierte List<int> in Base64 kodieren
    String base64EncodedString = base64Encode(compressedData);

    return base64EncodedString;
  }

  String toCompressedIntListTwoTermine(){
    //Json zu String
    String unCompressedString = jsonEncode(twoTermine);
    // String in Bytes
    List<int> bytes = utf8.encode(unCompressedString);
    // GZip-Kompression mit GZipCodec
    var codec = GZipCodec();
    List<int> compressedData = codec.encode(bytes);
    // Komprimierte List<int> in Base64 kodieren
    String base64EncodedString = base64Encode(compressedData);

    return base64EncodedString;
  }

  String getOneDummyData(){
    return jsonEncode(oneTermine);
  }

  String getDummyData(){
    return jsonEncode(mapItem);
  }
}