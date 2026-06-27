import 'package:flutter/foundation.dart';
class ApiConstants {
  static const serverUrl = 'https://manibase.ru';
  static const baseUrl = '$serverUrl/api';

  static String imageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$serverUrl$path';
  }
}