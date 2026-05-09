import 'dart:convert';
import 'api_client.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ReportService {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> getReports() async {
    final response = await _client.get("/api/reports");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed to load reports");
  }

  // 🚀 СОЗДАНИЕ ОТЧЕТА
//   Future<void> createReport(Map<String, dynamic> data) async {
//  final tokenStorage = TokenStorage();
//   final token = await tokenStorage.getToken();

//     final response = await _client.post(
//       "/api/reports",
//       body: jsonEncode(data),
//       headers:  {
//         'Content-Type': 'application/json',
//        'Authorization': 'Bearer $token',
//       }
//     );

//     if (response.statusCode != 200 &&
//         response.statusCode != 201) {
//       throw Exception("Failed to create report");
//     }
//   }

  Future<void> createReport(Map<String, dynamic> data) async {
    final tokenStorage = TokenStorage();
    final token = await tokenStorage.getToken();
    final response =
        await _client.post("/api/reports", body: jsonEncode(data), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create report");
    }
  }

  Future<List<String>> uploadImages(List<File> files) async {
    print("UPLOAD START");

    final tokenStorage = TokenStorage();
    final token = await tokenStorage.getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(_client.baseUrl + "/api/files/upload"),
    );

    request.headers['Authorization'] = 'Bearer $token';

    for (var file in files) {
      print("ADDING FILE: ${file.path}");

      request.files.add(
        await http.MultipartFile.fromPath('files', file.path), // 👈 важно
      );
    }

    print("SENDING REQUEST...");

    var response = await request.send();

    final respStr = await response.stream.bytesToString();

    print("STATUS: ${response.statusCode}");
    print("BODY: $respStr");

    if (response.statusCode == 200) {
      final data = jsonDecode(respStr);
      return List<String>.from(data["urls"]);
    }

    throw Exception("Upload failed");
  }
}
