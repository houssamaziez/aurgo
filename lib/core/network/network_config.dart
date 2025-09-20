class NetworkConfig {
  static const String baseUrl = 'http://192.168.2.192:8000/api';
  static const Duration connectTimeout = Duration(seconds: 10); // ms
  static const Duration receiveTimeout = Duration(seconds: 10); // ms

  static String loginPath = '/auth/login';
  static String profilePath = '/auth/profile';
  static String updateProfilePath = '/auth/update-profile';
}
