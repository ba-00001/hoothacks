import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/app_session.dart';
import '../models/auth_response.dart';

class LandlordSignupScreen extends StatefulWidget {
  const LandlordSignupScreen({super.key});

  @override
  State<LandlordSignupScreen> createState() => _LandlordSignupScreenState();
}

class _LandlordSignupScreenState extends State<LandlordSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  String _role = 'LANDLORD';
  String _tier = 'FREE_TRIAL';
  bool _isSubmitting = false;

  static const _tiers = [
    ('FREE_TRIAL', 'Free Trial', '1 listing · 30 days'),
    ('BASIC', 'Basic — \$29/mo', 'Up to 5 listings'),
    ('PREMIUM', 'Premium — \$79/mo', 'Unlimited + featured placement'),
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _businessController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final apiClient = context.read<ApiClient>();
      final json = await apiClient.postObject(
        '/auth/signup/landlord',
        body: {
          'email': _emailController.text.trim().toLowerCase(),
          'password': _passwordController.text,
          'businessName': _businessController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'role': _role,
          'subscriptionTier': _tier,
        },
      );
      if (!mounted) return;
      final response = AuthResponse.fromJson(json);
      await context.read<AppSession>().setSession(response);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List your property'),
        backgroundColor: Colors.transparent,
      ),
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
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create a landlord account',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Post your rental or sale listing directly to HomePilot AI renters and buyers.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 24),

                        // Account type
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'LANDLORD',
                              label: Text('Landlord'),
                              icon: Icon(Icons.home_rounded),
                            ),
                            ButtonSegment(
                              value: 'AGENT',
                              label: Text('Agent'),
                              icon: Icon(Icons.badge_rounded),
                            ),
                          ],
                          selected: {_role},
                          onSelectionChanged: (s) =>
                              setState(() => _role = s.first),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _businessController,
                          decoration: const InputDecoration(
                            labelText: 'Business / company name',
                            prefixIcon: Icon(Icons.business_rounded),
                          ),
                          validator: (v) =>
                              v != null && v.isNotEmpty ? null : 'Required',
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone number (optional)',
                            prefixIcon: Icon(Icons.phone_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) =>
                              v != null && v.contains('@')
                              ? null
                              : 'Enter a valid email',
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon:
                                const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (v) =>
                              v != null && v.length >= 6
                              ? null
                              : 'Minimum 6 characters',
                        ),
                        const SizedBox(height: 22),

                        Text(
                          'Choose a plan',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 10),

                        // Subscription tier cards
                        for (final (value, label, desc) in _tiers)
                          _TierCard(
                            value: value,
                            label: label,
                            description: desc,
                            selected: _tier == value,
                            onTap: () => setState(() => _tier = value),
                          ),

                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Create account'),
                        ),
                      ],
                    ),
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

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.value,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String value;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : Colors.white,
          border: Border.all(
            color: selected ? colorScheme.primary : const Color(0xFFDDDDDD),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? colorScheme.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color:
                          selected ? colorScheme.primary : Colors.black87,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
