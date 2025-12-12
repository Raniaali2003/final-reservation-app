// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
// import 'package:my_first_flutter_app/services/auth_service.dart';
// import 'package:my_first_flutter_app/models/user.dart';

// // Mock Directory class
// class MockDirectory extends Mock implements Directory {
//   @override
//   Future<Directory> create({bool recursive = false}) async => this;
  
//   @override
//   String get path => './test_dir';
// }

// // Mock File class
// class MockFile extends Mock implements File {
//   final Map<String, String> _storage = {};
//   String? _path;
  
//   @override
//   String get path => _path ?? './test.json';
  
//   @override
//   Future<File> writeAsString(String contents, {
//     FileMode mode = FileMode.write,
//     Encoding encoding = utf8,
//     bool flush = false,
//   }) async {
//     _storage[path] = contents;
//     return this;
//   }
  
//   @override
//   Future<bool> exists() async => _storage.containsKey(path);
  
//   @override
//   Future<String> readAsString({Encoding encoding = utf8}) async => _storage[path] ?? '[]';
  
//   @override
//   Future<File> create({bool recursive = false, bool exclusive = false}) async => this;
// }

// // Mock PathProviderPlatform
// class MockPathProviderPlatform extends Mock implements PathProviderPlatform {
//   final MockFile mockFile = MockFile();
  
//   @override
//   Future<Directory> getApplicationDocumentsDirectory() async {
//     return MockDirectory() as Directory;
//   }
  
//   @override
//   Future<String> getApplicationSupportPath() async => '.';
  
//   @override
//   Future<String> getTemporaryPath() async => './tmp';
  
//   @override
//   Future<Directory> getTemporaryDirectory() async {
//     final path = await getTemporaryPath();
//     return Directory(path);
//   }
// }

// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();
  
//   late MockPathProviderPlatform mockPathProvider;
//   late AuthService authService;
  
//   setUpAll(() {
//     // Register mock path provider
//     mockPathProvider = MockPathProviderPlatform();
//     PathProviderPlatform.instance = mockPathProvider;
    
//     // Setup method channel for path_provider
//     const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
//     TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
//         .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
//       if (methodCall.method == 'getApplicationDocumentsDirectory') {
//         return '.';
//       } else if (methodCall.method == 'getTemporaryDirectory') {
//         return './tmp';
//       }
//       return null;
//     });
//   });
  
//   setUp(() {
//     authService = AuthService();
//   });
  
//   test('AuthService can register a new user', () async {
//     // Arrange
//     final user = User(
//       id: '1',
//       name: 'Test User',
//       email: 'test@example.com',
//       isVendor: false,
//     );
    
//     // Act
//     await authService.register(user, 'password123');
    
//     // Assert
//     expect(authService.isAuthenticated, isTrue);
//     expect(authService.currentUser?.email, 'test@example.com');
//   });
  
//   test('AuthService can login with correct credentials', () async {
//     // Arrange
//     final user = User(
//       id: '1',
//       name: 'Test User',
//       email: 'test@example.com',
//       isVendor: false,
//     );
//     await authService.register(user, 'password123');
    
//     // Act
//     await authService.login('test@example.com', 'password123');
    
//     // Assert
//     expect(authService.isAuthenticated, isTrue);
//     expect(authService.currentUser?.email, 'test@example.com');
//   });
  
//   test('AuthService login fails with wrong password', () async {
//     // Arrange
//     final user = User(
//       id: '1',
//       name: 'Test User',
//       email: 'test@example.com',
//       isVendor: false,
//     );
//     await authService.register(user, 'password123');
    
//     // Act & Assert
//     expect(
//       () => authService.login('test@example.com', 'wrongpassword'),
//       throwsA(isA<Exception>()),
//     );
//   });
// }
