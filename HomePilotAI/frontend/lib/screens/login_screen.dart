import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false;
  String? _error;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await api.login(_emailC.text.trim(), _passC.text);
      if (res['token'] != null) {
        await _saveAndNavigate(res['token'], res['userId']);
      } else {
        setState(() => _error = res['error'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _error = 'Connection error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final auth = await account.authentication;

      // Flutter web gives accessToken, not idToken
      final token = auth.idToken ?? auth.accessToken;
      if (token == null) {
        if (mounted) setState(() { _error = 'Could not get Google token'; _loading = false; });
        return;
      }

      final res = await api.googleAuth(token);
      if (res['token'] != null) {
        await _saveAndNavigate(res['token'], res['userId']);
      } else {
        if (mounted) setState(() => _error = res['error'] ?? 'Google login failed');
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('popup_closed') || msg.contains('user_cancel')) {
        debugPrint('Google sign-in cancelled');
      } else {
        if (mounted) setState(() => _error = 'Google sign-in error: $msg');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveAndNavigate(String token, dynamic userId) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = userId is int ? userId : int.parse(userId.toString());
    await prefs.setString('token', token);
    await prefs.setInt('userId', uid);
    api.setAuth(token, uid);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Icon(Icons.home_work_rounded, size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text('HomePilot AI', textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Find your perfect home', textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)),
              const SizedBox(height: 48),
              TextField(controller: _emailC, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              TextField(controller: _passC, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)), obscureText: true),
              if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)],
              const SizedBox(height: 24),
              FilledButton(onPressed: _loading ? null : _login, style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Log In', style: TextStyle(fontSize: 16))),
              const SizedBox(height: 20),
              Row(children: [const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('or', style: TextStyle(color: Colors.grey.shade600))), const Expanded(child: Divider())]),
              const SizedBox(height: 20),
              OutlinedButton.icon(onPressed: _loading ? null : _googleLogin,
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                icon: Image.network('https://developers.google.com/identity/images/g-logo.png', height: 22, width: 22, errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24)),
                label: const Text('Continue with Google', style: TextStyle(fontSize: 16, color: Colors.black87))),
              const SizedBox(height: 24),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())), child: const Text("Don't have an account? Sign up")),
            ],
          ),
        ),
      ),
    );
  }
}
