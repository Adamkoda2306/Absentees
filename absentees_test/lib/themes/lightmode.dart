import 'package:flutter/material.dart';

final colorsurface = Colors.grey.shade100;

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade100,
    primary: Color.fromRGBO(198, 199, 199, 1),
    secondary: Color.fromARGB(255, 27, 139, 231),
    inversePrimary: Colors.black,
  ),
  appBarTheme: AppBarTheme(
    iconTheme: const IconThemeData(
      color: Colors.black,
    ),
    backgroundColor: colorsurface,
  ),
  iconTheme: const IconThemeData(
    color: Colors.black,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'Roboto',
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Roboto',
    ),
    displayLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 96.0,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 60.0,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 48.0,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 34.0,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 12.0,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 10.0,
    ),
  ),
);
