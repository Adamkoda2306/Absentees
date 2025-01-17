import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Alamanacpage extends StatelessWidget {
  const Alamanacpage({super.key});

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
    final Color inversePrimaryColor =
        Theme.of(context).colorScheme.inversePrimary;
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
            child: Text(
              "Almanac",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: inversePrimaryColor,
              ),
            ),
          ),
        ),
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20.0),
        minScale: 0.5, // Minimum zoom scale
        maxScale: 5.0, // Maximum zoom scale
        child: SizedBox(
          width: double.infinity,
          height:
              double.infinity, // Ensures the image takes up all available space
          child: Image.asset(
            'assets/images/alamanac.png', // Add your image asset path here
            fit: BoxFit.cover, // Adjust image scaling
          ),
        ),
      ),
    );
  }
}
