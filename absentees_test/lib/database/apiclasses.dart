// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../database/subjectdata.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ClassesData {
//   static const _dbName = 'classesdata.db';
//   static const _dbVersion = 1;
//   static const table = 'classes';

//   // Define column names
//   static const columnId = 'id';
//   static const columnSubjectName = 'subjectName';
//   static const columnTotalClasses = 'totalClasses';
//   static const columnAbsents = 'absents';
//   static const columnCompletedClasses = 'completedClasses';

//   // Private constructor for Singleton pattern
//   ClassesData._privateConstructor();
//   static final ClassesData instance = ClassesData._privateConstructor();

//   // Database reference
//   static Database? _database;

//   // Load saved preferences (used in initState)
//   String? selectedUG;
//   int? selectedSem;
//   String? selectedBranch;
//   List<String> subjectNames = [];

//   // Instance of SubjectList
//   final SubjectList subjectList = SubjectList();

//   // Open the database
//   Future<Database> get database async {
//     if (_database != null) {
//       return _database!;
//     }
//     // If the database is null, instantiate it
//     _database = await _initDatabase();
//     return _database!;
//   }

//   // Initialize the database
//   _initDatabase() async {
//     // Get the path to the database
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, _dbName);

//     // Open the database and create the table if it doesn't exist
//     return await openDatabase(
//       path,
//       version: _dbVersion,
//       onCreate: _onCreate,
//     );
//   }

//   // Create the table if it doesn't exist
//   Future _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE $table (
//         $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
//         $columnSubjectName TEXT NOT NULL,
//         $columnTotalClasses INTEGER NOT NULL,
//         $columnAbsents INTEGER NOT NULL,
//         $columnCompletedClasses INTEGER NOT NULL
//       )
//     ''');

//     // Insert default data if the database is newly created
//     await _insertDefaultData(db);
//   }

//   // Fetch completed classes from the API
//   Future<int> fetchCompletedClasses(String subjectName) async {
//     final url =
//         'http://192.168.155.70:5000/get_completed_classes'; // Replace with your Flask API endpoint
//     final response = await http.get(Uri.parse('$url?subjectName=$subjectName'));

//     if (response.statusCode == 200) {
//       // Parse the response body to get the completed classes
//       final data = json.decode(response.body);
//       return data[
//           'completedClasses']; // Adjust based on your API response structure
//     } else {
//       throw Exception('Failed to fetch completed classes');
//     }
//   }

//   // Insert default data if the database is created
//   Future<void> _insertDefaultData(Database db) async {
//     // Wait for preferences to load
//     await loadPreferences();

//     var defaultClasses = [];

//     // Loop through subjects and fetch the completed classes
//     for (int i = 0; i < subjectNames.length; i++) {
//       String subjectName = subjectNames[i];
//       int completedClasses = await fetchCompletedClasses(subjectName);

//       var classData = {
//         'subjectName': subjectName,
//         'totalClasses': (subjectName == "FHVE" ||
//                 subjectName == "ACS" ||
//                 subjectName == "OPC")
//             ? 24
//             : 48,
//         'absents': 0,
//         'completedClasses': completedClasses,
//       };
//       defaultClasses.add(classData);
//     }

//     // Insert the fetched data into the database
//     for (var classData in defaultClasses) {
//       await db.insert(
//         table,
//         {
//           columnSubjectName: classData['subjectName'],
//           columnTotalClasses: classData['totalClasses'],
//           columnAbsents: classData['absents'],
//           columnCompletedClasses: classData['completedClasses'],
//         },
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//     }
//   }

//   // Fetch all data from the database
//   Future<List<Map<String, dynamic>>> getAllClasses() async {
//     Database db = await database;
//     return await db.query(table);
//   }

//   // Fetch a specific class data by subject name
//   Future<Map<String, dynamic>?> getClassBySubjectName(
//       String subjectName) async {
//     Database db = await database;
//     var result = await db.query(
//       table,
//       where: '$columnSubjectName = ?',
//       whereArgs: [subjectName],
//     );
//     return result.isNotEmpty ? result.first : null;
//   }

//   // Insert or update class data
//   Future<int> insertOrUpdateClassData({
//     required String subjectName,
//     required int totalClasses,
//     required int absents,
//     required int completedClasses,
//   }) async {
//     Database db = await database;

//     // Check if the subject already exists
//     var existingClass = await getClassBySubjectName(subjectName);

//     if (existingClass != null) {
//       // Update the existing record
//       return await db.update(
//         table,
//         {
//           columnSubjectName: subjectName,
//           columnTotalClasses: totalClasses,
//           columnAbsents: absents,
//           columnCompletedClasses: completedClasses,
//         },
//         where: '$columnSubjectName = ?',
//         whereArgs: [subjectName],
//       );
//     } else {
//       // Insert a new record
//       return await db.insert(
//         table,
//         {
//           columnSubjectName: subjectName,
//           columnTotalClasses: totalClasses,
//           columnAbsents: absents,
//           columnCompletedClasses: completedClasses,
//         },
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//     }
//   }

//   // Load saved preferences from SharedPreferences
//   Future<void> loadPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     selectedUG = prefs.getString('selectedUG');
//     selectedSem = prefs.getInt('selectedSem');
//     selectedBranch = prefs.getString('selectedBranch');

//     // After loading preferences, fetch the subjects if the branch and semester are selected
//     if (selectedBranch != null && selectedSem != null) {
//       subjectNames = subjectList.getSubjects(selectedBranch!, selectedSem!);
//     }
//   }

//   // Get the data of a specific row by subject name
//   Future<Map<String, dynamic>?> getClassDataBySubjectName(
//       String subjectName) async {
//     Database db = await database;
//     var result = await db.query(
//       table,
//       where: '$columnSubjectName = ?',
//       whereArgs: [subjectName],
//     );

//     // If the result is not empty, return the first record
//     if (result.isNotEmpty) {
//       return result.first;
//     } else {
//       return null; // Return null if no matching record is found
//     }
//   }
// }
