import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/subjectdata.dart';

class ClassesData {
  static const _dbName = 'classesdata.db';
  static const _dbVersion = 1;
  static const table = 'classes';

  // Define column names
  static const columnId = 'id';
  static const columnSubjectName = 'subjectName';
  static const columnTotalClasses = 'totalClasses';
  static const columnAbsents = 'absents';

  // Private constructor for Singleton pattern
  ClassesData._privateConstructor();
  static final ClassesData instance = ClassesData._privateConstructor();

  // Database reference
  static Database? _database;

  // Load saved preferences (used in initState)
  String? selectedUG;
  int? selectedSem;
  String? selectedBranch;
  List<String> subjectNames = [];

  // Instance of SubjectList
  final SubjectList subjectList = SubjectList();

  // Open the database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    // If the database is null, instantiate it
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  _initDatabase() async {
    // Get the path to the database
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    // Open the database and create the table if it doesn't exist
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  // Create the table if it doesn't exist
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnSubjectName TEXT NOT NULL,
        $columnTotalClasses INTEGER NOT NULL,
        $columnAbsents INTEGER NOT NULL
      )
    ''');

    // Insert default data if the database is newly created
    await _insertDefaultData(db);
  }

  // Insert default data if the database is created
  Future<void> _insertDefaultData(Database db) async {
    // Wait for preferences to load
    await loadPreferences();

    var defaultClasses = [
      {
        'subjectName': subjectNames.isNotEmpty ? subjectNames[0] : 'Subject 1',
        'totalClasses': 48,
        'absents': 0
      },
      {
        'subjectName': subjectNames.length > 1 ? subjectNames[1] : 'Subject 2',
        'totalClasses': 48,
        'absents': 0
      },
      {
        'subjectName': subjectNames.length > 2 ? subjectNames[2] : 'Subject 3',
        'totalClasses': 48,
        'absents': 0
      },
      {
        'subjectName': subjectNames.length > 3 ? subjectNames[3] : 'Subject 4',
        'totalClasses': 48,
        'absents': 0
      },
      {
        'subjectName': subjectNames.length > 4 ? subjectNames[4] : 'Subject 5',
        'totalClasses': (subjectNames[4] == "FHVE" ||
                subjectNames[4] == "ACS" ||
                subjectNames[4] == "OPC")
            ? 24
            : 48,
        'absents': 0
      },
      {
        'subjectName': subjectNames.length > 5 ? subjectNames[5] : 'Subject 6',
        'totalClasses': 24,
        'absents': 0
      },
    ];

    // Insert default data into the table
    for (var classData in defaultClasses) {
      await db.insert(
        table,
        {
          columnSubjectName: classData['subjectName'],
          columnTotalClasses: classData['totalClasses'],
          columnAbsents: classData['absents']
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Fetch all data from the database
  Future<List<Map<String, dynamic>>> getAllClasses() async {
    Database db = await database;
    return await db.query(table);
  }

  // Fetch a specific class data by subject name
  Future<Map<String, dynamic>?> getClassBySubjectName(
      String subjectName) async {
    Database db = await database;
    var result = await db.query(
      table,
      where: '$columnSubjectName = ?',
      whereArgs: [subjectName],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Insert or update class data
  Future<int> insertOrUpdateClassData({
    required String subjectName,
    required int totalClasses,
    required int absents,
    required int completedClasses,
  }) async {
    Database db = await database;

    // Check if the subject already exists
    var existingClass = await getClassBySubjectName(subjectName);

    if (existingClass != null) {
      // Update the existing record
      return await db.update(
        table,
        {
          columnSubjectName: subjectName,
          columnTotalClasses: totalClasses,
          columnAbsents: absents
        },
        where: '$columnSubjectName = ?',
        whereArgs: [subjectName],
      );
    } else {
      // Insert a new record
      return await db.insert(
        table,
        {
          columnSubjectName: subjectName,
          columnTotalClasses: totalClasses,
          columnAbsents: absents
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Load saved preferences from SharedPreferences
  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedUG = prefs.getString('selectedUG');
    selectedSem = prefs.getInt('selectedSem');
    selectedBranch = prefs.getString('selectedBranch');

    // After loading preferences, fetch the subjects if the branch and semester are selected
    if (selectedBranch != null && selectedSem != null) {
      subjectNames = subjectList.getSubjects(selectedBranch!, selectedSem!);
    }
  }

  // Get the data of a specific row by subject name
  Future<Map<String, dynamic>?> getClassDataBySubjectName(
      String subjectName) async {
    Database db = await database;
    var result = await db.query(
      table,
      where: '$columnSubjectName = ?',
      whereArgs: [subjectName],
    );

    // If the result is not empty, return the first record
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null; // Return null if no matching record is found
    }
  }
}
