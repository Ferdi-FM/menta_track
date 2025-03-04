import 'package:intl/intl.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:string_similarity/string_similarity.dart';

import 'termin.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "weekly_plans_ver2.db"),
      onCreate: (db, version) async {
        await db.execute('''
         CREATE TABLE WeeklyPlans(
           id INTEGER PRIMARY KEY,
           weekKey TEXT UNIQUE,
           goodMean DOUBLE,
           calmMean DOUBLE,
           helpingMean DOUBLE
         )
       ''');

        //Tables zum speichern der Aktivitäten, die gut getan haben
        await db.execute('''
         CREATE TABLE savedActivities(
           id INTEGER PRIMARY KEY,
           activity TEXT,
           category TEXT,
           doneTask INTEGER
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
      version: 2,
    );
  }



  Future<void> updateActivities(String weekKey)async {
    final db = await database;
    List<Map<String,dynamic>> maps = await db.query(
      "Termine",
      columns: [
        "SUM(goodQuestion) / COUNT(*) AS goodMean",
        "SUM(calmQuestion) / COUNT(*) AS calmMean",
        "SUM(helpQuestion) / COUNT(*) AS helpMean"
      ],
      where: "answered = 1 AND weekKey = ?",
      whereArgs: [weekKey],
    );
      var goodMean = maps[0]["goodMean"] ?? -1; // Standardwert -1, wenn null
      var calmMean = maps[0]["calmMean"] ?? -1;
      var helpMean = maps[0]["helpMean"] ?? -1;

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

  Future<void> insertWeeklyPlan(String weekKey, List<Termin> terminItems) async {
    final db = await database;

    //Erstellt die Tabelle mit dem ersten Tag der Woche in der Tabelle WeeklyPlans.
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

  Future<void> saveHelpingActivities(String activity, String category, bool doneTask) async {
   if(category == "good" || category == "calm" || category == "help"){//Check ob es eine der drei richtigen kategorien ist
     final db = await database;
     bool doesAlreadyExist = false;
     final List<Map<String, dynamic>> result = await db.query(
       "savedActivities",
       where: "category = ?",
       whereArgs: [category],
     );
     for (var row in result) {
       String databaseActivity = row["activity"].toLowerCase().trim();
       String newActivity = activity.toLowerCase().trim();

       double similarity = databaseActivity.similarityTo(newActivity); // Wert zwischen 0 und 1

       if (similarity > 0.8) {
         doesAlreadyExist = true;
         break;
       }
     }

     if(!doesAlreadyExist){
       await db.insert(
           "savedActivities",
           {
             "activity": activity,
             "category": category,
             "doneTask": doneTask ? 1 : 0,
           });
     }
   }
  }

  Future<List<Map<String, dynamic>>> getHelpingActivity() async{
    final db = await database;
    return await db.query("savedActivities"); //Alternativ könnte man eine query mit WHERE question1 = 6 OR question2 = 6 OR question3 = 6 durch die "Termine"-Table laufen lassen
  }

  Future<int> getAllTermineCount(bool answered, bool tillNow) async {
    final db = await database;

    String query = "SELECT COUNT(*) FROM Termine WHERE answered = ? ";
    if (tillNow) query += "AND (datetime(timeBegin) < datetime(CURRENT_DATE))";
    int count = Sqflite.firstIntValue(await db.rawQuery(query, [answered ? 1 : 0])) ?? 0;

    return count;
  }

  Future<List<Termin>> getAllTermine() async {
    final db = await database;
    List<Termin> termine = mapToTerminList(await db.query("Termine"));
    return termine;
  }

  //Gibt eine Liste mit allen Terminen in einer woche "weekKey" aus der Datenbank zurück. WeekKey braucht format "yyyy-MM-dd"
  Future<List<Termin>> getWeeklyPlan(String weekKey) async {
   final db = await database;
   final List<Map<String, dynamic>> maps = await db.query( //Holt alle Termine, die den spezifizierten weekKey verwenden
      "Termine",
      where: "weekKey = ?",
      whereArgs: [weekKey],
    );
    return mapToTerminList(maps); // Konvertiert die Liste an Maps in Termin-Objekte und gibt diese zurück
  }

  Future<int> getWeekTermineCount(String weekKey) async {
    final db = await database;
    int count = Sqflite.firstIntValue(await db.rawQuery(
      "SELECT COUNT(*) FROM Termine WHERE weekKey = ?",
      [weekKey],
    )) ?? 0;
    return count;
  }

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

  List<Termin> mapToTerminList(List<Map<String, dynamic>> maps){
    return List.generate(maps.length, (i) {
      return Termin(
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

  //Gibt eine Liste mit allen weekKeys in der Datenbank zurück
  Future<List<Map<String, dynamic>>> getAllWeekPlans() async {
    final db = await database;
    return await db.query("WeeklyPlans");
  }

  //Theoretische dynamische Funktion die jede Variation an Tagesterminen zurückgeben kann (alle, unbeantwortet, beantwortet) TODO: reine spielerei, eigentlich nicht notwendig
  Future<List<Termin>> getDayTerminDynamic(String weekDayKey, bool? answered) async{
    final db = await database;
    String checkedFormatDateString = Utilities().checkDateFormat(weekDayKey); // Überprüfung, ob der Key korrekt ist

    String query = "SELECT COUNT(*) FROM Termine WHERE timeBegin LIKE ?";
    List<dynamic> whereArgs = ["$checkedFormatDateString%"];
    if (answered != null) {
      query += " AND answered = ?";
      whereArgs.add(answered ? 1 : 0); // 1 für true, 0 für false
    }

    return mapToTerminList(await db.rawQuery(query, whereArgs));
  }

  Future<List<Termin>> getDayTermineAnswered(String weekDayKey, bool answered) async { //EVTL. DateTime anstelle weekDayKey
    final db = await database;
    String checkedFormatDateString = Utilities().checkDateFormat(weekDayKey);  //Extra check ob weekDayKey richtiges Format hat
    final List<Map<String, dynamic>> terminMap = await db.query(
      "Termine",
      where: "timeBegin LIKE ? AND answered = ?",
      whereArgs: ["$checkedFormatDateString%", answered ? 1 : 0],
    );

    return mapToTerminList(terminMap);
  }

  //Braucht weekDayKey als mit DateTime kompatiblen String oder "dd.MM.yy" String
  Future<List<Termin>> getDayTermine(String weekDayKey) async {
    final db = await database;
    //DateTime date = DateFormat('dd.MM.yy').parse(weekDayKey);
    //String formattedDate =DateFormat('yyyy-MM-dd').format(date);
    String formattedDate = Utilities().checkDateFormat(weekDayKey); //Nötig? Checkt ob weekDayKey "dd.MM.yy" ist und wandelt es in "yyyy-MM-dd" um, damit es mit SQLite date-funktionen funktioniert

    final List<Map<String, dynamic>> terminMap = await db.query(
      "Termine",
      where: "timeBegin LIKE ?",
      whereArgs: ["$formattedDate%"],
    );

    return mapToTerminList(terminMap);
  }

  //Gibt einen einzelnen bestimmten Termin zurück, der über weekKey, timeBegin und terminName identifiziert wird (sollte keine überschneidungen geben)
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

  //Updated einen Termineintrag in der Datenbank
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

  //löscht eine Woche weekKey aus der Datenbank
  Future<void> dropTable(String weekKey) async {
    Database db = await database;

    await db.execute("DELETE FROM WeeklyPlans WHERE weekKey = ?", [weekKey]); //einträge Müssen aus der Liste der Wochen
    await db.execute("DELETE FROM Termine WHERE weekKey = ?", [weekKey]);     //und aus der Liste der Termine entfernt werden.
  }
}

//TODO: Für alternative Version müssten alle weekKey = ? durch timeBegin BETWEEN date(startDateTime) AND date(endDateTime) ersetzt werden. Das würde zu Problemen führen, wenn sich der erste Tag einer WOche ändert
/* Zum Beispiel so:

    final db = await database;
    Map<String, dynamic> map = db.query("Termine").first;
    String dayTerminTime = "2025-01-20";
    DateTime firstTermin = map["TerminBeginn"];
    while(firstTermin.difference(DateTime.parse(dayTerminTime)) > Duration(days: 7)){
      firstTermin = firstTermin.add(Duration(days: 7));
    }

    DateTime startDate = firstTermin;
    DateTime endDate = firstTermin.add(Duration(days: 6));

    final List<Map<String, dynamic>> maps1 = await db.query( //Holt alle Termine, die den spezifizierten weekKey verwenden
      "Termine",
      where: "date(timeBegin) BETWEEN date(?) AND date(?)",
      whereArgs: [startDate, endDate],
    );
 */

/* Alternative Funktionenen zum auslesen der Durchschnittswerte für einen Tag, bzw. eine WOche
  Future<List<double>> countMeanDay(String dayKey) async {
    final db = await database;
    DateTime date = DateFormat('dd.MM.yy').parse(dayKey);
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    List<Map<String,dynamic>> maps = await db.query(
      "Termine",
      columns: [
        "SUM(goodQuestion) / COUNT(*) AS goodMean",
        "SUM(calmQuestion) / COUNT(*) AS calmMean",
        "SUM(helpQuestion) / COUNT(*) AS helpMean"
      ],
      where: "answered = 1 AND timeBegin LIKE ?",
      whereArgs: ["$formattedDate%"],
    );

    print("${maps[0]["goodMean"]}");

    int goodMean = maps[0]["goodMean"] ?? -1.0; // Standardwert -1.0, wenn null
    int calmMean = maps[0]["calmMean"] ?? -1.0;
    int helpMean = maps[0]["helpMean"] ?? -1.0;

    return [goodMean.toDouble(),calmMean.toDouble(),helpMean.toDouble()];
  }

Future<Map<String, dynamic>> getMeanForWeeks() async {
    final db = await database;
    Map<String, dynamic> meanMap = {};
    int index = 0;
    List<Termin> termine1 = await DatabaseHelper().getAllTermine();
    DateTime firstDay = termine1.first.timeBegin;
    String firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstDay); // Format for use in the query
    DateTime endDay = firstDay.add(Duration(days: 6));
    String endWeekDayString = DateFormat("yyyy-MM-dd").format(endDay);


    for (Termin t in termine1) {
      if(t.timeBegin.difference(firstDay) > Duration(days: 6)){
        List<Map<String,dynamic>> maps = await db.query(
          "Termine",
          columns: [
            "SUM(goodQuestion) / COUNT(*) AS goodMean",
            "SUM(calmQuestion) / COUNT(*) AS calmMean",
            "SUM(helpQuestion) / COUNT(*) AS helpMean"
          ],
          where: "answered = 1 AND date(timeBegin) BETWEEN date(?) AND date(?)",
          whereArgs: [firstWeekDayString, endWeekDayString],
        );

        print("-----------------$index--------------------");
        if(!meanMap.containsKey(firstWeekDayString)){
          meanMap[firstWeekDayString] = [];
        }
        meanMap[firstWeekDayString]?.add([maps.first["goodMean"],maps.first["calmMean"],maps.first["helpMean"]]);
        print("$firstWeekDayString");
        index++;
        print("---------------------------");
      }
      while (t.timeBegin.difference(firstDay) > Duration(days: 6)) {
        firstDay = firstDay.add(Duration(days: 7));
        firstWeekDayString = DateFormat("yyyy-MM-dd").format(firstDay);
        endDay = firstDay.add(Duration(days: 6));
        endWeekDayString = DateFormat("yyyy-MM-dd").format(endDay);
      }

    }
    return meanMap;
  }*/