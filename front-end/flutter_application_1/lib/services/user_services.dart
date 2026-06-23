import 'dart:convert';
import 'package:http/http.dart' as http;


const baseurl="192.168.1.3";
Future<dynamic> login({required String email,required String password,}) async{
  final reponse=await http.post(
    Uri.parse("http://$baseurl:8000/garage/user/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email":email,
      "password":password
    })
  );
  if (reponse.statusCode != 200) {
    try {
      final error = jsonDecode(reponse.body);
      throw Exception(error['detail'] ?? 'Erreur de connexion');
    } catch (e) {
      throw Exception('Erreur de connexion : ${reponse.body}');
    }
  }
  final data=jsonDecode(reponse.body);
  return data;
}


Future<String> register({
  required String email,
  required String password,
  required String nom,
  required String prenom,
  required String numTel,
  required String adresse,
}) async {
  final reponse = await http.post(
    Uri.parse("http://$baseurl:8000/garage/user/register"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password,
      "nom": nom,
      "prenom": prenom,
      "num_tel": numTel,
      "adresse": adresse,
    }),
  );
  if (reponse.statusCode != 200) {
    try {
      final error = jsonDecode(reponse.body);
      throw Exception(error['detail'] ?? 'Erreur lors de l\'inscription');
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription : ${reponse.body}');
    }
  }
  final data = jsonDecode(reponse.body);
  return data["message"];
}

Future<dynamic> dashboard({
  required String token
}) async {
  final response = await http.get(
    Uri.parse("http://$baseurl:8000/garage/user/dashboard"),
    headers: {"Content-Type": "application/json",
    "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
  final data = jsonDecode(response.body);
  return data;
}

Future<void> logout({
  String? token,
}) async {
  try {
    final response = await http.post(
      Uri.parse("http://$baseurl:8000/garage/user/logout"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      // Local logout remains valid même si le backend ne répond pas correctement.
      return;
    }
  } catch (_) {
    // Ignorer les erreurs de logout côté API pour ne pas bloquer la déconnexion locale.
  }
}

Future<dynamic> predictPrice({
  required int year,
  required double kilometres,
  required String make,
  required String model,
  required String trim,
  required String fuel,
  required String transmission,
  required String bodyType,
  required int doors,
  required int seats,
  required double engineSize,
  required double enginePower,
  required String driveTrain,
  required String color,
  required String token
}) async {

  final response = await http.post(
    Uri.parse("http://$baseurl:8000/garage/user/predict"),
    headers: {"Content-Type": "application/json",
    "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "year": year,
      "kilometres": kilometres,
      "make": make,
      "model": model,
      "trim": trim,
      "fuel": fuel,
      "transmission": transmission,
      "body_type": bodyType,
      "doors": doors,
      "seats": seats,
      "engine_size": engineSize,
      "engine_power": enginePower,
      "drive_train": driveTrain,
      "color": color,

    }),
  );

  if (response.statusCode != 200) {
    try {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Erreur de prédiction');
    } catch (e) {
      throw Exception('Erreur de prédiction : ${response.body}');
    }
  } else {
    final data = jsonDecode(response.body);
    return data["price"];
  }
}


Future<Stream<String>> chat({
  required String token,
  required String query,
}) async {
  final client = http.Client();
  
  final request = http.Request(
    'POST',
    Uri.parse('http://$baseurl:8000/garage/user/chat'),
  );
  
  request.headers.addAll({
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  });
  
  request.body = jsonEncode({
    'query': query,
  });

  try {
    final streamedResponse = await client.send(request);

    if (streamedResponse.statusCode != 200) {
      final body = await streamedResponse.stream.bytesToString();
      throw Exception('Erreur ${streamedResponse.statusCode} : $body');
    }

    // ✅ Transform le stream SSE en strings
    return streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .map((line) {
          // ❌ PAS de trim() avant!
          if (line.startsWith('data: ')) {
            // ✅ Enlever JUSTE "data: " prefix, pas les espaces du texte!
            return line.substring(6);  // "data: ".length = 6
          }
          
          // ✅ Ignorer [DONE]
          if (line.trim() == '[DONE]') {
            return '';
          }
          
          return '';
        })
        .where((line) => line.isNotEmpty);

  } catch (e) {
    throw Exception('Échec de la récupération du chat : $e');
  }
}