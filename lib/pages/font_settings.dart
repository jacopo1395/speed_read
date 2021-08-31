import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:speed_read/constants/colors.dart';
import 'package:speed_read/constants/constants.dart';
import 'package:speed_read/constants/theme.dart';
import 'package:speed_read/main.dart';
import 'package:speed_read/service/shared_preferences.service.dart';

class FontSettingsPage extends StatefulWidget {
  @override
  _FontSettingsPageState createState() => _FontSettingsPageState();
}

class _FontSettingsPageState extends State<FontSettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Font Settings"),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: padding),
                    child: Icon(Icons.format_size, color: greenPrimary),
                  ),
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText:
                              SharedPreferenceService().fontSize.toString()),
                      onChanged: (String value) {
                        SharedPreferenceService()
                            .setFontSize(double.parse(value));
                        isThemeChanged.add(AppThemes.primaryTheme.copyWith(
                            textTheme: AppThemes.primaryTextTheme.copyWith(
                                bodyText1: AppThemes.primaryTextTheme.bodyText1
                                    ?.copyWith(
                                        fontSize: double.parse(value)))));
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
