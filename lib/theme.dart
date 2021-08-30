import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speed_read/colors.dart';

class AppTheme {

  static ThemeData get primaryTheme {
    final base = ThemeData.light();
    return base.copyWith(
        textTheme: _buildPrimaryTextTheme(base.textTheme),
        scaffoldBackgroundColor: white);
  }

  static TextTheme get primaryTextTheme {
   return primaryTheme.textTheme;
  }

  static TextTheme _buildPrimaryTextTheme(TextTheme base) {
    return base
        .copyWith(
          // Title Page
          headline1: base.headline1?.copyWith(
            // fontSize: 20,
            color: black,
          ),
          headline2: base.headline2?.copyWith(
            fontSize: 34,
            color: Colors.red,
            fontWeight: FontWeight.w700,
          ),
          headline3: base.headline3?.copyWith(
            fontSize: 34,
            color: Colors.yellow,
            fontWeight: FontWeight.w700,
          ),
          headline4: base.headline4?.copyWith(
            fontSize: 34,
            color: Colors.green,
            fontWeight: FontWeight.w700,
          ),
          headline5: base.headline5?.copyWith(
            fontSize: 22,
            color: Colors.blue,
            fontWeight: FontWeight.w700,
          ),
          headline6: base.headline6?.copyWith(
            fontSize: 22,
            color: Colors.orange,
            fontWeight: FontWeight.w700,
          ),
          // title
          subtitle1: base.subtitle1?.copyWith(
            // fontWeight: FontWeight.w600,
            // fontSize: 18,
            color: black,
          ),
          subtitle2: base.subtitle2?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.limeAccent,
          ),
          // text
          bodyText1: base.bodyText1?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: black,
          ),
          bodyText2: base.bodyText2?.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: Colors.white,
          ),
          // subtitle
          caption: base.caption?.copyWith(
            // fontWeight: FontWeight.normal,
            color: grey,
            // fontSize: 16,
          ),
          overline: base.overline?.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.brown,
            fontSize: 16,
          ),
          button: base.button?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        )
        .apply(
          fontFamily: 'SourceSansPro',
        );
  }

}
