import 'dart:developer'; // Import the log framework
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'marks.db');
    return await openDatabase(
      path,
      version: 2, // Incremented version number
      onCreate: (db, version) async {
        // Create Marks table with featureName and featureMarks
        await db.execute('''
          CREATE TABLE Marks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subjectName TEXT,
            featureName TEXT,
            featureMarks INTEGER
          )
        ''');
        log('Database created with table Marks', name: 'DBHelper');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Handle schema upgrade if needed (i.e., add featureName column)
          await db.execute('''
            ALTER TABLE Marks ADD COLUMN featureName TEXT;
          ''');
          log('Database upgraded to version $newVersion', name: 'DBHelper');
        }
      },
    );
  }

  // Insert a new subject with its feature marks
  Future<int> insertSubjectWithFeature(
      String subjectName, String featureName, int featureMarks) async {
    final db = await database;
    int id = await db.insert('Marks', {
      'subjectName': subjectName,
      'featureName': featureName,
      'featureMarks': featureMarks,
    });
    log("Data Added: ID=$id, Subject=$subjectName, Feature=$featureName, Marks=$featureMarks",
        name: 'DBHelper');
    return id;
  }

  // Get all marks data
  Future<List<Map<String, dynamic>>> getMarks() async {
    final db = await database;
    List<Map<String, dynamic>> marks = await db.query('Marks');
    log('Fetched marks data: ${marks.length} entries', name: 'DBHelper');
    return marks;
  }

  // Update the feature marks of a specific entry
  Future<int> updateFeature(int id, Map<String, dynamic> data) async {
    final db = await database;
    int rowsAffected =
        await db.update('Marks', data, where: 'id = ?', whereArgs: [id]);
    log('Updated entry ID=$id with data=$data', name: 'DBHelper');
    return rowsAffected;
  }

  // Delete a mark entry
  Future<int> deleteMark(int id) async {
    final db = await database;
    int rowsDeleted =
        await db.delete('Marks', where: 'id = ?', whereArgs: [id]);
    log('Deleted entry ID=$id', name: 'DBHelper');
    return rowsDeleted;
  }
}
