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
  int? absent;
  int? totalClasses;
  Map<String, dynamic>? classData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchClassData();
  }

  Future<void> _fetchClassData() async {
    classData = await ClassesData.instance
        .getClassDataBySubjectName(widget.subjectName);

    if (classData != null) {
      setState(() {
        absent = classData!['absents'];
        totalClasses = classData!['totalClasses'];
      });
    } else {
      print("Subject not found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
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
          ),
        ),
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
                _fetchClassData();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: classData == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: inversePrimaryColor),
                      ),
                      child: PieChart(
                        dataMap: {
                          "Absent": absent?.toDouble() ?? 0,
                          "Remaining Class":
                              (totalClasses ?? 0) - (absent ?? 0).toDouble(),
                        },
                        colorList: const [Colors.red, Colors.grey],
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
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 25),
                                  Text(
                                    "Expected : ${totalClasses!}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: inversePrimaryColor,
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
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Container(
                                        height: 16,
                                        width: 16,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Absent",
                                        style: TextStyle(
                                          color: inversePrimaryColor,
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.bold, // Bold text
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Container(
                                        height: 16,
                                        width: 16,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8, height: 5),
                                      Text(
                                        "Expected\n Count\n(inc. labs)",
                                        style: TextStyle(
                                          color: inversePrimaryColor,
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.bold, // Bold text
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
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _actionButton(
                                'Missed a Class', Icons.text_format_rounded)
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _actionButton(
                                'Scheduled Extra Class', Icons.add_circle)
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _actionButton('Class Cancelled', Icons.cancel)
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
        minWidth: 230,
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
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController noteController = TextEditingController();
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    color: inversePrimaryColor,
                    fontFamily: 'Roboto',
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: "Add a note (optional)",
                        labelStyle: TextStyle(color: inversePrimaryColor),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: inversePrimaryColor),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: inversePrimaryColor),
                        ),
                      ),
                      style: TextStyle(
                        color: inversePrimaryColor,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      try {
                        String note = noteController.text;
                        if (title == 'Missed a Class') {
                          await FunctionModel.instance
                              .addAbsent(widget.subjectName, absent ?? 0, note);
                        } else if (title == 'Scheduled Extra Class') {
                          await FunctionModel.instance.addExtraClass(
                              widget.subjectName, totalClasses ?? 0, note);
                        } else if (title == 'Class Cancelled') {
                          await FunctionModel.instance.cancelClass(
                              widget.subjectName, totalClasses ?? 0, note);
                        }

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
                        await _fetchClassData();
                      } catch (e) {
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
