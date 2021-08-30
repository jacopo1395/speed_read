import 'package:flutter/material.dart';
import 'package:speed_read/constants/theme.dart';
import 'package:speed_read/routes.dart';
import 'package:speed_read/service/navigation.service.dart';
import 'package:speed_read/service/shared_preferences.service.dart';

void main() {
  runApp(MyApp());
  SharedPreferenceService().initSharedPreferencesInstance();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      theme: AppTheme.primaryTheme,
      navigatorKey: NavigationService.navigatorKey,
      // initialRoute: BOOK_LIST,
      onGenerateRoute: routes,
    );
  }
}
