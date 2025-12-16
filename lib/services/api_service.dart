import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://opengatesserver-production.up.railway.app';

  static Future<List<String>> getAllowedGates(String token) async {
    final uri = Uri.parse('$baseUrl/allowed_gates?token=$token');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['allowed']);
    }

    if (response.statusCode == 401) {
      throw Exception('INVALID_TOKEN');
    }

    throw Exception('SERVER_ERROR');
  }
}
