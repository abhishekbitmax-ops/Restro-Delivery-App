import 'package:http/http.dart' as http;

/// 🌐 INDEPENDENT HTTP CLIENT
/// This client is INDEPENDENT of app lifecycle
/// It will NOT be cancelled when app goes to background or opens Google Maps
class BackgroundHttpClient {
  static final BackgroundHttpClient _instance = BackgroundHttpClient._internal();

  late http.Client _client;

  factory BackgroundHttpClient() {
    return _instance;
  }

  BackgroundHttpClient._internal() {
    // Create a persistent HTTP client that survives app lifecycle changes
    _client = http.Client();
    print("🌐 Independent HTTP Client initialized");
  }

  /// Get the independent HTTP client
  http.Client get client => _client;

  /// POST request that SURVIVES app going to background
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      print("📡 Background API call: ${url.path}");
      
      final response = await _client
          .post(
            url,
            headers: headers,
            body: body,
          )
          .timeout(timeout);

      print("✅ Background API response: ${response.statusCode}");
      return response;
    } catch (e) {
      print("❌ Background API error: $e");
      rethrow;
    }
  }

  /// GET request that SURVIVES app going to background
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      final response = await _client
          .get(
            url,
            headers: headers,
          )
          .timeout(timeout);

      return response;
    } catch (e) {
      print("❌ Background API error: $e");
      rethrow;
    }
  }

  /// Manually close if needed
  void close() {
    _client.close();
    print("🌐 HTTP Client closed");
  }
}
