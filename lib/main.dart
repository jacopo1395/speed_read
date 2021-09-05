import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speed_read/constants/theme.dart';
import 'package:speed_read/routes.dart';
import 'package:speed_read/service/local_storage.service.dart';
import 'package:speed_read/service/navigation.service.dart';
import 'package:speed_read/service/shared_preferences.service.dart';

StreamController<ThemeData> isThemeChanged = StreamController();

void main() async{
  runApp(MyApp());
  SharedPreferenceService().initSharedPreferencesInstance();
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeData>(
        initialData: AppThemes.primaryTheme,
        stream: isThemeChanged.stream,
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'Speed Read',
            // supportedLocales: [
            //   Locale('en', 'EN'),
            //   Locale('it', 'IT'),
            // ],
            // localizationsDelegates: [
            //   AppLocalizations.delegate,
            //   GlobalMaterialLocalizations.delegate,
            //   GlobalWidgetsLocalizations.delegate,
            //   DefaultCupertinoLocalizations.delegate,
            //   GlobalCupertinoLocalizations.delegate,
            // ],
            // localeResolutionCallback: (locale, supportedLocales) {
            //   for (var supportedLocale in supportedLocales) {
            //     if (supportedLocale.languageCode == locale.languageCode &&
            //         supportedLocale.countryCode == locale.countryCode) {
            //       return supportedLocale;
            //     }
            //   }
            //   return supportedLocales.first;
            // },
            debugShowCheckedModeBanner: false,
            theme: snapshot.data,
            navigatorKey: NavigationService.navigatorKey,
            // initialRoute: BOOK_LIST,
            onGenerateRoute: routes,
          );
        });
  }
}
