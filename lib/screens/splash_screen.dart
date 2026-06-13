import 'package:flutter/material.dart';
import '../core/api/token_storage.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    final token = await tokenStorage.getToken();

    if (!mounted) return;

    if (token == null || JwtDecoder.isExpired(token)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(),
        ),
      );
      return;
    }

    final decoded = JwtDecoder.decode(token);

    final role = decoded[
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(
          token: token,
          role: role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}