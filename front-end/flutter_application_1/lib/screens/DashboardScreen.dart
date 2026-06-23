import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:flutter_application_1/screens/Chatscreen.dart";
import "../providers/TokenProvider.dart";
import "../services/user_services.dart";
import "../services/taule_analysis_services.dart";
import "../services/audio_services.dart";
import "../routes.dart";
import "../theme/app_theme.dart";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenstate createState() => _DashboardScreenstate();
}

class _DashboardScreenstate extends State<DashboardScreen> {
  bool loading = true;
  dynamic user;
  dynamic issues;
  dynamic analyses;

  String userName = "";
  int nbAnalyses = 0;
  int nbBreakdowns = 0;

  Future<void> fetchUser() async {
    try {
      final token = context.read<TokenProvider>().token;
      final fetchedUser = await dashboard(token: token!);
      setState(() {
        user = fetchedUser;
        userName = fetchedUser["nom"] ?? "";
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> fetchBreakdowns() async {
    try {
      final token = context.read<TokenProvider>().token;
      final fetchedIssues = await fetchIssues(token: token!);
      setState(() {
        issues = fetchedIssues;
        nbBreakdowns = (fetchedIssues as List).length;
      });
    } catch (e) {}
  }

  Future<void> loadAnalyses() async {
    try {
      final token = context.read<TokenProvider>().token;
      final fetchedAnalyses = await fetchAnalyses(token: token!);
      setState(() {
        analyses = fetchedAnalyses;
        nbAnalyses = (fetchedAnalyses as List).length;
      });
    } catch (e) {}
  }

  Future<void> reload() async {
    await fetchBreakdowns();
    await loadAnalyses();
  }

  Future<void> handleLogout() async {
    final token = context.read<TokenProvider>().token;
    await logout(token: token);
    context.read<TokenProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.logout_route,
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchBreakdowns();
    loadAnalyses();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.secondary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ===================== HEADER CYBER-PREMIUM =====================
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF111E2E), AppTheme.primary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 70, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back,",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              userName.isEmpty ? "User 👋" : "$userName 👋",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // LOGO & LOGOUT GLOW EFFECT
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.logout_rounded, color: AppTheme.secondary, size: 20),
                              tooltip: "Sign out",
                              onPressed: handleLogout,
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Application Circular Logo Premium Design
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppTheme.secondary, AppTheme.secondary.withOpacity(0.2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.secondary.withOpacity(0.15),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )
                              ]
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0D1622),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  "assets/logo.png",
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person_rounded,
                                      color: AppTheme.secondary,
                                      size: 22,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // MULTIMODAL STAT CARDS (NEON & GLOW STYLE)
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.build_circle_rounded,
                        label: "Bodywork Scans",
                        count: nbAnalyses,
                        glowColor: AppTheme.secondary,
                        gradientColors: const [Color(0xFF182B42), Color(0xFF101D2D)],
                        onTap: () => Navigator.pushNamed(
                          context,
                          Routes.AllAnalyses_route,
                        ).then((_) => reload()),
                      ),
                      const SizedBox(width: 16),
                      _StatCard(
                        icon: Icons.hearing_rounded,
                        label: "Audio Diagnostics",
                        count: nbBreakdowns,
                        glowColor: AppTheme.tertiary,
                        gradientColors: const [Color(0xFF251A2B), Color(0xFF15101A)],
                        onTap: () => Navigator.pushNamed(
                          context,
                          Routes.AllIssues_route,
                        ).then((_) => reload()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ===================== FAST ACTIONS SEPARATOR =====================
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                children: [
                  Text(
                    "FAST ACTIONS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A6585),
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Divider(color: Color(0xFF1A2A3D), thickness: 1),
                  )
                ],
              ),
            ),
          ),

          // ===================== ACTIONS LIST (HYPER ATTRACTIVE) =====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.price_change_rounded,
                    title: "Price Prediction",
                    subtitle: "Estimate vehicle instant market value",
                    color: const Color(0xFFA149CE),
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.PricePrediction_route,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ChatHelpBanner(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Chatscreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// STAT CARD (PREMIUM DEGRADÉ & HALO DE LUMIÈRE)
// ══════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color glowColor;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.glowColor,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: glowColor.withOpacity(0.12), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.02),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: glowColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: glowColor.withOpacity(0.2), width: 1),
                ),
                child: Icon(icon, color: glowColor, size: 24),
              ),
              const SizedBox(height: 24),
              Text(
                "$count",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: glowColor.withOpacity(0.5),
                      blurRadius: 15,
                    )
                  ]
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8C9FB5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ACTION TILE (FUTURISTIC RIDE)
// ══════════════════════════════════════════════════════════════
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF121B26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.2), width: 1),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF677C94),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.2),
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CHAT HELP BANNER (ULTRA SMART DESIGN)
// ══════════════════════════════════════════════════════════════
class _ChatHelpBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _ChatHelpBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2C3D), Color(0xFF0A2221)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppTheme.secondary.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondary.withOpacity(0.05),
              blurRadius: 25,
              spreadRadius: 1,
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withOpacity(0.1),
                border: Border.all(
                  color: AppTheme.secondary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppTheme.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "AI Copilot",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text("PRO", style: TextStyle(color: AppTheme.secondary, fontSize: 9, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ask anything about your vehicle status",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: const Text(
                "Chat",
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}