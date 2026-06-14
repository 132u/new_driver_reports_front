// import 'package:flutter/foundation.dart';

// class ApiConstants {
//   static final String baseUrl = kIsWeb
//       ? 'http://localhost:5288/api'
//       : 'http://10.0.2.2:5288/api';

//   //static const String baseUrl = 'http://manibase.ru/api';
// }

import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return '/api';
    }

    return 'http://10.0.2.2:5288/api';
  }
}