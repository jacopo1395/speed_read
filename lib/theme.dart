import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get primaryTheme {
    final base = ThemeData.light();
    return base.copyWith(
      appBarTheme: _buildAppBarTheme(base),
      backgroundColor: Colors.white,
      accentColor: Colors.yellow,
      primaryColor: Colors.white,
      buttonColor: Colors.blue,
      // hintColor: accentYellow,
      canvasColor: Colors.white,

//      scaffoldBackgroundColor: primaryWhite,
//      cardColor: itemVeryLightGrayMostlyWhite,
//      errorColor: errorStrongRed,
      textTheme: _buildPrimaryTextTheme(base.textTheme),
//      primaryTextTheme: _buildPrimaryTextTheme(base.primaryTextTheme),
//      accentTextTheme: _buildPrimaryTextTheme(base.accentTextTheme),
      primaryIconTheme: base.iconTheme.copyWith(color: Colors.blue),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0)),
      ),
    );
  }

  static TextTheme _buildPrimaryTextTheme(TextTheme base) {
    return base
        .copyWith(

        )
        .apply(
          fontFamily: 'SourceSansPro',
        );
  }

  static AppBarTheme _buildAppBarTheme(ThemeData base) {
    return AppBarTheme(textTheme: _buildPrimaryTextTheme(base.textTheme));
  }
}
