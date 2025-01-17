import 'package:absentees_test/pages/alamanacpage.dart';
import 'package:absentees_test/pages/marksmemo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import '../database/subjectdata.dart';
import 'package:flutter/services.dart';
import 'attendancereport.dart';
import 'subjectpage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? selectedUG;
  int? selectedSem;
  String? selectedBranch;
  List<String> subjectNames = [];

  final SubjectList subjectList = SubjectList();
  int _currentIndex = 0; // Track the current index of the carousel
  int _currentPos = 0; // Track the current position of the bottom app bar
  PageController? _pageController; // Make it nullable

  final List<String> imageList = [
    'assets/images/aids_light.jpg',
    'assets/images/cse_light.jpg',
    'assets/images/ece_light.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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

    //Color Theme
    final Color surfaceColor = Theme.of(context).colorScheme.surface;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPos = index;
            });
          },
          children: [
            _buildHomePage(),
            const Attendancereport(),
            const Alamanacpage(),
            const Marksmemo(),
          ],
        ),
      ),
      bottomNavigationBar: SlidingClippedNavBar(
        iconSize: 32,
        backgroundColor: primaryColor,
        barItems: [
          BarItem(title: 'Home', icon: Icons.home_filled),
          BarItem(title: 'Report', icon: Icons.receipt_long_outlined),
          BarItem(title: 'Alamanac', icon: Icons.list_alt_rounded),
          BarItem(title: 'Memo', icon: Icons.note_sharp),
        ],
        selectedIndex: _currentPos,
        onButtonPressed: (index) {
          setState(() {
            _currentPos = index;
          });
          if (_pageController != null) {
            _pageController!.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuad,
            );
          }
        },
        activeColor: secondaryColor,
      ),
    );
  }

  // Home Page Widget
  Widget _buildHomePage() {
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color inversePrimaryColor =
        Theme.of(context).colorScheme.inversePrimary;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            child: Row(
              children: [
                const SizedBox(width: 7),
                Text(
                  "Absentees",
                  style: TextStyle(
                    color: inversePrimaryColor,
                    fontSize: 32,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),

          // Greeting Section
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
            child: Text(
              "Hi,",
              style: TextStyle(
                fontSize: 25,
                color: inversePrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
            child: Text(
              "Welcome to Absentees",
              style: TextStyle(
                fontSize: 18,
                color: inversePrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 18),

          Center(
            child: Row(
              children: [
                const SizedBox(width: 15),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  height: 240,
                  width: 300,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 0),
                        child: CarouselSlider(
                          items: imageList
                              .map(
                                (item) => Image.asset(
                                  item,
                                  fit: BoxFit.fill,
                                  height: 250,
                                  width: 250,
                                ),
                              )
                              .toList(),
                          options: CarouselOptions(
                            viewportFraction: 1,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 2),
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: imageList.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () => _pageController?.animateToPage(
                              entry.key,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutQuad,
                            ),
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 2.0,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentIndex == entry.key
                                    ? secondaryColor
                                    : inversePrimaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Column(
            children: [
              // Dynamically display subjects based on the subjectNames list
              ...subjectNames.map((subject) {
                return _classTile(
                    subject,
                    subject.substring(
                        0, 1)); // Assuming you have a method _classTile
              }).toList(),
            ],
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _classTile(String title, String iconText) {
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color inversePrimaryColor =
        Theme.of(context).colorScheme.inversePrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SubjectPage(subjectName: title)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: secondaryColor,
                    child: Text(
                      iconText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: inversePrimaryColor,
                    ),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios, color: inversePrimaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
