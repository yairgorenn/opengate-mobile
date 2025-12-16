import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/token_screen.dart';
import 'screens/gate_screen.dart';

void main() {
  runApp(const OpenGateApp());
}

class OpenGateApp extends StatelessWidget {
  const OpenGateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenGate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/token': (context) => const TokenScreen(),
        '/gates': (context) => const GateScreen(),
      },
    );
  }
}
  