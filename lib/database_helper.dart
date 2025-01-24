import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      join(path, 'weekly_plans_test2.db'),
      onCreate: (db, version) async {
       await db.execute('''
         CREATE TABLE WeeklyPlans(
           id INTEGER PRIMARY KEY,
           weekKey TEXT UNIQUE
         )
       ''');

        await db.execute('''
          CREATE TABLE Termine(
            id INTEGER PRIMARY KEY,
            weekKey TEXT,
            terminName TEXT,
            timeBegin TEXT,
            timeEnd TEXT,
            question0 INTEGER,
            question1 INTEGER,
            question2 INTEGER,
            question3 INTEGER,
            comment TEXT,
            answered INTEGER,
            FOREIGN KEY(weekKey) REFERENCES WeeklyPlans(weekKey)
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> insertWeeklyPlan(String weekKey, List<Termin> terminItems) async {
    final db = await database;

    //Erstellt die Tabelle mit dem ersten Tag der Woche in der Tabelle WeeklyPlans. Muss angepasst oder evtl. einfach entfernt werden
    await db.insert(
      'WeeklyPlans',
      {'weekKey': weekKey},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    //Einfügen der Termine in die Tabelle, die als Key den ersten Tag der Woche hat
    for (var termin in terminItems) {
      await db.insert(
        'Termine',
        {
          'weekKey': weekKey,
          'terminName': termin.terminName,
          'timeBegin': termin.timeBegin.toIso8601String(),
          'timeEnd': termin.timeEnd.toIso8601String(),
          'question0' : termin.question0,
          'question1': termin.question1,
          'question2': termin.question2,
          'question3': termin.question3,
          'comment': termin.comment,
          'answered': termin.answered ? 1 : 0,
        }, //Druch die verschachtelung mit dem weekkey konnte ich nicht einfach die Map übertragen
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  //Gibt eine Liste mit allen Terminen in einer woche "weekKey" aus der Datenbank zurück
  Future<List<Termin>> getWeeklyPlan(String weekKey) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query( //Holt alle Termine, die den spezifizierten weekKey verwenden
      'Termine',
      where: 'weekKey = ?',
      whereArgs: [weekKey],
    );

    // Konvertiert die Liste an Maps in Termin-Objekte und gibt diese zurück
    return List.generate(maps.length, (i) {
      return Termin(
        terminName: maps[i]['terminName'],
        timeBegin: DateTime.parse(maps[i]['timeBegin']),
        timeEnd: DateTime.parse(maps[i]['timeEnd']),
        question0: maps[i]['question0'],
        question1: maps[i]['question1'],
        question2: maps[i]['question2'],
        question3: maps[i]['question3'],
        comment: maps[i]['comment'],
        answered: maps[i]['answered'] == 1,
      );
    });
  }

  //Gibt eine Liste mit allen weekKeys in der Datenbank zurück
  Future<List<Map<String, dynamic>>> getAllWeekPlans() async {
    final db = await database;
    return await db.query('WeeklyPlans');
  }

  //Gibt einen einzelnen bestimmten Termin zurück, der über weekKey, timeBegin und terminName identifiziert wird (sollte keine überschneidungen geben)
  Future<Termin?> getSpecificTermin(String weekKey, String timeBegin, String terminName) async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'Termine',
      where: 'weekKey = ? AND timeBegin = ? AND terminName = ?' ,
      whereArgs: [weekKey, timeBegin, terminName],
    );
    if(results.length == 1){
      return Termin(
          terminName: results.first['terminName'],
          timeBegin: DateTime.parse(results.first['timeBegin']),
          timeEnd: DateTime.parse(results.first['timeEnd']),
          question0: results.first['question0'],
          question1: results.first['question1'],
          question2: results.first['question2'],
          question3: results.first['question3'],
          comment: results.first['comment'],
          answered: results.first['answered'] == 1,
      );
    }
    if(results.length > 1) {
      //print("Found more than 1 entry"); TODO: Testing
      return null;
    }
      return null;
  }

  //Updated einen Termineintrag in der Datenbank
  Future<void> updateEntry(String weekKey, String timeBegin, String terminName, Map<String, dynamic> updatedValues) async {
    final db = await database;

    await db.update(
      'Termine',
      updatedValues,
      where: 'weekKey = ? AND timeBegin = ? AND terminName = ?',
      whereArgs: [weekKey, timeBegin, terminName],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //löscht eine Woche weekKey aus der Datenbank
  Future<void> dropTable(String weekKey) async {
    Database db = await database;

    await db.execute('DELETE FROM WeeklyPlans WHERE weekKey = ?', [weekKey]); //einträge Müssen aus der Liste der Wochen
    await db.execute('DELETE FROM Termine WHERE weekKey = ?', [weekKey]);     //und aus der Liste der Termine entfernt werden. Wird noch überarbeitet
  }
}
