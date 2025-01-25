// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/subjectdata.dart';
import '../database/classesdata.dart';
import '../library/bargraph.dart';
import '../library/graphmodel.dart';

class Attendancereport extends StatefulWidget {
  const Attendancereport({super.key});

  @override
  State<Attendancereport> createState() => _AttendancereportState();
}

class _AttendancereportState extends State<Attendancereport> {
  String? selectedUG;
  int? selectedSem;
  String? selectedBranch;
  List<String> subjectNames = [];
  Map<String, dynamic>? Sub1ClassData;
  Map<String, dynamic>? Sub2ClassData;
  Map<String, dynamic>? Sub3ClassData;
  Map<String, dynamic>? Sub4ClassData;
  Map<String, dynamic>? Sub5ClassData;
  Map<String, dynamic>? Sub6ClassData;

  final SubjectList subjectList =
      SubjectList(); // Create an instance of SubjectList

  @override
  void initState() {
    super.initState();
    _loadSelection();
  }

  // Load saved values from SharedPreferences
  _loadSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedUG = prefs.getString('selectedUG');
      selectedSem = prefs.getInt('selectedSem');
      selectedBranch = prefs.getString('selectedBranch');
    });

    // After loading preferences, fetch the subjects
    if (selectedBranch != null && selectedSem != null) {
      subjectNames = subjectList.getSubjects(selectedBranch!, selectedSem!);

      // Fetch class data for each subject
      await _fetchClassData();
    }
  }

  // Fetch class data for each subject
  _fetchClassData() async {
    // Fetch class data for each subject dynamically
    for (String subject in subjectNames) {
      Map<String, dynamic>? subjectData =
          await ClassesData.instance.getClassBySubjectName(subject);

      setState(() {
        if (subject == subjectNames[0]) {
          Sub1ClassData = subjectData;
        } else if (subject == subjectNames[1]) {
          Sub2ClassData = subjectData;
        } else if (subject == subjectNames[2]) {
          Sub3ClassData = subjectData;
        } else if (subject == subjectNames[3]) {
          Sub4ClassData = subjectData;
        } else if (subject == subjectNames[4]) {
          Sub5ClassData = subjectData;
        } else if (subject == subjectNames[5]) {
          Sub6ClassData = subjectData;
        }
      });
    }
  }

  // Create the data for the bar chart using bar_graph
  List<GraphModel> _createBarGraphData() {
    List<GraphModel> data = [];

    if (Sub1ClassData != null) {
      data.add(GraphModel(
        valueData:
            (((Sub1ClassData!['totalClasses'] - Sub1ClassData!['absents']) /
                        Sub1ClassData!['totalClasses']) *
                    100)
                .toDouble(),
        dateData: subjectNames[0],
        colorData: Colors.blue,
      ));
    }

    if (Sub2ClassData != null) {
      data.add(GraphModel(
        valueData:
            (((Sub2ClassData!['totalClasses'] - Sub2ClassData!['absents']) /
                        Sub2ClassData!['totalClasses']) *
                    100)
                .toDouble(),
        dateData: subjectNames[1],
        colorData: Colors.blue,
      ));
    }

    if (Sub3ClassData != null) {
      data.add(GraphModel(
        valueData:
            (((Sub3ClassData!['totalClasses'] - Sub3ClassData!['absents']) /
                        Sub3ClassData!['totalClasses']) *
                    100)
                .toDouble(),
        dateData: subjectNames[2],
        colorData: Colors.blue,
      ));
    }

    if (Sub4ClassData != null) {
      data.add(GraphModel(
        valueData:
            (((Sub4ClassData!['totalClasses'] - Sub4ClassData!['absents']) /
                        Sub4ClassData!['totalClasses']) *
                    100)
                .toDouble(),
        dateData: subjectNames[3],
        colorData: Colors.blue,
      ));
    }

    if (Sub5ClassData != null) {
      data.add(GraphModel(
        valueData:
            (((Sub5ClassData!['totalClasses'] - Sub5ClassData!['absents']) /
                        Sub5ClassData!['totalClasses']) *
                    100)
                .toDouble(),
        dateData: subjectNames[4],
        colorData: Colors.blue,
      ));
    }

    if (Sub6ClassData != null) {
      data.add(GraphModel(
        valueData:
            (((Sub6ClassData!['totalClasses'] - Sub6ClassData!['absents']) /
                        Sub6ClassData!['totalClasses']) *
                    100)
                .toDouble(),
        dateData: 'SEED',
        colorData: Colors.blue,
      ));
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = Theme.of(context).colorScheme.surface;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color inversePrimaryColor =
        Theme.of(context).colorScheme.inversePrimary;
    double largestData = 0;
    List<GraphModel> graphData = _createBarGraphData();
    for (var data in graphData) {
      if (data.valueData > largestData) {
        largestData = data.valueData; // Keep it as double
      }
    }
    return Scaffold(
      backgroundColor: surfaceColor, // Light gray background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Attendance Report",
          style: TextStyle(
            color: inversePrimaryColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 45),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text(
                "Overview:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: inversePrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bar Graph Display using bar_graph
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: inversePrimaryColor,
                    ),
                  ),
                  child: Center(
                    child: BarGraph(
                      graphData: graphData,
                      largestValue: 100.0,
                      backgroundColor: Colors.transparent,
                      textColor: secondaryColor,
                      graphHeight: 300.0,
                      graphWidth: 250.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Footer Text
            const Center(
              child: Text(
                "Keep up the Good work!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
