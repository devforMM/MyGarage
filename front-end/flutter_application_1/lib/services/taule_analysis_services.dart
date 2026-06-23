import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

const String serverHost = "192.168.1.3";
const String baseUrl = "http://$serverHost:8000/garage/taule";

/// Uploads an image for damage detection analysis.
Future<String> uploadTauleImageAnalysis({
  required String token,
  required Uint8List imageBytes,
}) async {
  final request = http.MultipartRequest("POST", Uri.parse("$baseUrl/image_analysis"));
  
  request.headers["Authorization"] = "Bearer $token";
  request.files.add(http.MultipartFile.fromBytes(
    "image_file",
    imageBytes,
    filename: "image.jpg",
    contentType: MediaType("image", "jpeg"),
  ));

  final response = await request.send();
  final body = await response.stream.bytesToString();

  if (response.statusCode != 200) throw Exception(body);
  return jsonDecode(body)["message"];
}

/// Uploads a video for frame-by-frame inspection.
Future<String> uploadTauleVideoAnalysis({
  required String token,
  required Uint8List videoBytes,
}) async {
  final request = http.MultipartRequest("POST", Uri.parse("$baseUrl/video_analysis"));
  
  request.headers["Authorization"] = "Bearer $token";
  request.files.add(http.MultipartFile.fromBytes(
    "video",
    videoBytes,
    filename: "video.mp4",
    contentType: MediaType("video", "mp4"),
  ));

  final response = await http.Response.fromStream(await request.send());
  if (response.statusCode != 200) throw Exception(response.body);
  
  return response.body;
}

/// Fetches a list of all visual analyses for the user.
Future<List<dynamic>> fetchAnalyses({required String token}) async {
  final response = await http.get(
    Uri.parse("$baseUrl/taule_analyses"),
    headers: {"Authorization": "Bearer $token"},
  );

  if (response.statusCode != 200) throw Exception("Server error: ${response.body}");
  return jsonDecode(response.body)["analyses"] ?? [];
}

/// Fetches details for a specific analysis report.
Future<Map<String, dynamic>> fetchAnalysisDetails({
  required String token,
  required int analysisId,
}) async {
  final response = await http.get(
    Uri.parse("$baseUrl/analysis_details?analysis_id=$analysisId"),
    headers: {"Authorization": "Bearer $token"},
  );

  if (response.statusCode != 200) throw Exception("Server error: ${response.body}");
  return jsonDecode(response.body);
}

/// Checks the background processing status of a specific task.
Future<String> checkTaskStatus({required String taskId, required String token}) async {
  final response = await http.get(
    Uri.parse("$baseUrl/task_status/$taskId"),
    headers: {"Authorization": "Bearer $token"},
  );
  
  if (response.statusCode != 200) throw Exception(response.body);
  return jsonDecode(response.body)["status"];
}