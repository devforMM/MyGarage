import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';

class IssueDetailsScreen extends StatefulWidget {
  const IssueDetailsScreen({super.key});

  @override
  State<IssueDetailsScreen> createState() => _IssueDetailsScreenState();
}

class _IssueDetailsScreenState extends State<IssueDetailsScreen> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // Abonnements aux Streams pour éviter les fuites de mémoire
  StreamSubscription? _onCompleteSub;
  StreamSubscription? _onDurationSub;
  StreamSubscription? _onPositionSub;
  StreamSubscription? _onStateSub;

  @override
  void initState() {
    super.initState();

    _onCompleteSub = player.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });

    _onDurationSub = player.onDurationChanged.listen((d) {
      setState(() => duration = d);
    });

    _onPositionSub = player.onPositionChanged.listen((p) {
      setState(() => position = p);
    });

    _onStateSub = player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _onCompleteSub?.cancel();
    _onDurationSub?.cancel();
    _onPositionSub?.cancel();
    _onStateSub?.cancel();
    player.dispose();
    super.dispose();
  }

  Future<void> toggleAudio(String url) async {
    try {
      if (isPlaying) {
        await player.pause();
        setState(() => isPlaying = false);
        return;
      }

      if (position > Duration.zero && position < duration) {
        await player.resume();
        setState(() => isPlaying = true);
        return;
      }

      setState(() => isLoading = true);
      debugPrint("URL AUDIO: $url");

      // Use UrlSource to play directly from remote URL — more reliable on mobile
      await player.play(UrlSource(url));

      setState(() {
        isPlaying = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isPlaying = false;
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Audio error: $e")),
        );
      }
    }
  }

  Future<void> stopAudio() async {
    await player.stop();
    setState(() {
      isPlaying = false;
      position = Duration.zero;
    });
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, "0");
    if (d.inHours > 0) {
      return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
    }
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  double get _progress {
    if (duration.inSeconds == 0) return 0;
    return position.inSeconds / duration.inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final issue = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final String? audioPath = issue['audio_path'];
    const baseurl = "192.168.1.3";

    final String audioUrl = audioPath != null
        ? "http://$baseurl:8000/images/${audioPath.startsWith('/') ? audioPath.substring(1) : audioPath}".replaceAll('audio.m4a', 'audio.wav')
        : "";

    debugPrint("Audio URL built: $audioUrl");

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Issue Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ID CARD
              _InfoCard(
                icon: Icons.tag,
                iconColor: AppTheme.tertiary,
                label: "Issue ID",
                value: "${issue['id'] ?? 'N/A'}",
              ),
              const SizedBox(height: 14),

              // TYPE CARD
              _InfoCard(
                icon: Icons.car_repair,
                iconColor: AppTheme.secondary,
                label: "Predicted Class",
                value: "${issue['predicted_class'] ?? 'N/A'}",
              ),
              const SizedBox(height: 28),

              // AUDIO SECTION TITLE
              const Row(
                children: [
                  Icon(Icons.graphic_eq, color: AppTheme.secondary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Audio Recording",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 14),

              // AUDIO PLAYER CARD
              if (audioPath != null && audioPath.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF112030),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.secondary.withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Waveform decoration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(24, (i) {
                          final heights = [
                            10.0, 18.0, 28.0, 22.0, 14.0, 30.0, 20.0,
                            26.0, 12.0, 24.0, 32.0, 18.0, 28.0, 16.0,
                            22.0, 30.0, 14.0, 26.0, 20.0, 12.0, 28.0,
                            18.0, 24.0, 10.0,
                          ];
                          final isActive = duration.inSeconds > 0 && i < (_progress * 24).round();
                          return Container(
                            width: 3,
                            height: heights[i],
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.secondary
                                  : AppTheme.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // Player Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Stop Button
                          GestureDetector(
                            onTap: stopAudio,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: const Icon(
                                Icons.stop,
                                color: Colors.white54,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Main Play/Pause Button
                          GestureDetector(
                            onTap: isLoading ? null : () => toggleAudio(audioUrl),
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.secondary,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.secondary.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      isPlaying ? Icons.pause : Icons.play_arrow,
                                      size: 36,
                                      color: AppTheme.primary,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Forward Button (+10s)
                          GestureDetector(
                            onTap: () async {
                              final newPos = position + const Duration(seconds: 10);
                              await player.seek(
                                newPos > duration ? duration : newPos,
                              );
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: const Icon(
                                Icons.forward_10,
                                color: Colors.white54,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Timeline Slider
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: AppTheme.secondary,
                          inactiveTrackColor: AppTheme.secondary.withOpacity(0.15),
                          thumbColor: AppTheme.secondary,
                          overlayColor: AppTheme.secondary.withOpacity(0.15),
                        ),
                        child: Slider(
                          min: 0,
                          max: duration.inSeconds.toDouble().clamp(0.001, double.infinity),
                          value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble()),
                          onChanged: (value) async {
                            await player.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),

                      // Time Labels
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Status Subtitle
                      Text(
                        isLoading
                            ? "Chargement..."
                            : isPlaying
                                ? "Lecture en cours..."
                                : position > Duration.zero
                                    ? "En pause"
                                    : "Appuyez pour lire",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // FALLBACK EMTPY AUDIO CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF112030),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.tertiary.withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mic_off,
                        size: 44, 
                        color: AppTheme.tertiary.withOpacity(0.4)
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Aucun enregistrement audio disponible",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// INFO CARD WIDGET
// =====================================================
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF112030),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.1),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.45),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}