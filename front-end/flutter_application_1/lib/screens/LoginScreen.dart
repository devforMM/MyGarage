import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_services.dart';
import '../routes.dart';
import '../providers/TokenProvider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  void handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      SnackBarHelper.showError(context, "Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      dynamic res = await login(
        email: emailController.text,
        password: passwordController.text,
      );

      final token = res["access_token"] ?? res["acces_token"];
      if (token != null || res["message"] == "Login successful" || res["message"] == "Connexion réussie") {
        if (token != null) {
          Provider.of<TokenProvider>(context, listen: false).set_token(token);
        }
        SnackBarHelper.showSuccess(context, "Login successful ✅");

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(context, Routes.dashboard_route);
        }
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      SnackBarHelper.showError(context, errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: CustomAppBar(title: "Login", showBack: false),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // ===================== LOGO BRAND =====================
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.secondary, Color(0xFF0097E6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondary.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.build_rounded, 
                  size: 38, 
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 28),

              // ===================== WELCOME TEXTS =====================
              const Text(
                "Welcome to Garage 🏎️", 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Easily manage your analyses and breakdowns",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // ===================== FORM INPUTS =====================
              CustomTextInput(
                label: "Email address",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_rounded,
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: "Password",
                controller: passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_rounded,
              ),
              const SizedBox(height: 32),

              // ===================== ACTION BUTTON =====================
              CustomButton(
                label: "Login",
                onPressed: handleLogin,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),

              // ===================== REGISTER LINK =====================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not registered yet? ", 
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, Routes.register_route),
                    child: const Text(
                      "Sign up here",
                      style: TextStyle(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}