import 'package:shared_preferences/shared_preferences.dart';

class CategoryService {
  static const String _categoriesKey = 'restaurant_categories';

  static const List<String> defaultCategories = [
    'Italian',
    'Chinese',
    'Indian',
    'Mexican',
    'Japanese',
    'American',
    'Mediterranean',
    'Desserts',
    'Seafood',
    'Vegetarian',
    'Vegan',
    'Fast Food',
    'Cafe',
    'Steakhouse',
    'Barbecue',
  ];

  Future<List<String>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categories = prefs.getStringList(_categoriesKey);

    if (categories == null || categories.isEmpty) {
      await _saveCategories(defaultCategories);
      return defaultCategories;
    }

    return categories;
  }

  Future<bool> addCategory(String category) async {
    if (category.isEmpty) return false;

    final categories = await getCategories();
    if (categories.contains(category)) return false;

    categories.add(category);
    return await _saveCategories(categories);
  }

  Future<bool> removeCategory(String category) async {
    final categories = await getCategories();
    if (!categories.contains(category)) return false;

    categories.remove(category);
    return await _saveCategories(categories);
  }

  Future<bool> updateCategory(String oldCategory, String newCategory) async {
    if (newCategory.isEmpty) return false;

    final categories = await getCategories();
    final index = categories.indexOf(oldCategory);

    if (index == -1) return false;

    categories[index] = newCategory;
    return await _saveCategories(categories);
  }

  Future<bool> _saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(_categoriesKey, categories);
  }
}
