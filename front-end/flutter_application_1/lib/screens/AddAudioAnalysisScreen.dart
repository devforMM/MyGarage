import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import "../providers/TokenProvider.dart";
import "../services/audio_services.dart";
import "../theme/app_theme.dart";

class AddAudioAnalysisScreen extends StatefulWidget {
  const AddAudioAnalysisScreen({super.key});

  @override
  State<AddAudioAnalysisScreen> createState() => _AddAudioAnalysisScreenState();
}

class _AddAudioAnalysisScreenState extends State<AddAudioAnalysisScreen>
    with SingleTickerProviderStateMixin {

  final AudioRecorder recorder = AudioRecorder();

  bool isRecording = false;
  bool isSending = false;
  String? audioPath;
  int? audioSize;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    recorder.dispose();
    super.dispose();
  }

  // =====================================================
  // START RECORD
  // =====================================================
  Future<void> startRecording() async {
    if (await recorder.hasPermission()) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final path =
            "${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a";

        await recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 16000,
            bitRate: 128000,
          ),
          path: path,
        );

        setState(() {
          isRecording = true;
          audioPath = null;
          audioSize = null;
        });

        await Future.delayed(const Duration(seconds: 3));

        if (isRecording) {
          final filePath = await recorder.stop();

          // Attends que le fichier soit bien flushé
          await Future.delayed(const Duration(milliseconds: 500));

          if (filePath == null) throw Exception("filePath is null after stop");

          final file = File(filePath);
          if (!await file.exists()) {
            throw Exception("File does not exist: $filePath");
          }

          final size = await file.length();
          debugPrint("TAILLE AUDIO: $size bytes");

          if (size < 1000) {
            throw Exception(
                "File too small ($size bytes) — recording failed");
          }

          setState(() {
            isRecording = false;
            audioPath = filePath;
            audioSize = size;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Audio recorded successfully ✅ ($size bytes)"),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        setState(() => isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: $e"), backgroundColor: AppTheme.tertiary),
        );
      }
    }
  }

  // =====================================================
  // SEND AUDIO + NAVIGATE
  // =====================================================
  Future<void> sendAudio(String token) async {
    if (audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please record an audio first"),
        ),
      );
      return;
    }

    final file = File(audioPath!);
    final size = await file.length();
debugPrint("SEND AUDIO: $size bytes from $audioPath");

    if (size < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid file ($size bytes)")),
      );
      return;
    }

    try {
      setState(() => isSending = true);

      final audioBytes = await file.readAsBytes();
          debugPrint("BYTES READ: ${audioBytes.length}");
      final message = await createAudioIssue(token: token, audioBytes: audioBytes);

      setState(() => isSending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.success),
      );

      Navigator.pushReplacementNamed(context, Routes.AllIssues_route);
    } catch (e) {
      setState(() => isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: $e"), backgroundColor: AppTheme.tertiary),
      );
    }
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final token = Provider.of<TokenProvider>(context, listen: false).token!;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Audio Analysis",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 19,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // =====================================================
              // MIC ICON WITH PULSE
              // =====================================================
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isRecording ? _pulseAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording
                        ? AppTheme.tertiary.withOpacity(0.12)
                        : audioPath != null
                            ? const Color(0xFF2ECC71).withOpacity(0.1)
                            : AppTheme.secondary.withOpacity(0.08),
                    border: Border.all(
                      color: isRecording
                          ? AppTheme.tertiary.withOpacity(0.7)
                          : audioPath != null
                              ? const Color(0xFF2ECC71).withOpacity(0.6)
                              : AppTheme.secondary.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isRecording
                            ? AppTheme.tertiary.withOpacity(0.25)
                            : audioPath != null
                                ? const Color(0xFF2ECC71).withOpacity(0.15)
                                : AppTheme.secondary.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isRecording
                        ? Icons.mic_rounded
                        : audioPath != null
                            ? Icons.check_circle_rounded
                            : Icons.mic_none_rounded,
                    size: 60,
                    color: isRecording
                        ? AppTheme.tertiary
                        : audioPath != null
                            ? const Color(0xFF2ECC71)
                            : AppTheme.secondary,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // =====================================================
              // STATUS TEXT
              // =====================================================
              Text(
                isRecording
                    ? "Recording..."
                    : audioPath != null
                        ? "Audio ready ✅"
                        : "Ready to record",
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 8),

              // =====================================================
              // SUB STATUS
              // =====================================================
              Text(
                isRecording
                    ? "Duration: 3 seconds"
                    : audioPath != null && audioSize != null
                        ? "${(audioSize! / 1024).toStringAsFixed(1)} KB recorded"
                        : "Tap the button below to begin",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.45),
                  letterSpacing: 0.2,
                ),
              ),

              const Spacer(flex: 2),

              // =====================================================
              // AUDIO READY CARD
              // =====================================================
              if (audioPath != null && !isRecording)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151F2C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2ECC71).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.audiotrack_rounded,
                            color: Color(0xFF2ECC71), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "audio.m4a",
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (audioSize != null)
                              Text(
                                "${(audioSize! / 1024).toStringAsFixed(1)} KB · 3 seconds",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Re-record icon button
                      GestureDetector(
                        onTap: isRecording ? null : startRecording,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.refresh_rounded,
                              color: Colors.white60, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

              // =====================================================
              // RECORD BUTTON
              // =====================================================
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRecording
                        ? AppTheme.tertiary.withOpacity(0.15)
                        : audioPath != null
                            ? const Color(0xFF112E20)
                            : const Color(0xFF152A38),
                    foregroundColor: isRecording
                        ? AppTheme.tertiary
                        : audioPath != null
                            ? const Color(0xFF2ECC71)
                            : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isRecording
                            ? AppTheme.tertiary.withOpacity(0.4)
                            : audioPath != null
                                ? const Color(0xFF2ECC71).withOpacity(0.3)
                                : AppTheme.secondary.withOpacity(0.2),
                      ),
                    ),
                  ),
                  onPressed: isRecording ? null : startRecording,
                  icon: Icon(
                    isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                    size: 20,
                  ),
                  label: Text(
                    isRecording
                        ? "Recording..."
                        : audioPath != null
                            ? "Re-record"
                            : "Start Recording",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // =====================================================
              // ANALYSE BUTTON
              // =====================================================
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: audioPath != null && !isSending
                        ? AppTheme.secondary
                        : AppTheme.secondary.withOpacity(0.2),
                    foregroundColor: audioPath != null && !isSending
                        ? AppTheme.surface
                        : Colors.white30,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isSending || audioPath == null
                      ? null
                      : () => sendAudio(token),
                  icon: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.surface,
                          ),
                        )
                      : const Icon(Icons.analytics_outlined, size: 20),
                  label: Text(
                    isSending ? "Analyzing..." : "Start Audio Analysis",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}