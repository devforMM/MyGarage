import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../providers/TokenProvider.dart";
import "../services/audio_services.dart";
import "../routes.dart";
import "../theme/app_theme.dart";

class AllIssuesScreen extends StatefulWidget {
  const AllIssuesScreen({super.key});

  @override
  _AllIssuesScreenState createState() => _AllIssuesScreenState();
}

class _AllIssuesScreenState extends State<AllIssuesScreen> {
  List<dynamic> issues = [];
  bool loading = true;

  Future<void> loadIssues() async {
    try {
      final token = context.read<TokenProvider>().token;
      final data = await fetchIssues(token: token!);

      setState(() {
        issues = data;
        loading = false;
      });
    } catch (e) {
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
    loadIssues();
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
          "All your issues",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: issues.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.tertiary.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.car_crash_rounded,
                      size: 70,
                      color: AppTheme.tertiary.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No issues found",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: issues.length,
              itemBuilder: (context, index) {
                final issue = issues[index];

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
                        color: AppTheme.tertiary.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.car_crash_rounded,
                        color: AppTheme.tertiary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      "Issue ${issue['id'] ?? index + 1}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.build_circle_outlined,
                            size: 14,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Type: ${issue['classe'] ?? "N/A"}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.secondary,
                      size: 16,
                    ),
                    onTap: () async {
                      final token = context.read<TokenProvider>().token;
                      final details = await fetchIssueDetails(
                        token: token!,
                        issueId: issue['id'],
                      );
                      Navigator.pushNamed(
                        context,
                        Routes.Issue_details,
                        arguments: details,
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.addAudioAnalysis_route,
          );
        },
        backgroundColor: AppTheme.secondary,
        foregroundColor: AppTheme.primary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          "New Issue",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
        ),
      ),
    );
  }
}