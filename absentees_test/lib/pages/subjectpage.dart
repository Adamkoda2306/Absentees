import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pie_chart/pie_chart.dart';
import '../database/classesdata.dart';
import '../models/actionhistorymodel.dart';
import 'actionhistory.dart';

class SubjectPage extends StatefulWidget {
  final String subjectName;

  const SubjectPage({super.key, required this.subjectName});

  @override
  State<SubjectPage> createState() => _SubjectpageState();
}

class _SubjectpageState extends State<SubjectPage> {
  int? completedClasses;
  int? absent;
  int? totalClasses;
  Map<String, dynamic>? classData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchClassData();
  }

  // Fetch the class data asynchronously in initState
  Future<void> _fetchClassData() async {
    classData = await ClassesData.instance
        .getClassDataBySubjectName(widget.subjectName);

    if (classData != null) {
      setState(() {
        completedClasses = classData!['completedClasses'];
        absent = classData!['absents'];
        totalClasses = classData!['totalClasses'];
      });

      // You can log the class data for debugging
      print("Subject: ${classData!['subjectName']}");
      print("Total Classes: ${classData!['totalClasses']}");
      print("Absents: ${classData!['absents']}");
      print("Completed Classes: ${classData!['completedClasses']}");
    } else {
      print("Subject not found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    //Adjusting the status bar color
    final brightness = MediaQuery.of(context).platformBrightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent status bar
        statusBarIconBrightness: (brightness == Brightness.dark)
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color inversePrimaryColor =
        Theme.of(context).colorScheme.inversePrimary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(
            child: Text(
          widget.subjectName,
          style: TextStyle(color: inversePrimaryColor),
        )),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: inversePrimaryColor),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AttendanceHistory(subjectName: widget.subjectName),
                ),
              ).then((_) {
                // Refresh the class data after returning from the history page
                _fetchClassData();
              });
              // After returning from the history page, refresh the class data
              _fetchClassData();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: inversePrimaryColor,
                  ),
                ),
                child: PieChart(
                  dataMap: {
                    "Present": (completedClasses != null && absent != null)
                        ? (completedClasses! - absent!).toDouble()
                        : 0.0,
                    "Absent": absent!.toDouble(),
                    "Remaining Class":
                        (totalClasses != null && completedClasses != null)
                            ? (totalClasses! - completedClasses!).toDouble()
                            : 0.0,
                  },
                  colorList: const [
                    Colors.green,
                    Colors.red,
                    Colors.grey,
                  ],
                  chartRadius: MediaQuery.of(context).size.width * 1.5,
                  initialAngleInDegree: 0,
                  chartType: ChartType.disc,
                  ringStrokeWidth: 32,
                  centerText: "Attendance",
                  legendOptions: const LegendOptions(
                    showLegends: false,
                    legendPosition: LegendPosition.right,
                  ),
                  chartValuesOptions: const ChartValuesOptions(
                    // showChartValueBackground: false,
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  children: [
                    const SizedBox(width: 5),
                    Container(
                      height: 150,
                      width: 150,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: inversePrimaryColor,
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            "Completed\n Classes: ${completedClasses!}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: inversePrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Present: ${completedClasses! - absent!}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Absent: ${absent!}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      height: 150,
                      width: 150,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: inversePrimaryColor,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Absent",
                                  style: TextStyle(
                                    color: inversePrimaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold, // Bold text
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Present",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: inversePrimaryColor,
                                    fontWeight: FontWeight.bold, // Bold text
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8, height: 5),
                                Text(
                                  "Remaining \nclasses",
                                  style: TextStyle(
                                    color: inversePrimaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold, // Bold text
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Buttons for Actions
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton('Added Absent', Icons.close),
                    ],
                  ),
                  const SizedBox(height: 16), // Space between buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton('Added Extra Class', Icons.add),
                    ],
                  ),
                  const SizedBox(height: 16), // Space between buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton('Added Canceled Class', Icons.cancel),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String title, IconData icon) {
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color inversePrimaryColor =
        Theme.of(context).colorScheme.inversePrimary;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 230, // Ensures all buttons have the same width
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: TextStyle(
            color: inversePrimaryColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        onPressed: () {
          // Show a dialog with a note input field
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController noteController = TextEditingController();

              return AlertDialog(
                backgroundColor:
                    const Color(0xFFE3F2FD), // Light blue background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontFamily: 'Roboto',
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: "Add a note",
                        labelStyle: TextStyle(color: Colors.blue),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red), // Red Cancel button
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Green Confirm button
                    ),
                    onPressed: () async {
                      try {
                        String note = noteController.text;

                        // Determine the action and call the respective FunctionModel method
                        if (title == 'Added Absent') {
                          await FunctionModel.instance.addAbsent(
                              widget.subjectName,
                              completedClasses ?? 0,
                              absent ?? 0,
                              note);
                        } else if (title == 'Added Extra Class') {
                          await FunctionModel.instance.addExtraClass(
                              widget.subjectName,
                              totalClasses ?? 0,
                              completedClasses ?? 0,
                              note);
                        } else if (title == 'Added Canceled Class') {
                          await FunctionModel.instance.cancelClass(
                              widget.subjectName, totalClasses ?? 0, note);
                        }

                        // Show a success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Updated Successfully!!",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        Navigator.of(context).pop();

                        // Refresh data
                        await _fetchClassData();
                      } catch (e) {
                        // Show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Error: $e",
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
