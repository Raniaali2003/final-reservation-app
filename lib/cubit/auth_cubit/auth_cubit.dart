import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(AuthInitial()) {
    // Initialize and listen to auth state changes
    _initAuth();
  }

  Future<void> _initAuth() async {
    await _authService.init();
    _onAuthStateChanged();
    _authService.addListener(_onAuthStateChanged);
  }

  @override
  Future<void> close() {
    _authService.removeListener(_onAuthStateChanged);
    return super.close();
  }

  void _onAuthStateChanged() {
    if (_authService.currentUser != null) {
      emit(Authenticated(_authService.currentUser!));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      emit(AuthLoading());
      await _authService.login(email, password);
      // The _onAuthStateChanged will handle the state update
    } catch (e) {
      emit(AuthError(e.toString()));
      rethrow;
    }
  }

  Future<void> register(
      String email, String password, String name, bool isVendor) async {
    try {
      emit(AuthLoading());
      await _authService.register(email, password, name, isVendor);
      // The _onAuthStateChanged will handle the state update
    } catch (e) {
      emit(AuthError(e.toString()));
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.logout();
      // The _onAuthStateChanged will handle the state update
    } catch (e) {
      emit(AuthError(e.toString()));
      rethrow;
    }
  }

  // Get current user (synchronous)
  User? getCurrentUser() {
    return _authService.currentUser;
  }

  // Check if user is authenticated (synchronous)
  bool isAuthenticated() {
    return _authService.isAuthenticated;
  }

  // Check if current user is a vendor (synchronous)
  bool isVendor() {
    return _authService.currentUser?.isVendor ?? false;
  }
}
