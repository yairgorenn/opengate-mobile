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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Gates'),
      actions: [
        IconButton(
          icon: const Icon(Icons.key),
          tooltip: 'Change token',
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/token');
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(child: Text(_error!));
    } else {
      body = Padding(
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
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: body,
    );
  }
}
