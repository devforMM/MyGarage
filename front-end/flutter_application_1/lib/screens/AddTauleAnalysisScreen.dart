import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:provider/provider.dart";
import 'dart:convert';
import 'dart:typed_data';
import "../providers/TokenProvider.dart";
import "../services/taule_analysis_services.dart";
import "../routes.dart";
import "../theme/app_theme.dart";

class AddTauleAnalysisScreen extends StatefulWidget {
  const AddTauleAnalysisScreen({super.key});

  @override
  _AddTauleAnalysisScreenState createState() => _AddTauleAnalysisScreenState();
}

class _AddTauleAnalysisScreenState extends State<AddTauleAnalysisScreen> {
  Uint8List? selectedImageBytes;
  Uint8List? selectedVideoBytes;
  bool isUploading = false;

  // ✅ Message shown while polling task status
  String statusMessage = "";

  // ================= PICK IMAGE =================
  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        selectedImageBytes = bytes;
        selectedVideoBytes = null;
      });
    }
  }

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        selectedImageBytes = bytes;
        selectedVideoBytes = null;
      });
    }
  }

  // ================= PICK VIDEO =================
  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        selectedVideoBytes = bytes;
        selectedImageBytes = null;
      });
    }
  }

  // ================= UPLOAD IMAGE =================
  Future<void> uploadImageAnalysis() async {
    if (selectedImageBytes == null) return;
    try {
      setState(() => isUploading = true);
      final token = context.read<TokenProvider>().token;
      await uploadTauleImageAnalysis(
        imageBytes: selectedImageBytes!,
        token: token!,
      );
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image analysis uploaded successfully ✅"),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pushNamed(context, Routes.AllAnalyses_route);
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: AppTheme.tertiary),
      );
    }
  }

  // ================= UPLOAD VIDEO WITH POLLING =================
  Future<void> uploadVideoAnalysis() async {
    if (selectedVideoBytes == null) return;
    try {
      // ✅ Step 1 — upload, show "Sending video..."
      setState(() {
        isUploading = true;
        statusMessage = "Sending the video...";
      });

      final token = context.read<TokenProvider>().token!;

      final responseBody = await uploadTauleVideoAnalysis(
        videoBytes: selectedVideoBytes!,
        token: token,
      );

      final taskId = jsonDecode(responseBody)["task_id"];

      // ✅ Step 2 — polling, show "Video analysis in progress..."
      setState(() => statusMessage = "Video analysis in progress...");

      String status = "pending";
      while (status == "pending" || status == "started") {
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        status = await checkTaskStatus(taskId: taskId, token: token);
      }

      setState(() {
        isUploading = false;
        statusMessage = "";
      });

      if (!mounted) return;

      if (status == "done") {
        // ✅ Step 3 — success → snackbar and navigation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Video analysis completed successfully ✅"),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pushNamed(context, Routes.AllAnalyses_route);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Video processing failed ❌"),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
        statusMessage = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: AppTheme.tertiary),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text(
          "Create analysis",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= PREVIEW CONTAINER =================
            if (selectedImageBytes != null || selectedVideoBytes != null) ...[
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: selectedImageBytes != null
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.memory(selectedImageBytes!, height: 200, fit: BoxFit.cover),
                        )
                      : Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_camera_back_rounded, color: AppTheme.secondary, size: 44),
                              SizedBox(height: 10),
                              Text(
                                "Selected video",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ================= SECTION IMAGE =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151F2C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.image_rounded, color: Colors.white70, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Image analysis",
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondary,
                            foregroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: isUploading ? null : pickImageFromGallery,
                          icon: const Icon(Icons.photo_library_outlined, size: 18),
                          label: const Text("Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondary,
                            foregroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: isUploading ? null : pickImageFromCamera,
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: const Text("Camera", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  if (selectedImageBytes != null) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isUploading ? null : uploadImageAnalysis,
                      child: isUploading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text("Send image analysis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text("OR", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
              ],
            ),
            const SizedBox(height: 20),

            // ================= SECTION VIDEO =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151F2C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.videocam_rounded, color: Colors.white70, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Video analysis",
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF263340),
                      foregroundColor: AppTheme.secondary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: isUploading ? null : pickVideo,
                    icon: const Icon(Icons.video_library_rounded, size: 18),
                    label: const Text("Select a video", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  if (selectedVideoBytes != null) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: AppTheme.primary,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isUploading ? null : uploadVideoAnalysis,
                      child: isUploading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primary,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  statusMessage,
                                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          : const Text("Send video analysis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}