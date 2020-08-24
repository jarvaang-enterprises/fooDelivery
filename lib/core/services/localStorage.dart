import 'dart:convert';

import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static LocalStorage _instance;
  static SharedPreferences _preferences;

  static Future<LocalStorage> getInstance() async {
    // SharedPreferences.setMockInitialValues({});

    if (_instance == null) {
      _instance = LocalStorage();
    }

    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }

    return _instance;
  }

  static const String UserKey = 'user';

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

  dynamic _getFromDisk(String key) {
    var value = _preferences.get(key);
    print('(TRACE) LocalStorageService:_getFromDisk. key: $key value: $value');
    return value;
  }

  bool getFromDisk(String key) {
    return _getFromDisk(key);
  }

  void saveGetStartedToDisk(String key, bool content) {
    print(
        '(TRACE) LocalStorageService: _saveGetStartedToDisk. key: $key value: $content');
    _preferences.setBool(key, content);
  }

  void saveStringToDisk(String key, String content) {
    print(
        '(TRACE) LocalStorageService:_saveStringToDisk. key: $key value: $content');
    _preferences.setString(UserKey, content);
  }
}
