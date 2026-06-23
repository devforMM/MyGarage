import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes.dart';
import '../theme/app_theme.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;



  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Fade in progressif et élégant
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Effet d'aspiration / zoom fluide vers l'utilisateur
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Respiration subtile de la lueur arrière-plan
    _glowAnimation = Tween<double>(begin: 30.0, end: 50.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );

    _animationController.forward();

    // Redirection après 4 secondes (5s c'était un peu long pour l'expérience utilisateur)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.login_route);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080F18), // Base sombre signature
      body: Stack(
        children: [
          // Profondeur de champ ambiante (Radial Glow de fond)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF0F2636), // Lueur centrale diffuse
                    Color(0xFF080F18), // Extinction vers les bords
                  ],
                ),
              ),
            ),
          ),

          // Contenu principal animé
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LOGO FRAME AVEC LUMINESCENCE CYBER
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 130,
                            height: 130,
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
                                  blurRadius: _glowAnimation.value,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(4), // Bordure fine lumineuse
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF080F18),
                              ),
                              padding: const EdgeInsets.all(18),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback élégant si le logo ne charge pas temporairement
                                    return const Icon(
                                      Icons.engineering_rounded,
                                      size: 45,
                                      color: AppTheme.secondary,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ZONE DE TEXTE & MARQUE
                        const Text(
                          "MY GARAGE",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.secondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "MULTIMODAL AI DIAGNOSTIC",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                        
                        // Indicateur de chargement futuriste décalé vers le bas
                        const SizedBox(height: 90),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                            backgroundColor: Colors.white.withOpacity(0.03),
                            strokeWidth: 2.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "INITIALIZING SYSTEMS...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.25),
                            fontSize: 10,
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}