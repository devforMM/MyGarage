import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

const String baseUrl = "192.168.1.3:8000";

/// Sends an audio file to the backend for diagnostic processing.
Future<String> createAudioIssue({
  required String token,
  required Uint8List audioBytes,
}) async {
  final uri = Uri.http(baseUrl, "/garage/audio/issues");
  final request = http.MultipartRequest("POST", uri);
  
  request.headers["Authorization"] = "Bearer $token";
  request.files.add(
    http.MultipartFile.fromBytes(
      "audio_file",
      audioBytes,
      filename: "audio.m4a",
    ),
  );

  final response = await request.send();
  final body = await response.stream.bytesToString();
  
  if (response.statusCode != 200) throw Exception("Failed to upload: $body");
  
  return jsonDecode(body)["message"];
}

/// Retrieves a list of all audio diagnostic reports for the authenticated user.
Future<List<dynamic>> fetchIssues({required String token}) async {
  final uri = Uri.http(baseUrl, "/garage/audio/issues");
  final response = await http.get(uri, headers: {"Authorization": "Bearer $token"});

  if (response.statusCode != 200) throw Exception("Server error: ${response.body}");

  return jsonDecode(response.body)["issues"] ?? [];
}

/// Fetches detailed information for a specific audio diagnostic report.
Future<Map<String, dynamic>> fetchIssueDetails({
  required String token,
  required int issueId,
}) async {
  final uri = Uri.http(baseUrl, "/garage/audio/issues/$issueId");
  final response = await http.get(uri, headers: {"Authorization": "Bearer $token"});

  if (response.statusCode != 200) throw Exception("Server error: ${response.body}");

  return jsonDecode(response.body);
}