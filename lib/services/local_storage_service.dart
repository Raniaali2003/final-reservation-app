import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // 💡 يفضل إزالة نمط Singleton أو تركه كما هو، لكن لا يؤثر على المشكلة.
  static final LocalStorageService _instance = LocalStorageService._internal();
  static SharedPreferences? _prefs;

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  // 1. 🚀 دالة التهيئة الأساسية: يتم استدعاؤها في FutureBuilder في main.dart
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 2. دالة مساعدة للتحقق من التهيئة
  // نستخدم هذه الدالة للتأكد من أننا لا نحاول القراءة/الكتابة إذا لم يتم تهيئة _prefs
  bool _isInitialized() {
    return _prefs != null;
  }
  
  // 3. ⚠️ تم حذف await init() داخل دوال الحفظ والقراءة
  
  // Save data methods
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

  // Read data methods
  String? getString(String key) {
    if (!_isInitialized()) return null;
    return _prefs!.getString(key); // تم تغيير ? إلى ! لأننا تحققنا من عدم كونه null
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