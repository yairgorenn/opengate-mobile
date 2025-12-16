import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../config/gate_labels.dart';

class GateScreen extends StatefulWidget {
  const GateScreen({super.key});

  @override
  State<GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends State<GateScreen> {
  bool _loading = true;
  String? _error;
  List<String> _gates = [];

  @override
  void initState() {
    super.initState();
    _loadGates();
  }

  Future<void> _loadGates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('NO_TOKEN');
      }

      final gates = await ApiService.getAllowedGates(token);

      if (!mounted) return;
      setState(() {
        _gates = gates;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      if (e.toString().contains('INVALID_TOKEN')) {
        Navigator.pushReplacementNamed(context, '/token');
        return;
      }

      setState(() {
        _error = 'Failed to load gates';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gates')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _gates.map((gate) {
            final label = gateLabels[gate] ?? gate;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: () {},
                child: Text(label),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
