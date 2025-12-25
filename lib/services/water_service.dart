import 'package:water_health_monitor/services/api_client.dart';

class WaterService {
  static Future<List<dynamic>> getWaterSamples({
    String? state,
    String? district,
  }) async {
    String query = "";

    if (state != null) query += "?state=$state";
    if (district != null) {
      query += query.isEmpty ? "?district=$district" : "&district=$district";
    }

    return await ApiClient.getRequest("/api/water$query");
  }

  static Future<Map<String, dynamic>> getSummary() async {
    return await ApiClient.getRequest("/api/summary");
  }

  static Future<Map<String, dynamic>> addWaterSample({
    required String location,
    required String state,
    required String district,
    required double ph,
    required double turbidity,
    required double bacterialCount,
    required double temperature,
    required String contaminationLevel,
  }) async {
    final body = {
      "location": location,
      "state": state,
      "district": district,
      "ph": ph,
      "turbidity": turbidity,
      "bacterial_count": bacterialCount,
      "temperature": temperature,
      "contamination_level": contaminationLevel,
    };

    return await ApiClient.postRequest("/api/water", body);
  }
}
