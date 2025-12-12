import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String email;
  final bool isVendor;
  final String? restaurantId; // Only for vendors
  final String? phoneNumber;
  String? _password; // Private field for password

  User({
    required this.id,
    required this.name,
    required this.email,
    this.isVendor = false,
    this.restaurantId,
    this.phoneNumber,
    String? password,
  }) : _password = password;

  // Getter for password (read-only)
  String? get password => _password;

  // Setter for password (only used during registration/password reset)
  set password(String? value) {
    _password = value;
  }

  // Convert User object to a Map
  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'name': name,
      'email': email,
      'isVendor': isVendor,
      'restaurantId': restaurantId,
      'phoneNumber': phoneNumber,
    };
    
    // Only include password if it's not null
    if (_password != null) {
      map['password'] = _password!;
    }
    
    return map;
  }

  // Create a User object from a Map
  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isVendor: json['isVendor'] == true,
      restaurantId: json['restaurantId']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      password: json['password']?.toString(),
    );
    
    debugPrint('Created user from JSON: ${user.email}, password: ${user.password != null ? 'set' : 'not set'}');
    return user;
  }
}
