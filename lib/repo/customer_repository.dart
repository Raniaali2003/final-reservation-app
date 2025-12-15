import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_first_flutter_app/models/restaurant.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Restaurant>> getRestaurants() async {
    try {
      final snapshot = await _firestore.collection('restaurants').get();
      return snapshot.docs
          .map((doc) => Restaurant.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch restaurants: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      // Return default categories if none found
      return [
        'Italian',
        'Chinese',
        'Indian',
        'Mexican',
        'American',
        'Japanese',
      ];
    }
  }

  Future<void> toggleFavorite(String restaurantId, String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final doc = await userRef.get();

      if (doc.exists) {
        final favorites = List<String>.from(doc['favoriteRestaurants'] ?? []);
        if (favorites.contains(restaurantId)) {
          favorites.remove(restaurantId);
        } else {
          favorites.add(restaurantId);
        }
        await userRef.update({'favoriteRestaurants': favorites});
      }
    } catch (e) {
      throw Exception('Failed to update favorites: $e');
    }
  }
}
