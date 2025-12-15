import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repo/customer_repository.dart';
import '../customer_state/customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _customerRepository;

  CustomerCubit({CustomerRepository? customerRepository})
      : _customerRepository = customerRepository ?? CustomerRepository(),
        super(CustomerInitial());

  // Load restaurants and categories
  Future<void> loadRestaurants() async {
    try {
      emit(CustomerLoading());

      final restaurants = await _customerRepository.getRestaurants();
      final categories = await _customerRepository.getCategories();

      emit(CustomerRestaurantsLoaded(
        restaurants: restaurants,
        categories: categories,
      ));
    } catch (e) {
      emit(CustomerError('Failed to load restaurants: ${e.toString()}'));
    }
  }

  // Toggle favorite status for a restaurant
  Future<void> toggleFavorite(String restaurantId, String userId) async {
    try {
      if (state is CustomerRestaurantsLoaded) {
        await _customerRepository.toggleFavorite(restaurantId, userId);
        // Reload data to reflect the change
        await loadRestaurants();
      }
    } catch (e) {
      emit(CustomerError('Failed to update favorites: ${e.toString()}'));
    }
  }
}
