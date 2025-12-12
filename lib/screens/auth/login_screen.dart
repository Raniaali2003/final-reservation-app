


import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final bool isVendor;

  const LoginScreen({super.key, this.isVendor = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  // Color constants
  static const Color primaryBlack = Colors.black;
  static const Color lightGray = Colors.grey;
  static const double borderRadius = 30.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (!mounted) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authService = context.read<AuthService>();
      final isVendor = authService.currentUser?.isVendor ?? false;
      
      if (isVendor) {
        Navigator.of(context, rootNavigator: false)
            .pushNamedAndRemoveUntil('/vendor-home', (route) => false);
      } else {
        Navigator.of(context, rootNavigator: false)
            .pushNamedAndRemoveUntil('/customer-home', (route) => false);
      }
    });
  }

  void _handleAuthSuccess({required String message}) {
    if (!mounted) return;
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _navigateToHome();
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final authService = context.read<AuthService>();
      final success = await authService.login(email, password);

      if (!mounted) return;

      if (success) {
        // If login succeeded, wait a bit for user data to be set
        if (authService.currentUser == null) {
          // Wait for auth state listener to update currentUser
          for (int i = 0; i < 5; i++) {
            await Future.delayed(const Duration(milliseconds: 300));
            if (authService.currentUser != null) break;
            if (!mounted) return;
          }
        }
        
        // Navigate to home if login succeeded
        // Even if currentUser is temporarily null, the auth state listener will update it
        // and the user is authenticated in Firebase Auth
        _handleAuthSuccess(message: 'Login successful');
      } else {
        setState(() {
          _errorMessage =
              authService.error ?? 'Login failed. Please check your credentials.';
        });
      }
    } catch (e) {
      debugPrint('Login error: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBlack),
          onPressed: () => Navigator.pushReplacementNamed(context, '/role-selection'),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight;
            final hasBoundedHeight = maxHeight != double.infinity;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: hasBoundedHeight
                  ? ConstrainedBox(
                      constraints: BoxConstraints(minHeight: maxHeight),
                      child: _buildContent(context),
                    )
                  : _buildContent(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLogoPlaceholder(),
            const SizedBox(height: 50),
            const Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: primaryBlack),
            ),
            const SizedBox(height: 50),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: lightGray),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: const BorderSide(color: lightGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide:
                            const BorderSide(color: primaryBlack, width: 2),
                      ),
                    ),
                    validator: (value) => value != null && EmailValidator.validate(value)
                        ? null
                        : 'Enter a valid email',
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: lightGray),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: const BorderSide(color: lightGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide:
                            const BorderSide(color: primaryBlack, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: primaryBlack,
                        ),
                        onPressed: () =>
                            setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    validator: (value) =>
                        value != null && value.isNotEmpty ? null : 'Password is required',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
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
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Log in with Email',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {},
              child: const Text('Forgot password? Reset it.',
                  style: TextStyle(
                      color: primaryBlack,
                      decoration: TextDecoration.underline)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('New user? ', style: TextStyle(color: primaryBlack)),
                InkWell(
                  onTap: () => Navigator.pushReplacementNamed(
                      context, '/register',
                      arguments: {'isVendor': widget.isVendor}),
                  child: const Text('Sign up',
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
            const SizedBox(height: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoPlaceholder() => Center(
        child: Image.asset('assets/Reservo4.png', height: 80),
      );
}
