// lib/screens/login_screen.dart
import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/core/app_text_styles.dart';
import 'package:brainmoto_app/core/constant.dart';
import 'package:brainmoto_app/core/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigate based on role
      switch (authProvider.currentUser!.role) {
        case UserRole.teacher:
          Navigator.of(context).pushReplacementNamed('/teacher-dashboard');
          break;
        case UserRole.coordinator:
          Navigator.of(context).pushReplacementNamed('/coordinator-dashboard');
          break;
        case UserRole.super_admin:
          Navigator.of(context).pushReplacementNamed('/super-admin-dashboard');
          break;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleBiometricLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithBiometric();

    if (!mounted) return;

    if (success) {
      // Navigate based on role
      switch (authProvider.currentUser!.role) {
        case UserRole.teacher:
          Navigator.of(context).pushReplacementNamed('/teacher-dashboard');
          break;
        case UserRole.coordinator:
          Navigator.of(context).pushReplacementNamed('/coordinator-dashboard');
          break;
        case UserRole.super_admin:
          Navigator.of(context).pushReplacementNamed('/super-admin-dashboard');
          break;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Biometric login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SafeArea(
            child: Form(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset(AssetConstant.brainMotoLogo)),
            Center(
              child: Text(
                StringConstant.loginText,
                style: AppTextStyles.h2,
              ),
            ),
            Center(
                child: Text(StringConstant.belowLoginText,
                    style: AppTextStyles.bodyLarge)),
            SizedBox(
              height: 7.hp,
            ),
            Text(
              StringConstant.email,
              style: AppTextStyles.bodyMedium,
            ),
            Container(
              width: double.infinity,
              height: 7.hp,
              decoration: BoxDecoration(
                  color: AppColors.inputFieldBack,
                  border:
                      Border.all(color: AppColors.inputFieldBorder, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(2.13.wp))),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: StringConstant.emailInputField,
                  hintStyle: AppTextStyles.bodySmall,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.wp,
                    vertical: 2.hp,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.wp),
                    child: Image.asset(
                      AssetConstant.emailLogo,
                      width: 8.wp,
                      height: 8.wp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 3.hp,
            ),
            Text(
              StringConstant.password,
              style: AppTextStyles.bodyMedium,
            ),
            Container(
              width: double.infinity,
              height: 7.hp,
              decoration: BoxDecoration(
                  color: AppColors.inputFieldBack,
                  border:
                      Border.all(color: AppColors.inputFieldBorder, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(2.13.wp))),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: StringConstant.passwordInputField,
                  hintStyle: AppTextStyles.bodySmall,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.wp,
                    vertical: 2.hp,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.wp),
                    child: Image.asset(
                      AssetConstant.lockFrame,
                      width: 8.wp,
                      height: 8.wp,
                    ),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(3.wp),
                      child: Image.asset(
                        _obscurePassword
                            ? AssetConstant.fluentEye
                            : AssetConstant.fluentEye,
                        width: 6.wp,
                        height: 6.wp,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.hp,
            ),
            Container(
              width: double.infinity,
              height: 7.hp,
              decoration: BoxDecoration(
                  color: AppColors.disabledButton,
                  border:
                      Border.all(color: AppColors.inputFieldBorder, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(2.13.wp))),
              child: Center(
                child: Text(
                  StringConstant.getStarted,
                  style: AppTextStyles.h4
                      .copyWith(color: AppColors.disabledButtonText),
                ),
              ),
            ),
          ],
        ))),
      ),
    );
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Logo
//                   Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF4e3f8a),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Icon(
//                       Icons.psychology,
//                       size: 60,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   const Text(
//                     'Welcome to Brainmoto',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF4e3f8a),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Sign in to continue',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   const SizedBox(height: 40),

//                   // Email Field
//                   TextFormField(
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: const InputDecoration(
//                       labelText: 'Email',
//                       prefixIcon: Icon(Icons.email),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your email';
//                       }
//                       if (!value.contains('@')) {
//                         return 'Please enter a valid email';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Password Field
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: _obscurePassword,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       prefixIcon: const Icon(Icons.lock),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword = !_obscurePassword;
//                           });
//                         },
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your password';
//                       }
//                       if (value.length < 6) {
//                         return 'Password must be at least 6 characters';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 24),

//                   // Login Button
//                   Consumer<AuthProvider>(
//                     builder: (context, authProvider, child) {
//                       return ElevatedButton(
//                         onPressed: authProvider.isLoading ? null : _handleLogin,
//                         child: authProvider.isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Text('Sign In',
//                                 style: TextStyle(fontSize: 16)),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Biometric Login Button
//                   Consumer<AuthProvider>(
//                     builder: (context, authProvider, child) {
//                       if (!authProvider.biometricEnabled)
//                         return const SizedBox();

//                       return OutlinedButton.icon(
//                         onPressed: authProvider.isLoading
//                             ? null
//                             : _handleBiometricLogin,
//                         icon: const Icon(Icons.fingerprint),
//                         label: const Text('Sign In with Biometric'),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: const Color(0xFF4e3f8a),
//                           side: const BorderSide(color: Color(0xFF4e3f8a)),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
}
