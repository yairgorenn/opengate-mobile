import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExistingToken();
  }

  Future<void> _loadExistingToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _controller.text = token;
    }
  }

  Future<void> _saveAndValidate() async {
    final token = _controller.text.trim();
    if (token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // אימות מול השרת
      await ApiService.getAllowedGates(token);

      // אם הצליח – שומרים
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/gates');
    } catch (e) {
  String message;

  final error = e.toString();

  if (error.contains('INVALID_TOKEN')) {
    message = 'Token לא תקין';
  } else if (error.contains('NETWORK_ERROR')) {
    message = 'שגיאת תקשורת עם השרת';
  } else {
    message = 'שגיאה כללית';
  }

  setState(() {
    _error = message;
    _loading = false;
  });
}

  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _controller.clear();

    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Token')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'OpenGate Token',
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _saveAndValidate,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Save & Continue'),
            ),
            TextButton(
              onPressed: _clearToken,
              child: const Text('Clear Token'),
            ),
          ],
        ),
      ),
    );
  }
}
