import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/actionhistorymodel.dart'; // Update with your actual file path

class AttendanceHistory extends StatefulWidget {
  final String subjectName;

  const AttendanceHistory({super.key, required this.subjectName});

  @override
  _AttendanceHistoryState createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  late Future<List<Map<String, dynamic>>> _actionHistory;

  @override
  void initState() {
    super.initState();
    _loadActionHistory();
  }

  // Load the action history from the database
  void _loadActionHistory() {
    _actionHistory =
        FunctionModel.instance.getActionHistory(widget.subjectName);
  }

  // Undo the action and reload the action history
  Future<void> _undoAction(
      int actionId, String action, String subjectName) async {
    // Perform undo operation
    await FunctionModel.instance.undoAction(actionId, action, subjectName);

    // After undoing, reload the action history
    setState(() {
      _loadActionHistory(); // Refresh the action history
    });
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
        title: Text(
          'Attendance History',
          style: TextStyle(
            color: inversePrimaryColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Label indicating that latest history is on top
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Icon(Icons.history, color: secondaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Latest History on Top',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // History List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _actionHistory,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          color: inversePrimaryColor,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No history available.',
                        style: TextStyle(
                          color: inversePrimaryColor,
                        ),
                      ),
                    );
                  } else {
                    final actions = snapshot.data!;
                    return ListView.builder(
                      itemCount: actions.length,
                      itemBuilder: (context, index) {
                        final action = actions[index];
                        return Card(
                          color: primaryColor,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(
                              action['action'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: inversePrimaryColor,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${action['date']}',
                                  style: TextStyle(
                                    color: inversePrimaryColor,
                                  ),
                                ),
                                Text(
                                  'Time: ${action['time']}',
                                  style: TextStyle(
                                    color: inversePrimaryColor,
                                  ),
                                ),
                                if (action['note'] != null)
                                  Text(
                                    'Note: ${action['note']}',
                                    style: TextStyle(
                                      color: inversePrimaryColor,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.undo,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _undoAction(action['id'], action['action'],
                                    action['subjectName']);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
