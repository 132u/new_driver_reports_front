import 'dart:convert';
import 'package:driver_reports_app/core/constants/api_constants.dart';
import 'package:driver_reports_app/core/constants/app_version.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VersionScreen extends StatefulWidget {
  const VersionScreen({super.key});

  @override
  State<VersionScreen> createState() => _VersionScreenState();
}

class _VersionScreenState extends State<VersionScreen> {
  Map<String, dynamic>? versionInfo;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadVersion();
  }

  Future<void> loadVersion() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/version'),
      );

      if (response.statusCode == 200) {
        setState(() {
          versionInfo = jsonDecode(response.body);
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Версия'),
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : versionInfo == null
                ? const Text('Не удалось получить версию')
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'API Version: ${versionInfo!['version']}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Build: ${versionInfo!['buildDate']}',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Commit: ${versionInfo!['commit']}',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'UI Version: ${AppVersion.appVersion}',
                      ),
                    ],
                  ),
      ),
    );
  }
}
