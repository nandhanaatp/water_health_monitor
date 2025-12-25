class NetworkConfig {
  // 🔧 UPDATE THIS IP WHEN WIFI CHANGES
  static const String currentIP = "10.13.8.135";
  static const String port = "5000";
  
  // Debug info
  static void printConfig() {
    print('🌐 Backend URL: $baseUrl');
  }
  
  static String get baseUrl => "http://$currentIP:$port";
}