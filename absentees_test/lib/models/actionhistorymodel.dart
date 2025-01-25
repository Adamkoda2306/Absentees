import 'dart:developer'; // Import the log framework
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../database/classesdata.dart';

class FunctionModel {
  static final FunctionModel instance = FunctionModel._init();
  static Database? _database;

  FunctionModel._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('action_history.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE actionHistory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            note TEXT,
            subjectName TEXT NOT NULL
          );
        ''');
        log('Database created with table actionHistory', name: 'FunctionModel');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS actionHistory (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              action TEXT NOT NULL,
              date TEXT NOT NULL,
              time TEXT NOT NULL,
              note TEXT,
              subjectName TEXT NOT NULL
            );
          ''');
          log('Database upgraded to version $newVersion',
              name: 'FunctionModel');
        }
      },
    );
  }

  Future<void> recordAction(
      String action, String subjectName, String note) async {
    final db = await instance.database;
    final now = DateTime.now();

    await db.insert('actionHistory', {
      'action': action,
      'date': '${now.year}-${now.month}-${now.day}',
      'time': '${now.hour}:${now.minute}',
      'note': note,
      'subjectName': subjectName,
    });
    log('Recorded action: $action for subject: $subjectName with note: $note',
        name: 'FunctionModel');
  }

  Future<void> addAbsent(String subjectName, int absent, String note) async {
    final db = await ClassesData.instance.database;

    if (absent >= 0) {
      await db.update(
        ClassesData.table,
        {
          ClassesData.columnAbsents: absent + 1,
        },
        where: '${ClassesData.columnSubjectName} = ?',
        whereArgs: [subjectName],
      );
      await recordAction('Absent Added', subjectName, note);
    } else {
      log("Attempted to add negative absent count", name: 'FunctionModel');
    }
  }

  Future<void> cancelClass(
      String subjectName, int totalClasses, String note) async {
    final db = await ClassesData.instance.database;

    if (totalClasses > 0) {
      await db.update(
        ClassesData.table,
        {
          ClassesData.columnTotalClasses: totalClasses - 1,
        },
        where: '${ClassesData.columnSubjectName} = ?',
        whereArgs: [subjectName],
      );
      await recordAction('Class Cancelled', subjectName, note);
    } else {
      log("Attempted to cancel class when totalClasses is zero or negative",
          name: 'FunctionModel');
    }
  }

  Future<void> addExtraClass(
      String subjectName, int totalClasses, String note) async {
    final db = await ClassesData.instance.database;

    await db.update(
      ClassesData.table,
      {
        ClassesData.columnTotalClasses: totalClasses + 1,
      },
      where: '${ClassesData.columnSubjectName} = ?',
      whereArgs: [subjectName],
    );

    await recordAction('Extra Class Added', subjectName, note);
    log('Added extra class for subject: $subjectName', name: 'FunctionModel');
  }

  Future<List<Map<String, dynamic>>> getActionHistory(
      String subjectName) async {
    final db = await instance.database;
    final result = await db.query(
      'actionHistory',
      where: 'subjectName = ?',
      whereArgs: [subjectName],
      orderBy: 'id DESC',
    );
    log('Fetched action history for subject: $subjectName with ${result.length} entries',
        name: 'FunctionModel');
    return result;
  }

  Future<void> undoAction(
      int actionId, String action, String subjectName) async {
    final db = await ClassesData.instance.database;

    final subject = await db.query(
      ClassesData.table,
      where: '${ClassesData.columnSubjectName} = ?',
      whereArgs: [subjectName],
    );

    if (subject.isNotEmpty) {
      if (action == 'Absent Added') {
        int absents = subject.first[ClassesData.columnAbsents] as int;
        if (absents > 0) {
          await db.update(
            ClassesData.table,
            {ClassesData.columnAbsents: absents - 1},
            where: '${ClassesData.columnSubjectName} = ?',
            whereArgs: [subjectName],
          );
        } else {
          log("Cannot undo absent action, absents are already zero",
              name: 'FunctionModel');
        }
      } else if (action == 'Class Cancelled') {
        int totalClasses = subject.first[ClassesData.columnTotalClasses] as int;
        await db.update(
          ClassesData.table,
          {ClassesData.columnTotalClasses: totalClasses + 1},
          where: '${ClassesData.columnSubjectName} = ?',
          whereArgs: [subjectName],
        );
      } else if (action == 'Extra Class Added') {
        int totalClasses = subject.first[ClassesData.columnTotalClasses] as int;
        if (totalClasses > 0) {
          await db.update(
            ClassesData.table,
            {
              ClassesData.columnTotalClasses: totalClasses - 1,
            },
            where: '${ClassesData.columnSubjectName} = ?',
            whereArgs: [subjectName],
          );
        } else {
          log("Cannot undo extra class, values are already at zero",
              name: 'FunctionModel');
        }
      }
    } else {
      log("Subject not found in database for $subjectName",
          name: 'FunctionModel');
    }

    final dbInstance = await instance.database;
    await dbInstance.delete(
      'actionHistory',
      where: 'id = ?',
      whereArgs: [actionId],
    );
    log('Deleted action with ID: $actionId', name: 'FunctionModel');
  }

  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
      log('Database connection closed', name: 'FunctionModel');
    }
  }
}
