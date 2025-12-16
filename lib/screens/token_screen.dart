import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _saving = false;

  Future<void> _saveAndContinue() async {
    final token = _controller.text.trim();
    if (token.isEmpty) return;

    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/gates');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Token')),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _saveAndContinue,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Save & Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
