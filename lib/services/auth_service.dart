import 'api_client.dart';

class AuthService {
  static String? _currentUser;
  static String? _currentRole;
  static int? _userId;

  static String? get currentUser => _currentUser;
  static String? get currentRole => _currentRole;
  static int? get userId => _userId;
  static bool get isLoggedIn => _currentUser != null;

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await ApiClient.postRequest("/api/login", {
        "username": username,
        "password": password
      });

      if (response['status'] == 'success') {
        _currentUser = username;
        _currentRole = response['role'];
        _userId = response['user_id'];
      }

      return response;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  static void logout() {
    _currentUser = null;
    _currentRole = null;
    _userId = null;
  }
}