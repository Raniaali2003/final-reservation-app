import 'package:shared_preferences/shared_preferences.dart';

class CategoryService {
  static const String _categoriesKey = 'restaurant_categories';
  
  // Default categories that will be available when the app is first installed
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

  // Get all categories
  Future<List<String>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categories = prefs.getStringList(_categoriesKey);
    
    // If no categories exist yet, initialize with default categories
    if (categories == null || categories.isEmpty) {
      await _saveCategories(defaultCategories);
      return defaultCategories;
    }
    
    return categories;
  }

  // Add a new category
  Future<bool> addCategory(String category) async {
    if (category.isEmpty) return false;
    
    final categories = await getCategories();
    if (categories.contains(category)) return false;
    
    categories.add(category);
    return await _saveCategories(categories);
  }

  // Remove a category
  Future<bool> removeCategory(String category) async {
    final categories = await getCategories();
    if (!categories.contains(category)) return false;
    
    categories.remove(category);
    return await _saveCategories(categories);
  }

  // Update a category
  Future<bool> updateCategory(String oldCategory, String newCategory) async {
    if (newCategory.isEmpty) return false;
    
    final categories = await getCategories();
    final index = categories.indexOf(oldCategory);
    
    if (index == -1) return false;
    
    categories[index] = newCategory;
    return await _saveCategories(categories);
  }

  // Save categories to shared preferences
  Future<bool> _saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(_categoriesKey, categories);
  }
}
