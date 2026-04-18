import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

final api = ApiService();

void main() {
  runApp(const HomePilotApp());
}

class HomePilotApp extends StatelessWidget {
  const HomePilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF18605D),
      primary: const Color(0xFF18605D),
      secondary: const Color(0xFFE59B32),
      surface: const Color(0xFFF7F2EA),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'HomePilot AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4EFE7),
        textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
          headlineLarge: GoogleFonts.sourceSerif4(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2A2C),
          ),
          headlineSmall: GoogleFonts.sourceSerif4(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2A2C),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() { super.initState(); _checkAuth(); }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');
    if (token != null && userId != null) {
      api.setAuth(token, userId);
      setState(() { _loggedIn = true; _loading = false; });
    } else {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return _loggedIn ? const DashboardScreen() : const LoginScreen();
  }
}