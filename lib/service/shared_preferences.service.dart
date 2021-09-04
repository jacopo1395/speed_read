import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static const SPEED = 'speed';
  static const FONT_SIZE = 'fontSize';
  static const FONT_COLOR = 'fontColor';
  static const BACKGROUND_COLOR = 'backgroundColor';

  SharedPreferenceService._();

  static final SharedPreferenceService _instance = SharedPreferenceService._();

  SharedPreferences? _prefs;

  Future<void> initSharedPreferencesInstance() async {
    _prefs = await SharedPreferences.getInstance().catchError((dynamic e) {
      debugPrint('shared prefrences error : $e');
    });
  }

  Future setString(String name, String value) async {
    await _prefs!.setString(name, value);
  }

  Future setInt(String name, int value) async {
    await _prefs!.setInt(name, value);
  }

  Future setBool(String name, bool value) async {
    await _prefs!.setBool(name, value);
  }

  Future remove(String name) async {
    await _prefs!.remove(name);
  }

  Future clearAll() async {
    await _prefs!.clear();
  }

  factory SharedPreferenceService() {
    return _instance;
  }



  int get speed {
    return _prefs!.getInt(SPEED) ?? 200;
  }

  void setSpeed(int value) async {
    await _prefs!.setInt(SPEED, value);
  }


  double get fontSize {
    return _prefs!.getDouble(FONT_SIZE) ?? 18;
  }

  void setFontSize(double value) async {
    await _prefs!.setDouble(FONT_SIZE, value);
  }

  int get fontColor {
    return _prefs!.getInt(FONT_COLOR) ?? 0xFF4F514A;
  }

  void setFontColor(int value) async {
    await _prefs!.setInt(FONT_COLOR, value);
  }
}
