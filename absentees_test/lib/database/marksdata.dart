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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Handle schema upgrade if needed (i.e., add featureName column)
          await db.execute('''
            ALTER TABLE Marks ADD COLUMN featureName TEXT;
          ''');
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
    print(
        "Data Added: ID=$id, Subject=$subjectName, Feature=$featureName, Marks=$featureMarks");
    return id;
  }

  // Get all marks data
  Future<List<Map<String, dynamic>>> getMarks() async {
    final db = await database;
    return await db.query('Marks');
  }

  // Update the feature marks of a specific entry
  Future<int> updateFeature(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('Marks', data, where: 'id = ?', whereArgs: [id]);
  }

  // Delete a mark entry
  Future<int> deleteMark(int id) async {
    final db = await database;
    return await db.delete('Marks', where: 'id = ?', whereArgs: [id]);
  }
}
