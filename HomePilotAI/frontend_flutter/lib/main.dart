import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'models/user_profile.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'services/ai_service.dart';
import 'services/api_client.dart';
import 'services/app_session.dart';
import 'services/auth_service.dart';
import 'services/listing_service.dart';
import 'services/profile_service.dart';

void main() {
  runApp(const HomePilotBootstrap());
}

class HomePilotBootstrap extends StatelessWidget {
  const HomePilotBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSession()),
        ProxyProvider<AppSession, ApiClient>(
          update: (_, session, _) => ApiClient(session),
        ),
        ProxyProvider<ApiClient, AuthService>(
          update: (_, apiClient, _) => AuthService(apiClient),
        ),
        ProxyProvider<ApiClient, ProfileService>(
          update: (_, apiClient, _) => ProfileService(apiClient),
        ),
        ProxyProvider<ApiClient, AiService>(
          update: (_, apiClient, _) => AiService(apiClient),
        ),
        ProxyProvider<ApiClient, ListingService>(
          update: (_, apiClient, _) => ListingService(apiClient),
        ),
      ],
      child: const HomePilotApp(),
    );
  }
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
  late Future<void> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = context.read<AppSession>().restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Consumer<AppSession>(
          builder: (context, session, _) {
            if (!session.isAuthenticated) {
              return const LoginScreen();
            }

            final UserProfile? user = session.user;
            if (user == null || !user.hasCompletedProfile) {
              return const ProfileSetupScreen();
            }

            return const HomeShell();
          },
        );
      },
    );
  }
}
