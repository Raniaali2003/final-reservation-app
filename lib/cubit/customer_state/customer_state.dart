import 'package:equatable/equatable.dart';
import 'package:my_first_flutter_app/models/restaurant.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerRestaurantsLoaded extends CustomerState {
  final List<Restaurant> restaurants;
  final List<String> categories;

  const CustomerRestaurantsLoaded({
    required this.restaurants,
    required this.categories,
  });

  @override
  List<Object> get props => [restaurants, categories];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object> get props => [message];
}
