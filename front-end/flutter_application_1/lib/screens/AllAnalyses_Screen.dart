import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../providers/TokenProvider.dart";
import "../services/taule_analysis_services.dart";
import "package:flutter_application_1/routes.dart";
import "../theme/app_theme.dart";

class AllAnalyses_Screen extends StatefulWidget {
  const AllAnalyses_Screen({super.key});

  @override
  _AllAnalyses_Screenstate createState() => _AllAnalyses_Screenstate();
}

class _AllAnalyses_Screenstate extends State<AllAnalyses_Screen> {
  List<dynamic> analyses = [];
  bool loading = true;
  bool _isFetchingDetails = false; // Sécurité pour bloquer les doubles clics

  Future<void> loadAnalyses() async {
    try {
      final token = context.read<TokenProvider>().token;
      final data = await fetchAnalyses(token: token!);

      if (!mounted) return;
      setState(() {
        analyses = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadAnalyses();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.secondary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text(
          "All your analyses",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: AppTheme.secondary),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.dashboard_route,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: analyses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.image_search_rounded,
                      size: 70,
                      color: AppTheme.secondary.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No analysis found",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: analyses.length,
                  itemBuilder: (context, index) {
                    final analysis = analyses[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151F2C),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.03)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppTheme.secondary.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.analytics_rounded,
                            color: AppTheme.secondary,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          "Analysis ${analysis['id'] ?? index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.layers_outlined,
                                size: 14,
                                color: Colors.white.withOpacity(0.4),
                              ),
                              const SizedBox(width: 4),
                              // L'Expanded force le texte à prendre uniquement l'espace disponible restant
                              
                            ],
                          ),
                        ),
                                                trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppTheme.secondary,
                          size: 16,
                        ),
                        onTap: _isFetchingDetails
                            ? null // Désactive le clic si un chargement est en cours
                            : () async {
                                setState(() => _isFetchingDetails = true);
                                try {
                                  final token = context.read<TokenProvider>().token;
                                  final details = await fetchAnalysisDetails(
                                    token: token!,
                                    analysisId: analysis['id'],
                                  );

                                  if (!mounted) return;
                                  Navigator.pushNamed(
                                    context,
                                    Routes.Analysis_details,
                                    arguments: details,
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error fetching details: $e")),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isFetchingDetails = false);
                                  }
                                }
                              },
                      ),
                    );
                  },
                ),
                // Overlay de chargement discret si on attend les détails
                if (_isFetchingDetails)
  Positioned.fill(
    child: Container(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.secondary),
      ),
    ),
  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.AddTauleAnalysis_route,
          );
        },
        backgroundColor: AppTheme.secondary,
        foregroundColor: AppTheme.primary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          "New Analysis",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
        ),
      ),
    );
  }
}