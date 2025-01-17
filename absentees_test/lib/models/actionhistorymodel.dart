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
      version: 2, // Incremented version to trigger onCreate or onUpgrade
      onCreate: (db, version) async {
        // Create table for actionHistory
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle upgrade to version 2
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
  }

  Future<void> addAbsent(
      String subjectName, int completedClasses, int absent, String note) async {
    final db =
        await ClassesData.instance.database; // Access ClassesData database

    if (absent > 0) {
      await db.update(
        ClassesData.table, // Use the ClassesData table
        {
          ClassesData.columnAbsents: absent + 1,
        },
        where: '${ClassesData.columnSubjectName} = ?',
        whereArgs: [subjectName],
      );
      await recordAction('Absent Added', subjectName, note);
    } else {
      // Avoid negative absents
      print("Absent count cannot be negative");
    }
  }

  Future<void> cancelClass(
      String subjectName, int totalClasses, String note) async {
    final db =
        await ClassesData.instance.database; // Access ClassesData database

    if (totalClasses > 0) {
      await db.update(
        ClassesData.table, // Use the ClassesData table
        {
          ClassesData.columnTotalClasses: totalClasses - 1,
        },
        where: '${ClassesData.columnSubjectName} = ?',
        whereArgs: [subjectName],
      );
      await recordAction('Class Cancelled', subjectName, note);
    } else {
      // Avoid negative totalClasses
      print("Total classes cannot be negative");
    }
  }

  Future<void> addExtraClass(String subjectName, int totalClasses,
      int completedClasses, String note) async {
    final db =
        await ClassesData.instance.database; // Access ClassesData database

    await db.update(
      ClassesData.table, // Use the ClassesData table
      {
        ClassesData.columnTotalClasses: totalClasses + 1,
        ClassesData.columnCompletedClasses: completedClasses + 1,
      },
      where: '${ClassesData.columnSubjectName} = ?',
      whereArgs: [subjectName],
    );

    await recordAction('Extra Class Added', subjectName, note);
  }

  Future<List<Map<String, dynamic>>> getActionHistory(
      String subjectName) async {
    final db = await instance.database;
    return await db.query(
      'actionHistory',
      where: 'subjectName = ?',
      whereArgs: [subjectName],
      orderBy: 'id DESC',
    );
  }

  Future<void> undoAction(
      int actionId, String action, String subjectName) async {
    final db =
        await ClassesData.instance.database; // Access ClassesData database

    // Fetch the subject data to ensure it exists before undoing any action
    final subject = await db.query(
      ClassesData.table,
      where: '${ClassesData.columnSubjectName} = ?',
      whereArgs: [subjectName],
    );

    if (subject.isNotEmpty) {
      if (action == 'Absent Added') {
        // Undo 'Absent Added' by decrementing the absents count
        int absents = subject.first[ClassesData.columnAbsents] as int;
        if (absents > 0) {
          await db.update(
            ClassesData.table,
            {ClassesData.columnAbsents: absents - 1},
            where: '${ClassesData.columnSubjectName} = ?',
            whereArgs: [subjectName],
          );
        } else {
          // Prevent absents from going negative
          print("Cannot undo absent action, absents are already zero");
        }
      } else if (action == 'Class Cancelled') {
        // Undo 'Class Cancelled' by incrementing the totalClasses count
        int totalClasses = subject.first[ClassesData.columnTotalClasses] as int;
        await db.update(
          ClassesData.table,
          {ClassesData.columnTotalClasses: totalClasses + 1},
          where: '${ClassesData.columnSubjectName} = ?',
          whereArgs: [subjectName],
        );
      } else if (action == 'Extra Class Added') {
        // Undo 'Extra Class Added' by decrementing both totalClasses and completedClasses
        int totalClasses = subject.first[ClassesData.columnTotalClasses] as int;
        int completedClasses =
            subject.first[ClassesData.columnCompletedClasses] as int;
        if (totalClasses > 0 && completedClasses > 0) {
          await db.update(
            ClassesData.table,
            {
              ClassesData.columnTotalClasses: totalClasses - 1,
              ClassesData.columnCompletedClasses: completedClasses - 1,
            },
            where: '${ClassesData.columnSubjectName} = ?',
            whereArgs: [subjectName],
          );
        } else {
          print("Cannot undo extra class, values are already at zero");
        }
      }
    } else {
      // Log or handle the case where the subject was not found
      print("Subject not found in database for $subjectName.");
    }

    // Delete the action from actionHistory
    final dbInstance = await instance.database;
    await dbInstance.delete(
      'actionHistory',
      where: 'id = ?',
      whereArgs: [actionId],
    );
  }

  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
    }
  }
}
