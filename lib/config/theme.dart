import 'package:flutter/material.dart';

class AppThemes {
  static const Color newPrimaryColor = Color(0xFF8F4C38);

  static const Color lightBackground = Colors.white;
  static const Color darkBackground = Colors.black;

  static ThemeData lightTheme = ThemeData(
    primaryColor: newPrimaryColor, 
    colorScheme: ColorScheme.light(primary: newPrimaryColor), 
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: newPrimaryColor,
      titleTextStyle: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 18, color: Colors.black),
      bodyMedium: TextStyle(fontFamily: 'Montserrat', fontSize: 16, color: Colors.black),
      titleLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87), 
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        side: BorderSide.none,
        backgroundColor: newPrimaryColor, 
        foregroundColor: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        side: BorderSide(color: newPrimaryColor),
        backgroundColor: Colors.transparent, 
        foregroundColor: newPrimaryColor, 
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: newPrimaryColor, 
    colorScheme: ColorScheme.dark(primary: newPrimaryColor),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: newPrimaryColor,
      titleTextStyle: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 18, color: Colors.white),
      bodyMedium: TextStyle(fontFamily: 'Montserrat', fontSize: 16, color: Colors.white),
      titleLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        side: BorderSide.none,
        backgroundColor: const Color.fromARGB(255, 108, 61, 15),
        foregroundColor: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
         textStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        side: BorderSide(color: newPrimaryColor), 
        backgroundColor: Colors.transparent, 
        foregroundColor: newPrimaryColor, 
      ),
    ),
  );
}