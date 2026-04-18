import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'profile_setup_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _signup() async {
    if (_passC.text != _confirmC.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await api.signup(_emailC.text.trim(), _passC.text);
      if (res['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', res['token']);
        await prefs.setInt('userId', res['userId']);
        api.setAuth(res['token'], res['userId']);
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => ProfileSetupScreen(userId: res['userId'])),
            (_) => false,
          );
        }
      } else {
        setState(() => _error = res['error'] ?? 'Signup failed');
      }
    } catch (e) {
      setState(() => _error = 'Connection error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
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
                    Text('Create your account', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 24),
                    TextField(controller: _emailC, decoration: const InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 16),
                    TextField(controller: _passC, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                    const SizedBox(height: 16),
                    TextField(controller: _confirmC, decoration: const InputDecoration(labelText: 'Confirm Password'), obscureText: true),
                    if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: Colors.red))],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _signup,
                        child: Text(_loading ? 'Creating...' : 'Sign up', style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}