import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

const String baseUrl = "http://192.168.1.3:8000/garage/taule";

/// Envoie une image pour analyse de la tôlerie.
Future<String> creer_analyse_taule({
  required Uint8List image_file,
  required String token,
}) async {
  var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/image_analysis"));
  
  request.headers["Authorization"] = "Bearer $token";
  request.files.add(http.MultipartFile.fromBytes(
    "image_file",
    image_file,
    filename: "image.jpg",
    contentType: MediaType("image", "jpeg"),
  ));

  var res = await request.send();
  var body = await res.stream.bytesToString();
  if (res.statusCode != 200) throw Exception(body);
  
  return jsonDecode(body)["message"] ?? body;
}

/// Récupère la liste des analyses effectuées.
Future<List<dynamic>> fetchAnalyses({required String token}) async {
  final res = await http.get(
    Uri.parse("$baseUrl/taule_analyses"),
    headers: {"Authorization": "Bearer $token"},
  );
  if (res.statusCode != 200) throw Exception(res.body);
  
  return jsonDecode(res.body)["analyses"] ?? [];
}

/// Récupère les détails d'une analyse spécifique.
Future<Map<String, dynamic>> fetchAnalysisDetails({
  required String token, 
  required int analysisId
}) async {
  final res = await http.get(
    Uri.parse("$baseUrl/analysis_details?analysis_id=$analysisId"),
    headers: {"Authorization": "Bearer $token"},
  );
  if (res.statusCode != 200) throw Exception(res.body);
  
  return jsonDecode(res.body);
}

/// Lance une inspection vidéo complète.
Future<String> full_taule_inspection({
  required Uint8List video_file,
  required String token,
}) async {
  var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/video_analysis"));
  
  request.headers["Authorization"] = "Bearer $token";
  request.files.add(http.MultipartFile.fromBytes(
    "video",
    video_file,
    filename: "video.mp4",
    contentType: MediaType("video", "mp4"),
  ));

  final streamResp = await request.send();
  final response = await http.Response.fromStream(streamResp);
  if (response.statusCode != 200) throw Exception(response.body);
  
  return response.body;
}

/// Vérifie le statut d'une tâche d'analyse en arrière-plan.
Future<String> check_task_status({required String taskId, required String token}) async {
  final res = await http.get(
    Uri.parse("$baseUrl/task_status/$taskId"),
    headers: {"Authorization": "Bearer $token"},
  );
  if (res.statusCode != 200) throw Exception(res.body);
  
  return jsonDecode(res.body)["status"] ?? "";
}