import 'package:driver_reports_app/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
class ApiClient {
 // final String baseUrl = "http://10.0.2.2:5288";
  final String baseUrl = ApiConstants.baseUrl;
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt");
  }

  Future<http.Response> post(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final token = await _getToken();
    return await http.post(
      Uri.parse(ApiConstants.baseUrl + url),
      body: body,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> get(String url) async {
    final token = await _getToken();

    return await http.get(
      Uri.parse('$baseUrl$url'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}
