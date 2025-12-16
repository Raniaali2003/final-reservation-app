import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  static SharedPreferences? _prefs;

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool _isInitialized() {
    return _prefs != null;
  }

  Future<bool> setString(String key, String value) async {
    if (!_isInitialized()) return false;
    return await _prefs!.setString(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    if (!_isInitialized()) return false;
    return await _prefs!.setInt(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    if (!_isInitialized()) return false;
    return await _prefs!.setBool(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    if (!_isInitialized()) return false;
    return await _prefs!.setDouble(key, value);
  }

  String? getString(String key) {
    if (!_isInitialized()) return null;
    return _prefs!
        .getString(key); // تم تغيير ? إلى ! لأننا تحققنا من عدم كونه null
  }

  int? getInt(String key) {
    if (!_isInitialized()) return null;
    return _prefs!.getInt(key);
  }

  bool? getBool(String key) {
    if (!_isInitialized()) return null;
    return _prefs!.getBool(key);
  }

  double? getDouble(String key) {
    if (!_isInitialized()) return null;
    return _prefs!.getDouble(key);
  }

  // Remove data
  Future<bool> remove(String key) async {
    if (!_isInitialized()) return false;
    return await _prefs!.remove(key);
  }

  // Clear all data
  Future<bool> clear() async {
    if (!_isInitialized()) return false;
    return await _prefs!.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    if (!_isInitialized()) return false;
    return _prefs!.containsKey(key);
  }
}
