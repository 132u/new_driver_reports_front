import 'package:flutter/foundation.dart';
// class ApiConstants {
//   static String get baseUrl {
//     return 'http://localhost:5288/api';
//   }

//   static String get serverUrl {
//     return 'http://localhost:5288';
//   }

//   static String imageUrl(String path) {
//     if (path.startsWith('http')) return path;
//     return '$serverUrl$path';
//   }
// }
class ApiConstants {
  static String get baseUrl {
    // if (kIsWeb) {
    //   return '/api';
    // }

    return 'http://manibase.ru/api';
  }

  static String get serverUrl {
    // if (kIsWeb) {
    //   return '';
    // }

    return 'http://manibase.ru';
  }

  static String imageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$serverUrl$path';
  }
}