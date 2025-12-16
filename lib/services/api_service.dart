import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://opengatesserver-production.up.railway.app';

  static Future<List<String>> getAllowedGates(String token) async {
  final uri = Uri.parse('$baseUrl/allowed_gates?token=$token');

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['allowed']);
    }

    if (response.statusCode == 401) {
      throw Exception('INVALID_TOKEN');
    }

    throw Exception('SERVER_ERROR_${response.statusCode}');
  } on Exception catch (e) {
    // אם זו שגיאה שאנחנו זרקנו בעצמנו – מעבירים הלאה
    if (e.toString().contains('INVALID_TOKEN') ||
        e.toString().contains('SERVER_ERROR')) {
      rethrow;
    }

    // אחרת – זו באמת שגיאת רשת
    throw Exception('NETWORK_ERROR');
  }
}

static Future<void> openGate({
  required String token,
  required String gate,
}) async {
  final uri = Uri.parse('$baseUrl/open');

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'gate': gate}),
    );

    if (response.statusCode == 200) return;

    if (response.statusCode == 401) {
      throw Exception('INVALID_TOKEN');
    }

    if (response.statusCode == 403) {
      throw Exception('FORBIDDEN');
    }

    if (response.statusCode == 409) {
      throw Exception('DEVICE_BUSY');
    }

    throw Exception('SERVER_ERROR_${response.statusCode}');
  } on Exception catch (e) {
    // כמו קודם: אם זו שגיאה לוגית שלנו - לא לדרוס
    final s = e.toString();
    if (s.contains('INVALID_TOKEN') ||
        s.contains('FORBIDDEN') ||
        s.contains('DEVICE_BUSY') ||
        s.contains('SERVER_ERROR')) {
      rethrow;
    }
    throw Exception('NETWORK_ERROR');
  }
}

static Future<String> getStatus() async {
  final uri = Uri.parse('$baseUrl/status');

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['status'] as String?) ?? 'unknown';
    }

    throw Exception('SERVER_ERROR_${response.statusCode}');
  } on Exception catch (e) {
    final s = e.toString();
    if (s.contains('SERVER_ERROR')) rethrow;
    throw Exception('NETWORK_ERROR');
  }
}

}
