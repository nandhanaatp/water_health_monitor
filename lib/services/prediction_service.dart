import 'package:water_health_monitor/services/api_client.dart';


class PredictionService {
  static Future<Map<String, dynamic>> predictRisk({
    required double ph,
    required double turbidity,
    required int bacterialCount,
    required double temperature,
    required String location,
  }) async {
    final body = {
      "ph": ph,
      "turbidity": turbidity,
      "bacterial_count": bacterialCount,
      "temperature": temperature,
      "location": location,
    };

    return await ApiClient.postRequest("/api/predict", body);
  }
}
