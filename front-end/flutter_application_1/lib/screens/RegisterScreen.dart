import 'package:flutter/material.dart';
import '../services/user_services.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Map<String, TextEditingController> controllers = {
    "nom": TextEditingController(),
    "prenom": TextEditingController(),
    "email": TextEditingController(),
    "password": TextEditingController(),
    "numTel": TextEditingController(),
    "adresse": TextEditingController(),
  };

  bool _isLoading = false;

  Future<void> handleRegister() async {
    if (controllers.values.any((controller) => controller.text.isEmpty)) {
      SnackBarHelper.showError(context, "Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await register(
        email: controllers["email"]!.text,
        password: controllers["password"]!.text,
        nom: controllers["nom"]!.text,
        prenom: controllers["prenom"]!.text,
        numTel: controllers["numTel"]!.text,
        adresse: controllers["adresse"]!.text,
      );

      SnackBarHelper.showSuccess(context, "Account created successfully ✅");
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.login_route);
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
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080F18), // Fond cinématique profond aligné
      appBar: AppBar(
        backgroundColor: const Color(0xFF080F18),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Registration", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Logo Animé/Premium Style Neon
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.secondary, Color(0xFF00ADB5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondary.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_add_rounded, size: 32, color: Color(0xFF080F18)),
                ),
                const SizedBox(height: 24),

                // Titre & Sous-titre Épurés
                const Text(
                  "Create Your Profile",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  "Enter your details to register in My Garage system.",
                  style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // SECTION 1: IDENTITÉ
                _FormSection(
                  title: "Personal Identity",
                  icon: Icons.badge_outlined,
                  children: [
                    CustomTextInput(
                      label: "Last Name",
                      controller: controllers["nom"]!,
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextInput(
                      label: "First Name",
                      controller: controllers["prenom"]!,
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // SECTION 2: CONTACT & LOCALISATION
                _FormSection(
                  title: "Contact & Location",
                  icon: Icons.contact_mail_outlined,
                  children: [
                    CustomTextInput(
                      label: "Email Address",
                      controller: controllers["email"]!,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextInput(
                      label: "Phone Number",
                      controller: controllers["numTel"]!,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_android_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextInput(
                      label: "Home Address",
                      controller: controllers["adresse"]!,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // SECTION 3: SÉCURITÉ
                _FormSection(
                  title: "Security",
                  icon: Icons.shield_outlined,
                  children: [
                    CustomTextInput(
                      label: "Password",
                      controller: controllers["password"]!,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Bouton d'action principal avec effet de lueur
                InkWell(
                  onTap: _isLoading ? null : handleRegister,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: _isLoading ? [Colors.grey.shade800, Colors.grey.shade700] : [AppTheme.secondary, const Color(0xFF00ADB5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        if (!_isLoading) BoxShadow(color: AppTheme.secondary.withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 5))
                      ]
                    ),
                    child: Center(
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF080F18), strokeWidth: 2.5))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.how_to_reg_rounded, color: Color(0xFF080F18), size: 22),
                              SizedBox(width: 8),
                              Text("Create Account", style: TextStyle(color: Color(0xFF080F18), fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.3)),
                            ],
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Lien de connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already registered?", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Composant interne _FormSection complètement modernisé
class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FormSection({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.secondary, size: 18),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white60, 
                  fontSize: 11, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1.2
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1B2B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}