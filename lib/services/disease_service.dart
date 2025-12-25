import 'package:water_health_monitor/services/api_client.dart';

class DiseaseService {
  static Future<List<dynamic>> getAlerts({
    String? disease,
    String? district,
  }) async {
    String query = "";

    if (disease != null) query += "?disease=$disease";
    if (district != null) {
      query += query.isEmpty ? "?district=$district" : "&district=$district";
    }

    return await ApiClient.getRequest("/api/alerts$query");
  }

  static Future<Map<String, dynamic>> addDiseaseAlert({
    required String disease,
    required int cases,
    required String riskLevel,
    required String location,
    required String state,
    required String district,
  }) async {
    final body = {
      "disease": disease,
      "cases": cases,
      "risk_level": riskLevel,
      "location": location,
      "state": state,
      "district": district,
    };

    return await ApiClient.postRequest("/api/alerts", body);
  }
}
