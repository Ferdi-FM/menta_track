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
      join(path, 'weekly_plans_test1.db'),
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
      print(termin.toString());
      await db.insert(
        'Termine',
        {
          'weekKey': weekKey,
          'terminName': termin.terminName,
          'timeBegin': termin.timeBegin.toIso8601String(),
          'timeEnd': termin.timeEnd.toIso8601String(),
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
        question1: maps[i]['question1'],
        question2: maps[i]['question2'],
        question3: maps[i]['question3'],
        comment: maps[i]['comment'],
        answered: maps[i]['answered'] == 1,
      );
    });
  }

  Future<List<Map<String, dynamic>>> getAllWeekPlans() async {
    final db = await database;
    return await db.query('WeeklyPlans');
  }

  Future<void> dropTable(String weekKey) async {
    Database db = await database;

    await db.execute('DELETE FROM WeeklyPlans WHERE weekKey = ?', [weekKey]); //einträge Müssen aus der Liste der Wochen
    await db.execute('DELETE FROM Termine WHERE weekKey = ?', [weekKey]);     //und aus der Liste der Termine entfernt werden. Wird noch überarbeitet
  }
}
