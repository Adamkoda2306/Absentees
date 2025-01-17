import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/marksdata.dart';
import '../database/subjectdata.dart';

class Marksmemo extends StatefulWidget {
  const Marksmemo({super.key});

  @override
  State<Marksmemo> createState() => _MarksMemoState();
}

class _MarksMemoState extends State<Marksmemo> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _marks = [];
  String? selectedUG;
  int? selectedSem;
  String? selectedBranch;
  String? selectedSubject; // Track selected subject
  List<String> subjectNames = []; // List of available subjects

  final SubjectList subjectList = SubjectList();

  @override
  void initState() {
    super.initState();
    _loadSelection();
    _fetchMarks();
  }

  // Load saved values from SharedPreferences
  _loadSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedUG = prefs.getString('selectedUG');
      selectedSem = prefs.getInt('selectedSem');
      selectedBranch = prefs.getString('selectedBranch');
    });

    if (selectedBranch != null && selectedSem != null) {
      subjectNames = subjectList.getSubjects(selectedBranch!, selectedSem!);
    }
  }

  void _fetchMarks() async {
    final data = await _dbHelper.getMarks();
    setState(() {
      _marks = data;
    });
  }

  void _showPopup({Map<String, dynamic>? mark}) {
    final TextEditingController featureNameController =
        TextEditingController(text: mark != null ? mark['featureName'] : '');
    final TextEditingController featureMarksController = TextEditingController(
        text: mark != null ? mark['featureMarks'].toString() : '');

    showDialog(
      context: context,
      builder: (ctx) {
        final Color secondaryColor = Theme.of(context).colorScheme.secondary;
        final Color primaryColor = Theme.of(context).colorScheme.primary;
        final Color inversePrimaryColor =
            Theme.of(context).colorScheme.inversePrimary;
        return AlertDialog(
          title: Text(
            mark != null ? 'Edit Feature Marks' : 'Add Subject',
            style: TextStyle(
              color: inversePrimaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown to select subject
                DropdownButton<String>(
                  dropdownColor: primaryColor,
                  value: selectedSubject, // Bind the value to selectedSubject
                  hint: Text(
                    'Select Subject',
                    style: TextStyle(
                      color: inversePrimaryColor,
                    ),
                  ),
                  items: subjectNames.map((String subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(
                        subject,
                        style: TextStyle(
                          color: inversePrimaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newSubject) {
                    setState(() {
                      selectedSubject = newSubject;
                      print('Subject Selected: $selectedSubject');
                    });
                    Navigator.of(ctx)
                        .pop(); // Close the dialog immediately after selection
                    _showPopup(
                        mark:
                            mark); // Reopen the dialog to reflect the updated state
                  },
                ),
                TextField(
                  controller: featureNameController,
                  decoration: InputDecoration(
                    labelText: 'Feature Name',
                    labelStyle: TextStyle(
                      color: inversePrimaryColor,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            inversePrimaryColor, // Bottom line color when not focused
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: inversePrimaryColor
                            .withOpacity(0.6), // Bottom line color when focused
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: inversePrimaryColor,
                  ),
                ),
                TextField(
                  controller: featureMarksController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Feature Marks',
                    labelStyle: TextStyle(
                      color: inversePrimaryColor,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            inversePrimaryColor, // Bottom line color when not focused
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: inversePrimaryColor
                            .withOpacity(0.6), // Bottom line color when focused
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: inversePrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                selectedSubject = null;
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: inversePrimaryColor,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    secondaryColor, // Use secondary color for the button
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(24), // Optional: rounded corners
                ),
              ),
              onPressed: () async {
                final String featureName = featureNameController.text;
                final int featureMarks =
                    int.tryParse(featureMarksController.text) ?? 0;

                if (selectedSubject != null && featureName.isNotEmpty) {
                  if (mark == null) {
                    // Insert new subject with the provided feature and marks
                    int id = await _dbHelper.insertSubjectWithFeature(
                        selectedSubject!, featureName, featureMarks);
                    print('Inserted ID: $id');
                  } else {
                    // Update existing feature marks
                    await _dbHelper.updateFeature(mark['id'], {
                      'featureName': featureName,
                      'featureMarks': featureMarks,
                    });
                  }
                  _fetchMarks(); // Refresh data after saving
                  Navigator.of(ctx).pop();
                  selectedSubject = null;
                }
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: inversePrimaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteMark(int id) async {
    await _dbHelper.deleteMark(id);
    _fetchMarks();
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

    final Color surfaceColor = Theme.of(context).colorScheme.surface;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color inversePrimaryColor =
        Theme.of(context).colorScheme.inversePrimary;
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(
            child: Text(
          'Marks Memo',
          style: TextStyle(
            color: inversePrimaryColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _marks.length,
          itemBuilder: (ctx, index) {
            final mark = _marks[index];
            return Dismissible(
              key: Key(mark['id'].toString()),
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8), // Attractive red color
                  borderRadius: BorderRadius.circular(12), // Round corners
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _deleteMark(mark['id']);
              },
              confirmDismiss: (direction) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Confirm Deletion',
                        style: TextStyle(
                          color: inversePrimaryColor,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to delete this mark?',
                        style: TextStyle(
                          color: inversePrimaryColor,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: inversePrimaryColor,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Card(
                elevation: 4,
                color: primaryColor,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Round corners
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  title: Text(
                    mark['subjectName'],
                    style: TextStyle(
                      color: inversePrimaryColor,
                    ),
                  ),
                  subtitle: Text(
                    '${mark['featureName']}: ${mark['featureMarks']}',
                    style: TextStyle(
                      color: inversePrimaryColor,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: secondaryColor,
                    ),
                    onPressed: () => _showPopup(mark: mark),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPopup(),
        child: Icon(
          Icons.add,
          color: secondaryColor,
        ),
      ),
    );
  }
}
