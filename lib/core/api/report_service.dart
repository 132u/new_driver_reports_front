import 'dart:convert';
import 'dart:typed_data';
import 'package:driver_reports_app/core/constants/api_constants.dart';

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

Future<void> updateReport(
  String id,
  Map<String, dynamic> data,
) async {
      final tokenStorage = TokenStorage();
    final token = await tokenStorage.getToken();
  final response = await http.put(
    Uri.parse(
      '${ApiConstants.baseUrl}/reports/$id',
    ),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Ошибка редактирования отчета',
    );
  }
}
  Future<void> createReport(Map<String, dynamic> data) async {
    final tokenStorage = TokenStorage();
    final token = await tokenStorage.getToken();
    final response =
        await _client.post("/reports", body: jsonEncode(data), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create report");
    }
  }

  Future<List<String>> uploadImages(List<Uint8List> files) async {
  print("UPLOAD START");

  final tokenStorage = TokenStorage();
  final token = await tokenStorage.getToken();

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(_client.baseUrl + "/files/upload"),
  );

  request.headers['Authorization'] = 'Bearer $token';

  for (int i = 0; i < files.length; i++) {
    final fileBytes = files[i];

    print("ADDING FILE #$i (${fileBytes.lengthInBytes} bytes)");

    request.files.add(
      http.MultipartFile.fromBytes(
        'files',
        fileBytes,
        filename: 'image_$i.jpg',
      ),
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

  throw Exception("Upload failed: ${response.statusCode} $respStr");
}
}
