import 'package:flutter/services.dart';

import 'pages/splashscreen.dart';
import 'pages/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes/darkmode.dart';
import 'themes/lightmode.dart';
import 'themes/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const Loginpage(),
      },
      themeMode: themeProvider.themeMode,
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
