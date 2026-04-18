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
      if (mounted) setState(() => _error = 'Google sign-in error');
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6E5C6), Color(0xFFE1EFE9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HomePilot AI', style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 8),
                      const Text('Find the most affordable housing options for your budget, location, and eligibility profile.'),
                      const SizedBox(height: 24),
                      TextField(controller: _emailC, decoration: const InputDecoration(labelText: 'Email')),
                      const SizedBox(height: 16),
                      TextField(controller: _passC, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                      if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: Colors.red))],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _login,
                          child: Text(_loading ? 'Signing in...' : 'Login', style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('or', style: TextStyle(color: Colors.grey.shade600))), const Expanded(child: Divider())]),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : _googleLogin,
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          icon: Image.network('https://developers.google.com/identity/images/g-logo.png', height: 22, width: 22, errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24)),
                          label: const Text('Continue with Google', style: TextStyle(fontSize: 16, color: Colors.black87)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                        child: const Text('Create a new account'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}