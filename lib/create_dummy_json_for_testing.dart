import 'dart:convert';
import 'dart:io';

///Klasse, die Termine simulieren soll, neue Wochen können variabel hinzugefügt werden

class CreateDummyJsonForTesting{
  Map<String, dynamic> mapItem = {};
  List<Map<String, String>> oneTermine = [];
  List<Map<String, String>> twoTermine = [];
  List<Map<String, String>> studyTermine = [];
  List<Map<String, String>> presentationTermine = [];

  List<Map<String, String>> singleWeek = [];

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

    studyTermine = [
      {
        "tN": "Frühstück",
        "tB": "2025-03-03 10:00:00",
        "tE": "2025-03-03 11:00:00"
      },
      {
        "tN": "Aufräumen & Putzen",
        "tB": "2025-03-03 11:30:00",
        "tE": "2025-03-03 13:00:00"
      },
      {
        "tN": "Nichts tun",
        "tB": "2025-03-03 15:00:00",
        "tE": "2025-03-03 16:30:00"
      },
      {
        "tN": "Frühstück",
        "tB": "2025-03-04 10:00:00",
        "tE": "2025-03-04 11:00:00"
      },
      {
        "tN": "Aufräumen & Putzen",
        "tB": "2025-03-05 11:30:00",
        "tE": "2025-03-05 13:00:00"
      },
      {
        "tN": "Nichts tun",
        "tB": "2025-03-06 15:00:00",
        "tE": "2025-03-06 16:30:00"
      },
      {
        "tN": "Aufstehen",
        "tB": "2025-03-10 09:00:00",
        "tE": "2025-03-10 10:00:00"
      },
      {
        "tN": "Zähne putzen",
        "tB": "2025-03-10 09:30:00",
        "tE": "2025-03-10 10:00:00"
      },
      {
        "tN": "Frühstück",
        "tB": "2025-03-10 09:45:00",
        "tE": "2025-03-10 10:40:00"
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
        "tN": "Hobby",
        "tB": "2025-03-14 14:00:00",
        "tE": "2025-03-14 15:30:00"
      },
      {
        "tN": "Auf Mount Everest klettern",
        "tB": "2025-03-15 18:00:00",
        "tE": "2025-03-15 19:00:00"
      },
      {
        "tN": "Sauna",
        "tB": "2025-03-16 20:00:00",
        "tE": "2025-03-16 21:00:00"
      },
      {
        "tN": "App testen",
        "tB": "2025-03-17 13:00:00",
        "tE": "2025-03-17 14:00:00"
      },
      {
        "tN": "Reflektieren",
        "tB": "2025-03-17 13:30:00",
        "tE": "2025-03-17 14:30:00"
      },
      {
        "tN": "Probieren",
        "tB": "2025-03-18 15:30:00",
        "tE": "2025-03-18 16:30:00"
      },
      {
        "tN": "Testen",
        "tB": "2025-03-19 13:30:00",
        "tE": "2025-03-19 14:30:00"
      },
      {
        "tN": "Feedback geben",
        "tB": "2025-03-20 14:00:00",
        "tE": "2025-03-20 15:30:00"
      },
      {
        "tN": "Film Abend",
        "tB": "2025-03-21 18:00:00",
        "tE": "2025-03-21 19:00:00"
      },
      {
        "tN": "Bouldern",
        "tB": "2025-03-23 13:30:00",
        "tE": "2025-03-23 14:30:00"
      },
      {
        "tN": "Brunch",
        "tB": "2025-03-24 14:00:00",
        "tE": "2025-03-24 15:30:00"
      },
      {
        "tN": "Meditieren",
        "tB": "2025-03-25 18:00:00",
        "tE": "2025-03-25 19:00:00"
      },
      {
        "tN": "Nichts tun",
        "tB": "2025-03-26 20:00:00",
        "tE": "2025-03-26 21:00:00"
      },
      {
        "tN": "Tierheim helfen",
        "tB": "2025-03-27 09:00:00",
        "tE": "2025-03-27 10:00:00"
      },
      {
        "tN": "2 Wochen Einkauf",
        "tB": "2025-03-28 14:00:00",
        "tE": "2025-03-28 15:30:00"
      },
      {
        "tN": "Lieblingsessen kochen",
        "tB": "2025-03-29 18:00:00",
        "tE": "2025-03-29 19:00:00"
      }
    ];

    presentationTermine = [
      {
        "tN": "Frühstück",
        "tB": "2025-03-03 10:00:00",
        "tE": "2025-03-03 11:00:00"
      },
      {
        "tN": "Aufräumen & Putzen",
        "tB": "2025-03-03 11:30:00",
        "tE": "2025-03-03 13:00:00"
      },
      {
        "tN": "Nichts tun",
        "tB": "2025-03-03 15:00:00",
        "tE": "2025-03-03 16:30:00"
      },
      {
        "tN": "Frühstück",
        "tB": "2025-03-04 10:00:00",
        "tE": "2025-03-04 11:00:00"
      },
      {
        "tN": "Aufräumen & Putzen",
        "tB": "2025-03-05 11:30:00",
        "tE": "2025-03-05 13:00:00"
      },
      {
        "tN": "Aufstehen",
        "tB": "2025-03-10 09:00:00",
        "tE": "2025-03-10 10:00:00"
      },
      {
        "tN": "Frühstück",
        "tB": "2025-03-10 09:45:00",
        "tE": "2025-03-10 11:00:00"
      },
      {
        "tN": "Langsam angehen lassen",
        "tB": "2025-03-10 10:15:00",
        "tE": "2025-03-10 12:00:00"
      },
      {
        "tN": "Meeting",
        "tB": "2025-03-11 14:00:00",
        "tE": "2025-03-11 15:30:00"
      },
      {
        "tN": "Nicht zu ernst nehmen",
        "tB": "2025-03-11 15:00:00",
        "tE": "2025-03-11 16:30:00"
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
        "tN": "Hobby",
        "tB": "2025-03-14 14:00:00",
        "tE": "2025-03-14 15:30:00"
      },
      {
        "tN": "Auf Mount Everest klettern",
        "tB": "2025-03-15 18:00:00",
        "tE": "2025-03-15 19:00:00"
      },
      {
        "tN": "Sauna",
        "tB": "2025-03-16 20:00:00",
        "tE": "2025-03-16 21:00:00"
      },
      {
        "tN": "App testen",
        "tB": "2025-03-17 13:00:00",
        "tE": "2025-03-17 14:00:00"
      },
      {
        "tN": "Probieren",
        "tB": "2025-03-18 15:30:00",
        "tE": "2025-03-18 16:30:00"
      },
      {
        "tN": "Testen",
        "tB": "2025-03-19 13:30:00",
        "tE": "2025-03-19 14:30:00"
      },
      {
        "tN": "Feedback geben",
        "tB": "2025-03-20 14:00:00",
        "tE": "2025-03-20 15:30:00"
      },
      {
        "tN": "Film Abend",
        "tB": "2025-03-21 18:00:00",
        "tE": "2025-03-21 19:00:00"
      },
      {
        "tN": "Bouldern",
        "tB": "2025-03-23 13:30:00",
        "tE": "2025-03-23 14:30:00"
      },
      {
        "tN": "Brunch",
        "tB": "2025-03-24 14:00:00",
        "tE": "2025-03-24 15:30:00"
      },
      {
        "tN": "Meditieren",
        "tB": "2025-03-25 18:00:00",
        "tE": "2025-03-25 19:00:00"
      },
      {
        "tN": "Nichts tun",
        "tB": "2025-03-26 20:00:00",
        "tE": "2025-03-26 21:00:00"
      },
      {
        "tN": "Kochen",
        "tB": "2025-03-30 20:00:00",
        "tE": "2025-03-30 21:00:00"
      },
      {
        "tN": "Tierheim helfen",
        "tB": "2025-03-31 09:00:00",
        "tE": "2025-03-31 10:00:00"
      },
      {
        "tN": "2 Wochen Einkauf",
        "tB": "2025-04-01 14:00:00",
        "tE": "2025-04-01 15:30:00"
      },
      {
        "tN": "Lieblingsessen kochen",
        "tB": "2025-04-03 18:00:00",
        "tE": "2025-04-03 19:00:00"
      }
    ];

    singleWeek = [
      {
        "tN": "Tierheim helfen",
        "tB": "2025-03-31 09:00:00",
        "tE": "2025-03-31 10:00:00"
      },
      {
        "tN": "2 Wochen Einkauf",
        "tB": "2025-04-01 14:00:00",
        "tE": "2025-04-01 15:30:00"
      },
      {
        "tN": "Lieblingsessen kochen",
        "tB": "2025-04-03 18:00:00",
        "tE": "2025-04-03 19:00:00"
      }
    ];

    // 2025-01-20         20.01 21.01 22.01 | 29.01 30.01.22.01    "20-26" ->  29 ->22 -> 20! "+6" -> 27
    // 2025-01-29      ICH WIL HINZUFÜGEN: 18.01- 31.01

    mapItem = {"2025-01-20" : termine, "2025-01-27" : termine2, "2025-03-10" : termine3};
  }

  String toCompressedStudyList(){
    //Json zu String
    String unCompressedString = jsonEncode(presentationTermine);
    // String in Bytes
    List<int> bytes = utf8.encode(unCompressedString);
    // GZip-Kompression mit GZipCodec
    var codec = GZipCodec();
    List<int> compressedData = codec.encode(bytes);
    // Komprimierte List<int> in Base64 kodieren
    String base64EncodedString = base64Encode(compressedData);

    return base64EncodedString;
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