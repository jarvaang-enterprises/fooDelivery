import 'dart:convert';

import 'package:fooddeliveryboiler/core/models/deliveryModel.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static LocalStorage _instance;
  static SharedPreferences _preferences;

  static Future<LocalStorage> getInstance() async {
    // SharedPreferences.setMockInitialValues({});

    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    if (_instance == null) {
      _instance = LocalStorage();
      _instance.saveCurrentScreen("homeModal");
    }

    return _instance;
  }

  static const String UserKey = 'user';
  static const String DelDataKey = 'DeliveryData';

  UserData get user {
    var userJson = _getFromDisk(UserKey);
    if (userJson == null) {
      return null;
    }
    return UserData.fromJson(json.decode(userJson));
  }

  set user(UserData userToSave) {
    saveStringToDisk(UserKey, json.encode(userToSave.toJson()));
  }

  set delivery(DeliveryData d) {
    saveStringToDisk(DelDataKey, json.encode(d.toJson()));
  }

  DeliveryData get delivery {
    var dDataJson = _getFromDisk(DelDataKey);
    if (dDataJson == null) {
      return null;
    }
    return DeliveryData.fromJson(json.decode(dDataJson));
  }

  dynamic _getFromDisk(String key) {
    var value = _preferences.get(key);
    return value;
  }

  bool getFromDisk(String key) {
    return _getFromDisk(key);
  }

  String getCurrentScreen() {
    String currValue = _getFromDisk("currScreen");
    return currValue;
  }

  void saveGetStartedToDisk(String key, bool content) {
    _preferences.setBool(key, content);
  }

  void savePrevScreen(String preValue) {
    _preferences.setString("prevScreen", preValue);
  }

  String getPrevScreen() {
    String pValue = _getFromDisk("prevScreen");
    return pValue;
  }

  void saveCurrentScreen(String value) {
    savePrevScreen(getCurrentScreen() ?? "");
    _preferences.setString("currScreen", value);
  }

  void saveStringToDisk(String key, String content) async {
    await _preferences.setString(key, content);
  }
}
