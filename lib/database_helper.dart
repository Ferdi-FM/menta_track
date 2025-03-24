import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:menta_track/notification_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'termin.dart';

///Klasse für alles was mit der SQLite-Datenbank zu tun hat

class DatabaseHelper {
  static Database? _database;

  ///Getter für Datenbank
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  ///Erstellt die Datenbank
  Future<Database> initDatabase() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "weekly_plans_test7.db"),
      onCreate: (db, version) async {
        //Könnte auch aus "Termine" errechnet werden, ist so aber performanter und einfacher zu organisieren
        await db.execute('''
         CREATE TABLE WeeklyPlans(
           id INTEGER PRIMARY KEY,
           weekKey TEXT UNIQUE,
           goodMean DOUBLE,
           calmMean DOUBLE,
           helpingMean DOUBLE
         )
       ''');

        await db.execute('''
          CREATE TABLE Termine(
            id INTEGER PRIMARY KEY,
            weekKey TEXT,
            terminName TEXT,
            timeBegin TEXT,
            timeEnd TEXT,
            doneQuestion INTEGER, 
            goodQuestion INTEGER,
            calmQuestion INTEGER,
            helpQuestion INTEGER,
            comment TEXT,
            answered INTEGER,
            FOREIGN KEY(weekKey) REFERENCES WeeklyPlans(weekKey)
          )
        ''');
      },
      version: 3,
    );
  }

  Future<void> insertSingleWeek(String weekKey, BuildContext context) async{
    final db = await database;
    String query = '''
      SELECT weekKey FROM WeeklyPlans 
      WHERE date(weekKey) BETWEEN date(?, '-6 days') AND date(?, '+6 days')
      LIMIT 1;
    ''';
    List<Map<String, dynamic>> result = await db.rawQuery(query, [weekKey, weekKey]);

    if(result.isEmpty){
      await db.insert(
        "WeeklyPlans",
        {"weekKey": weekKey},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      if(context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Woche würde sich überschneiden"))
        );
      }
    }
  }

  ///Speichert einen neuen Termin in der Datenbank
  Future<void> insertWeeklyPlan(String weekKey, List<Termin> terminItems) async {
    final db = await database;
    await db.insert(
      "WeeklyPlans",
      {"weekKey": weekKey},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    //Einfügen der Termine in die Tabelle, die als Key den ersten Tag der Woche hat
    for (var termin in terminItems) {
      Termin? t = await getSpecificTermin(weekKey, termin.timeBegin.toIso8601String(), termin.terminName); //checkt ob es den Termin schon gibt
      if(t == null) { //Sollte es notwendig werden, dass eine Woche geupdated wird, ist es so möglich, da Termine-Table keine unique Keys hat. Man könne timebegin und end zu UNIQUE machen, dann könnte man aber keine 2 Termine zur gleichen zeit haben
        await db.insert(
          "Termine",
          {
            "weekKey": weekKey,
            "terminName": termin.terminName,
            "timeBegin": termin.timeBegin.toIso8601String(),
            "timeEnd": termin.timeEnd.toIso8601String(),
            "doneQuestion": termin.doneQuestion,
            "goodQuestion": termin.goodMean,
            "calmQuestion": termin.calmMean,
            "helpQuestion": termin.helpMean,
            "comment": termin.comment,
            "answered": termin.answered ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  }

  Future<void> insertSingleTermin(String weekKey, String terminName, DateTime timeBegin, DateTime timeEnd) async {
    final db = await database;
    //Einfügen der Termine in die Tabelle, die als Key den ersten Tag der Woche hat
    Termin termin = Termin(
        terminName: terminName,
        timeBegin: timeBegin,
        timeEnd: timeEnd,
        doneQuestion: -1,
        goodMean: -1,
        calmMean: -1,
        helpMean: -1,
        comment: "",
        answered: false,
        weekKey: weekKey);

    await db.insert(
      "Termine",
      termin.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    NotificationHelper().scheduleNewTerminNotification(termin);
  }

  ///Funktionen für alle Termine

  ///Gibt alle Termine in einer Liste zurück
  Future<List<Termin>> getAllTermine() async {
    final db = await database;
    List<Termin> termine = mapToTerminList(await db.query("Termine"));
    return termine;
  }

  Future<int> getAllTermineCountUnconditional() async {
    final db = await database;
    int count = Sqflite.firstIntValue(await db.rawQuery(
      "SELECT COUNT(*) FROM Termine",
    )) ?? 0;

    return count;
  }

  ///Gibt die Anzahl an allen Terminen zurück
  Future<int> getAllTermineCount(bool answered, bool tillNow) async {
    final db = await database;

    String query = "SELECT COUNT(*) FROM Termine WHERE answered = ? ";
    if (tillNow) query += "AND (datetime(timeBegin) < datetime(current_timestamp))";
    int count = Sqflite.firstIntValue(await db.rawQuery(query, [answered ? 1 : 0])) ?? 0;

    return count;
  }

  ///Funktionen für Termine in einer Woche

  ///Gibt eine Liste mit allen Terminen in einer woche "weekKey" aus der Datenbank zurück. WeekKey braucht format "yyyy-MM-dd"
  Future<List<Termin>> getWeeklyPlan(String weekKey) async {
   final db = await database;
   final List<Map<String, dynamic>> maps = await db.query( //Holt alle Termine, die den spezifizierten weekKey verwenden
      "Termine",
      where: "weekKey = ?",
      whereArgs: [weekKey],
    );
    return mapToTerminList(maps); // Konvertiert die Liste an Maps in Termin-Objekte und gibt diese zurück
  }

  ///Gibt die Anzahl aller Termine in einer woche zurück. WeekKey braucht format "yyyy-MM-dd"
  Future<int> getWeekTermineCount(String weekKey, bool tillNow) async {
    final db = await database;
    String query = "SELECT COUNT(*) FROM Termine WHERE weekKey = ?";
    if (tillNow) query += " AND (datetime(timeBegin) < datetime(current_timestamp))";
    int count = Sqflite.firstIntValue(await db.rawQuery(
      query,
      [weekKey],
    )) ?? 0;
    return count;
  }

  ///Gibt die Anzahl aller un/beantworteter Termine in einer woche zurück. WeekKey braucht format "yyyy-MM-dd"
  Future<int> getWeekTermineCountAnswered(String weekKey, bool answered) async {
    final db = await database;
    int count = Sqflite.firstIntValue(await db.rawQuery(
      "SELECT COUNT(*) FROM Termine WHERE weekKey = ? AND answered = ?",
      [weekKey, answered ? 1: 0],
    )) ?? 0;
    return count;
  }

  ///Funktionen für Termine an einem Tag

  ///Gibt die Anzahl aller Termine in einer woche zurück. weekDayKey braucht format "dd.MM.yy" oder "yyyy-MM-dd"
  Future<int> getDayTermineCount(String weekDayKey) async {
    final db = await database;
    DateTime date = DateFormat('dd.MM.yy').parse(weekDayKey);
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    int count = Sqflite.firstIntValue(await db.rawQuery(
      "SELECT COUNT(*) FROM Termine WHERE timeBegin LIKE ?",
      ["$formattedDate%"],
    )) ?? 0;
    return count;
  }

  ///Gibt eine Liste aller un/beantworteter Termine in einer woche zurück. weekDayKey braucht format "dd.MM.yy" oder "yyyy-MM-dd"
  Future<List<Termin>> getDayTermineAnswered(String weekDayKey, bool answered, [bool? tillNow]) async { //EVTL. DateTime anstelle weekDayKey
    final db = await database;
    String checkedFormatDateString = Utilities().checkDateFormat(weekDayKey); //Extra check ob weekDayKey richtiges Format hat
    String query = "timeBegin LIKE ? AND answered = ?";
    if(tillNow == true) query += "AND (datetime(timeBegin) < datetime(current_timestamp))";

    final List<Map<String, dynamic>> terminMap = await db.query(
      "Termine",
      where: query,
      whereArgs: ["$checkedFormatDateString%", answered ? 1 : 0],
    );

    return mapToTerminList(terminMap);
  }

  ///Gibt eine Liste aller Termine in einer woche zurück. weekDayKey braucht format "dd.MM.yy" oder "yyyy-MM-dd"
  Future<List<Termin>> getDayTermine(String weekDayKey) async {
    final db = await database;
    String formattedDate = Utilities().checkDateFormat(weekDayKey); //Nötig? Checkt ob weekDayKey "dd.MM.yy" ist und wandelt es in "yyyy-MM-dd" um, damit es mit SQLite date-funktionen funktioniert
    final List<Map<String, dynamic>> terminMap = await db.query(
      "Termine",
      where: "timeBegin LIKE ?",
      whereArgs: ["$formattedDate%"],
    );
    return mapToTerminList(terminMap);
  }


  ///Einzelne Termin Funktionen
  ///Gibt einen einzelnen bestimmten Termin zurück, der über weekKey, timeBegin und terminName identifiziert wird (sollte keine überschneidungen geben)
  Future<Termin?> getSpecificTermin(String weekKey, String timeBegin, String terminName) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
        "Termine",
        where: "weekKey = ? AND timeBegin = ? AND terminName = ?" ,
        whereArgs: [weekKey, timeBegin, terminName],
        limit: 1
    );
    if(maps.length == 1){
      return mapToTerminList(maps).first;
    } else {
      return null;
    }
  }

  ///Allgemeines

  ///Updated einen Termineintrag in der Datenbank
  Future<void> updateEntry(String weekKey, String timeBegin, String terminName, Map<String, dynamic> updatedValues) async {
    final db = await database;

    await db.update(
      "Termine",
      updatedValues,
      where: "weekKey = ? AND timeBegin = ? AND terminName = ?",
      whereArgs: [weekKey, timeBegin, terminName],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ///Updated den Durchschnittswert in der WeeklyPlans-Table
  Future<void> updateActivities(String weekKey)async {
    final db = await database;
    List<Map<String,dynamic>> maps = await db.query(
      "Termine",
      columns: [
        "(SUM(goodQuestion) * 1.0) / COUNT(*) AS goodMean",
        "(SUM(calmQuestion) * 1.0) / COUNT(*) AS calmMean",
        "(SUM(helpQuestion) * 1.0) / COUNT(*) AS helpMean"
      ],
      where: "answered = 1 AND weekKey = ?",
      whereArgs: [weekKey],
    );
    double goodMean = maps[0]["goodMean"] ?? -1.0; // Standardwert -1, wenn null
    double calmMean = maps[0]["calmMean"] ?? -1.0;
    double helpMean = maps[0]["helpMean"] ?? -1.0;

    //print("IN UPDATEACTIVITIES: \n $goodMean \n $calmMean \n $helpMean");

    Map<String, dynamic> updatedValues = {
      "goodMean": goodMean,
      "calmMean": calmMean,
      "helpingMean": helpMean,
    };

    await db.update(
      "WeeklyPlans",
      updatedValues,
      where: "weekKey = ?",
      whereArgs: [weekKey],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ///Gibt eine Map mit allen Einträgen in WeeklyPlans zurück
  Future<List<Map<String, dynamic>>> getAllWeekPlans() async {
    final db = await database;
    return await db.query("WeeklyPlans");
  }

  ///Wandelt eine map  aus der Termine-Table in eine Liste mit Termin-Elementen um
  List<Termin> mapToTerminList(List<Map<String, dynamic>> maps){
    return List.generate(maps.length, (i) {
      return Termin(
        weekKey: maps[i]["weekKey"],
        terminName: maps[i]["terminName"],
        timeBegin: DateTime.parse(maps[i]["timeBegin"]),
        timeEnd: DateTime.parse(maps[i]["timeEnd"]),
        doneQuestion: maps[i]["doneQuestion"],
        goodMean: maps[i]["goodQuestion"],
        calmMean: maps[i]["calmQuestion"],
        helpMean: maps[i]["helpQuestion"],
        comment: maps[i]["comment"],
        answered: maps[i]["answered"] == 1,
      );
    });
  }

  ///löscht eine Woche weekKey aus WeeklyPlans-Table und entsprechende Termine aus Termine-Table aus der Datenbank
  Future<void> dropTable(String weekKey) async {
    Database db = await database;

    await db.execute("DELETE FROM WeeklyPlans WHERE weekKey = ?", [weekKey]);
    await db.execute("DELETE FROM Termine WHERE weekKey = ?", [weekKey]);//Könnte mit SQLite Cascade gelöscht werden, da weekKey foreignkey ist
  }

  Future<void> dropTermin(String weekKey, String terminName, String timeBegin) async {
    final db = await database;

    await db.delete(
      "Termine",
      where: "weekKey = ? AND timeBegin = ? AND terminName = ?" ,
      whereArgs: [weekKey, timeBegin, terminName],
    );
  }
}