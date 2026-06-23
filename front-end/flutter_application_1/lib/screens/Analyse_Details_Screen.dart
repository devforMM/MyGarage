import "package:flutter/material.dart";
import "package:video_player/video_player.dart";
import "../theme/app_theme.dart";

class AnalysisDetailsScreen extends StatefulWidget {
  const AnalysisDetailsScreen({super.key});

  @override
  State<AnalysisDetailsScreen> createState() => _AnalysisDetailsScreenState();
}

class _AnalysisDetailsScreenState extends State<AnalysisDetailsScreen> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _videoError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final analyse = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final String type = analyse['type'] ?? 'taule';
    final bool isVideo = type == 'video';

    if (isVideo && _videoController == null) {
      final int id = analyse['id'];
      final videoUrl = "http://192.168.1.3:8000/garage/taule/video/$id";
      _initVideo(videoUrl);
    }
  }

  Future<void> _initVideo(String url) async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      setState(() => _videoInitialized = true);
    } catch (e) {
      setState(() => _videoError = true);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyse = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    const baseurl = "192.168.1.3";
    final String type = analyse['type'] ?? 'taule';
    final bool isVideo = type == 'video';

    final String? analysedPath = analyse['analysed_path'];
    final String? imagePath = analyse['analysed_image'];

    final String imageUrl = (!isVideo && (analysedPath ?? imagePath) != null)
        ? "http://$baseurl:8000/images/${analysedPath ?? imagePath}"
        : "";

    final raw = analyse['detections'];
    List<String> detectionLabels = [];
    if (raw is List) {
      for (final d in raw) {
        if (d is Map) {
          detectionLabels.add(d['label']?.toString() ?? '?');
        } else if (d is String) {
          detectionLabels.add(d);
        }
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text(
          "Analysis Details",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCard(
              icon: Icons.info_outline_rounded,
              label: "ID",
              value: "${analyse['id'] ?? 'N/A'}",
            ),
            const SizedBox(height: 12),

            if (analyse['date'] != null) ...[
              _InfoCard(
                icon: Icons.calendar_today_rounded,
                label: "Date",
                value: analyse['date'].toString(),
              ),
              const SizedBox(height: 12),
            ],

            _InfoCard(
              icon: isVideo ? Icons.videocam_outlined : Icons.image_outlined,
              label: "Type",
              value: isVideo ? "Vidéo" : "Image",
            ),
            const SizedBox(height: 16),

            // ===================== Detections =====================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151F2C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.03)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics_rounded, color: AppTheme.secondary, size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Detections",
                        style: TextStyle(fontSize: 13, color: AppTheme.border, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  detectionLabels.isEmpty
                      ? const Text(
                          "No detections",
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: detectionLabels.map((label) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.secondary.withOpacity(0.25),
                                ),
                              ),
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: AppTheme.secondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              isVideo ? "Analyzed video" : "Analyzed image",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),

            // ===================== MEDIA RENDER =====================
            if (!isVideo) _ImageSection(imageUrl: imageUrl),
            if (isVideo) _buildVideoPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoError) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: AppTheme.tertiary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.tertiary.withOpacity(0.15)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: AppTheme.tertiary, size: 44),
              SizedBox(height: 10),
              Text(
                "Unable to load the video",
                style: TextStyle(color: AppTheme.tertiary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    if (!_videoInitialized) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: const Color(0xFF151F2C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.secondary),
              SizedBox(height: 14),
              Text(
                "Video loading...",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: const Color(0xFF151F2C),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              color: const Color(0xFF0F1722),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _videoController!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: AppTheme.secondary,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                      });
                    },
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      _videoController!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppTheme.secondary,
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// INFO CARD
// ══════════════════════════════════════════════
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151F2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.secondary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.border, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// IMAGE SECTION
// ══════════════════════════════════════════════
class _ImageSection extends StatelessWidget {
  final String imageUrl;
  const _ImageSection({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: const Color(0xFF151F2C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 48,
            color: AppTheme.secondary.withOpacity(0.3),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 280,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 280,
            color: const Color(0xFF151F2C),
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.secondary),
            ),
          );
        },
        errorBuilder: (context, error, stack) {
          return Container(
            height: 280,
            decoration: BoxDecoration(
              color: AppTheme.tertiary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.tertiary.withOpacity(0.15)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_rounded, color: AppTheme.tertiary, size: 44),
                  SizedBox(height: 10),
                  Text(
                    "Loading error",
                    style: TextStyle(color: AppTheme.tertiary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}