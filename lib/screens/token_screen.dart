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
  bool _hasExistingToken = false;


  @override
  void initState() {
    super.initState();
    _loadExistingToken();
  }

  Future<void> _loadExistingToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token != null && token.isNotEmpty) {
    _controller.text = token;
    setState(() {
      _hasExistingToken = true;
    });
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
    message = 'טוקן לא תקין';
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
      _hasExistingToken = false;
    });
  }

  @override
Widget build(BuildContext context) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: const Color(0xFF1565C0), // כחול
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              Text(
                'הגדרת טוקן',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Tahoma',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (_hasExistingToken)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    iconSize: 28,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/gates');
                    },
                  ),
                ),

              const SizedBox(height: 40),

              TextField(
                controller: _controller,
                style: const TextStyle(
                  fontFamily: 'Tahoma',
                  fontSize: 20,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'טוקן גישה',
                  labelStyle: const TextStyle(
                    fontFamily: 'Tahoma',
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white70),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_error != null)
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Tahoma',
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _loading ? null : _saveAndValidate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontFamily: 'Tahoma',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('שמירה והמשך'),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _clearToken,
                child: const Text(
                  'ניקוי טוקן',
                  style: TextStyle(
                    fontFamily: 'Tahoma',
                    color: Colors.white70,
                    fontSize: 14,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}


