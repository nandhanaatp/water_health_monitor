import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/network_config.dart';

class ApiClient {
  static String get baseUrl => NetworkConfig.baseUrl;
  
  static void _logRequest(String method, String url, [Map<String, dynamic>? body]) {
    print('🌐 $method → $url');
    if (body != null) print('📦 Body: $body');
  }


  // -----------------------------
  // GET request
  // -----------------------------
  static Future<dynamic> getRequest(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    _logRequest('GET', url.toString());

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("❌ GET FAILED: ${response.body}");
      throw Exception("GET failed: ${response.statusCode}");
    }
  }

  // -----------------------------
  // POST request
  // -----------------------------
  static Future<dynamic> postRequest(
      String endpoint, Map<String, dynamic> body) async {

    final url = Uri.parse("$baseUrl$endpoint");
    _logRequest('POST', url.toString(), body);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      print("❌ POST FAILED: CODE ${response.statusCode}");
      print("RESPONSE: ${response.body}");
      throw Exception("POST failed: ${response.statusCode}");
    }
  }
}
