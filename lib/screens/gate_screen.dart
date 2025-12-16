import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../config/gate_labels.dart';
import 'dart:async';

class GateScreen extends StatefulWidget {
  const GateScreen({super.key});

  @override
  State<GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends State<GateScreen> {
  bool _loading = true;
  String? _error; 
  List<String> _gates = [];
  bool _busy = false;
  String? _info;
  Timer? _pollTimer;
  Timer? _messageClearTimer;

  DateTime? _pollStart;
  static const int _pollIntervalSeconds = 2;
  static const int _pollTimeoutSeconds = 30;

  @override
  void dispose() {
  _stopPolling();
  _messageClearTimer?.cancel();
  super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadGates();
  }
  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollStart = null;
    }
  void _scheduleMessageClear() {
  _messageClearTimer?.cancel();

  _messageClearTimer = Timer(const Duration(seconds: 10), () {
    if (!mounted) return;
    setState(() {
      _info = null;
    });
  });
}
  
  void _startPolling() {
  _stopPolling();
  _pollStart = DateTime.now();

  _pollTimer = Timer.periodic(
    const Duration(seconds: _pollIntervalSeconds),
    (_) async {
      if (!mounted) return;

      // Timeout מקומי
      final start = _pollStart!;
      final elapsed = DateTime.now().difference(start).inSeconds;
      if (elapsed >= _pollTimeoutSeconds) {
        _stopPolling();
        setState(() {
          _busy = false;
          _info = 'הפתיחה נכשלה';
        });
        _scheduleMessageClear();
        return;
      }

      try {
        final status = await ApiService.getStatus();

        if (!mounted) return;

        if (status == 'pending') {
          // ממשיכים
          setState(() {
            _info = 'פותח את השער';
          });
          return;
        }

        if (status == 'opened') {
          _stopPolling();
          setState(() {
            _busy = false;
            _info = 'השער נפתח';
          });
          _scheduleMessageClear();
          return;
        }

        if (status == 'failed') {
          _stopPolling();
          setState(() {
            _busy = false;
            _info = 'הפתיחה נכשלה';
          });
          _scheduleMessageClear();
          return;
        }

        if (status == 'ready') {
          _stopPolling();
          setState(() {
            _busy = false;
            _info = null;
          });
          return;
        }

        // סטטוס לא מוכר - מפסיקים כדי לא להיתקע
        _stopPolling();
        setState(() {
          _busy = false;
          _info = 'הפתיחה נכשלה';
        });
        _scheduleMessageClear();
      } catch (e) {
        if (!mounted) return;
        // במקרה של שגיאת רשת בזמן polling - עוצרים ומציגים
        _stopPolling();
        setState(() {
          _busy = false;
          _info = 'הפתיחה נכשלה';
        });
        _scheduleMessageClear();
      }
    },
  );
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
        _error = 'שגיאה בטעינת שערים';
        _loading = false;
      });
    }
  }


Future<void> _onOpenGate(String gate) async {
  if (_busy || _pollTimer != null) return;

  setState(() {
    _busy = true;
    _info = 'שולח פקודת פתיחה...';
  });

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _info = 'No token';
    });
    Navigator.pushReplacementNamed(context, '/token');
    return;
  }

  try {
    await ApiService.openGate(token: token, gate: gate);

    if (!mounted) return;
    setState(() {
      _info = 'פותח שער...';
    });

    _startPolling();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _busy = false;
        _info = 'הפתיחה נכשלה';
      });
      _scheduleMessageClear();
    }

}


  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Gates'),
      actions: [
        IconButton(
          icon: const Icon(Icons.key),
          tooltip: 'Change token',
          onPressed: _busy
              ? null
              : () {
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
  children: [
    if (_info != null) ...[
      Text(_info!),
      const SizedBox(height: 12),
    ],
    ..._gates.map((gate) {
      final label = gateLabels[gate] ?? gate;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton(
          onPressed: _busy ? null : () => _onOpenGate(gate),
          child: Text(label),
        ),
      );
    }).toList(),
  ],
),

      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: body,
    );
  }
}
