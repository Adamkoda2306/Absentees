import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  String? selectedUG;
  int? selectedSem;
  String? selectedBranch;

  // List of options for UG, Sem, and Branch
  final List<String> ugOptions = ['UG1', 'UG2'];
  final List<int> semUG1Options = [1, 2]; // Semester options for UG1
  final List<int> semUG2Options = [3, 4]; // Semester options for UG2
  final List<String> branchOptions = ['ECE', 'CSE', 'AIDS'];

  List<int> semOptions = []; // This will store the semester options dynamically

  // Save selected values in SharedPreferences
  _saveSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedUG', selectedUG ?? '');
    prefs.setInt('selectedSem', selectedSem ?? 0);
    prefs.setString('selectedBranch', selectedBranch ?? '');
  }

  // Load saved values from SharedPreferences
  _loadSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ug = prefs.getString('selectedUG');
    int? sem = prefs.getInt('selectedSem');
    String? branch = prefs.getString('selectedBranch');

    if (ug != null &&
        sem != null &&
        branch != null &&
        ug.isNotEmpty &&
        branch.isNotEmpty) {
      // Automatically navigate to Homepage if all selections are valid
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    } else {
      setState(() {
        selectedUG = ug;
        selectedSem = sem;
        selectedBranch = branch;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSelection();
  }

  // Update semester options based on selected UG
  void updateSemesterOptions(String? selectedUG) {
    if (selectedUG == 'UG1') {
      semOptions = semUG1Options;
    } else if (selectedUG == 'UG2') {
      semOptions = semUG2Options;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent status bar
        statusBarIconBrightness: (brightness == Brightness.dark)
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    final textStyle = TextStyle(
      fontSize: 16,
      color: Theme.of(context).colorScheme.inversePrimary,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                    child: Image(
                  height: 100,
                  width: 100,
                  image: AssetImage('assets/images/splashlogo.png'),
                  fit: BoxFit.cover, // Adjust the fit of the image
                )),
                const SizedBox(height: 24),
                Text('Select your UG Program:', style: textStyle),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: selectedUG,
                  hint: 'Choose UG',
                  items: ugOptions,
                  onChanged: (newValue) {
                    setState(() {
                      selectedUG = newValue;
                      updateSemesterOptions(
                          selectedUG); // Update semester options
                      selectedSem = null; // Reset semester if UG changes
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text('Select your Semester:', style: textStyle),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: selectedSem,
                  hint: 'Choose Semester',
                  items: semOptions.map((e) => e.toString()).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedSem = int.tryParse(newValue ?? '');
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text('Select your Branch:', style: textStyle),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: selectedBranch,
                  hint: 'Choose Branch',
                  items: branchOptions,
                  onChanged: (newValue) {
                    setState(() {
                      selectedBranch = newValue;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedUG != null &&
                          selectedSem != null &&
                          selectedBranch != null) {
                        _saveSelection();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Homepage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select all fields.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 40,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, // Container color
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary, // Border color
          width: 1.5, // Border width
        ),
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonFormField<String>(
        value: value?.toString(),
        hint: Text(
          hint,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        decoration: const InputDecoration(
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        ),
        dropdownColor: Theme.of(context).colorScheme.primary,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.inversePrimary, // Text color
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
