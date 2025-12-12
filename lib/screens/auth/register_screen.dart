


import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final bool isVendor;

  const RegisterScreen({super.key, this.isVendor = false});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;

  static const Color primaryBlack = Colors.black;
  static const Color lightGray = Colors.grey;
  static const double borderRadius = 30.0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Registration Logic ---
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;

    AuthService? authService;
    try {
      authService = context.read<AuthService>();
    } catch (e) {
      debugPrint('Error accessing AuthService: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Authentication service unavailable. Please try again.';
          _isLoading = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await authService.register(email, password, name, widget.isVendor);

      if (!mounted) return;

      if (success) {
        if (!mounted) return;

        // If registration succeeded, wait a bit for user data to be set
        if (authService.currentUser == null) {
          // Wait for auth state listener to update currentUser
          for (int i = 0; i < 5; i++) {
            await Future.delayed(const Duration(milliseconds: 300));
            if (authService.currentUser != null) break;
            if (!mounted) return;
          }
        }
        
        // Navigate to home if registration succeeded
        // Even if currentUser is temporarily null, the auth state listener will update it
        // and the user is authenticated in Firebase Auth
        _handleAuthSuccess(message: 'Signed up successfully');
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = authService?.error ?? 'Registration failed. Please try again.';
          });
        }
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('Error: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  // --- Navigation to Home ---
  void _navigateToHome() {
    if (!mounted) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final authService = context.read<AuthService>();
      final isVendor = authService.currentUser?.isVendor ?? false;
      
      try {
        if (isVendor) {
          Navigator.of(context, rootNavigator: false)
              .pushNamedAndRemoveUntil('/vendor-home', (route) => false);
        } else {
          Navigator.of(context, rootNavigator: false)
              .pushNamedAndRemoveUntil('/customer-home', (route) => false);
        }
      } catch (e) {
        debugPrint('Navigation error: $e');
        try {
          if (isVendor) {
            Navigator.of(context, rootNavigator: true)
                .pushNamedAndRemoveUntil('/vendor-home', (route) => false);
          } else {
            Navigator.of(context, rootNavigator: true)
                .pushNamedAndRemoveUntil('/customer-home', (route) => false);
          }
        } catch (e2) {
          debugPrint('Root navigator error: $e2');
        }
      }
    });
  }

  void _handleAuthSuccess({required String message}) {
    if (!mounted) return;

    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      debugPrint('Toast error: $e');
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  // --- Rounded Text Field Helper ---
  Widget _buildRoundedTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool isConfirmPassword = false,
  }) {
    bool currentVisibility = isConfirmPassword ? _isConfirmPasswordVisible : _isPasswordVisible;

    VoidCallback? toggleVisibility;
    if (obscureText) {
      toggleVisibility = () {
        setState(() {
          if (isConfirmPassword) {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          } else {
            _isPasswordVisible = !_isPasswordVisible;
          }
        });
      };
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText && !currentVisibility,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: lightGray),
        prefixIcon: Icon(prefixIcon, color: primaryBlack),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryBlack, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        suffixIcon: obscureText
            ? IconButton(
                icon: Icon(currentVisibility ? Icons.visibility : Icons.visibility_off,
                    color: primaryBlack),
                onPressed: toggleVisibility,
              )
            : null,
      ),
      validator: validator,
    );
  }

  // --- Logo Helper ---
  Widget _buildLogoPlaceholder(BuildContext context) =>
      Center(child: Image.asset('assets/Reservo4.png', height: 80));


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogoPlaceholder(context),
                const SizedBox(height: 50),
                Text(
                  widget.isVendor ? 'Register Your Business' : 'Create Account',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: primaryBlack),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.isVendor
                      ? 'Register your restaurant business'
                      : 'Join us to make reservations',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: lightGray, fontSize: 16),
                ),
                const SizedBox(height: 32),

                _buildRoundedTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your name';
                    if (value.length < 3) return 'Name must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildRoundedTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value != null && EmailValidator.validate(value) ? null : 'Please enter a valid email',
                ),
                const SizedBox(height: 16),
                _buildRoundedTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) =>
                      value != null && value.length >= 6 ? null : 'Password must be at least 6 characters',
                ),
                const SizedBox(height: 16),
                _buildRoundedTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  isConfirmPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                ],

                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlack,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Create Account',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 40),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ',
                        style: TextStyle(color: primaryBlack)),
                    InkWell(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login',
                          arguments: {'isVendor': widget.isVendor}),
                      child: const Text('Sign In',
                          style: TextStyle(
                              color: primaryBlack,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/role-selection'),
                  child: const Text('Back to Role Selection',
                      style: TextStyle(color: primaryBlack)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




