import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_result.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:5288";
  // ⚠️ emulator = 10.0.2.2

  Future<LoginResult?> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 401) {
      return null;
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final token = data["jwtToken"];

      final decodedToken = JwtDecoder.decode(token);

      final role = decodedToken[
          'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

      return LoginResult(
        token: token,
        role: role,
      );
    }

    return null;
  }

  Future<bool> register(String name, String email, String password) async {
    final url = Uri.parse("$baseUrl/api/auth/register");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Register error: ${response.body}");
      return false;
    }
  }
}
