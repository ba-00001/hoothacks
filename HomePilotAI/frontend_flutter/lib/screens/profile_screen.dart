import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_session.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _householdController = TextEditingController();
  final _creditController = TextEditingController();
  final _locationController = TextEditingController();

  String _employmentStatus = 'Full-time';
  String _rentOrBuy = 'RENT';
  bool _isSaving = false;
  bool _saved = false;

  static const _employmentOptions = [
    'Full-time',
    'Part-time',
    'Self-employed',
    'Unemployed',
    'Student',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AppSession>().user;
    if (user != null) {
      _incomeController.text = user.incomeRange ?? '';
      _householdController.text = user.householdSize?.toString() ?? '1';
      _creditController.text = user.creditEstimate?.toString() ?? '';
      _locationController.text = user.preferredLocation ?? '';
      _rentOrBuy = user.rentOrBuy ?? 'RENT';
      final emp = user.employmentStatus ?? 'Full-time';
      _employmentStatus =
          _employmentOptions.contains(emp) ? emp : 'Full-time';
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _householdController.dispose();
    _creditController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _saved = false;
    });
    try {
      final updatedUser = await context.read<ProfileService>().updateProfile(
        incomeRange: _incomeController.text.trim(),
        employmentStatus: _employmentStatus,
        householdSize: int.parse(_householdController.text.trim()),
        creditEstimate: _creditController.text.trim().isEmpty
            ? null
            : int.parse(_creditController.text.trim()),
        preferredLocation: _locationController.text.trim(),
        rentOrBuy: _rentOrBuy,
      );
      if (!mounted) return;
      await context.read<AppSession>().updateUser(updatedUser);
      setState(() => _saved = true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final user = session.user;
    final email = user?.email ?? '';
    final initials = email.isNotEmpty
        ? email[0].toUpperCase()
        : '?';
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + email header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  email,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_saved) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Profile saved',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'Financial Profile',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'These values drive your affordability estimates, grant matches, and property rankings.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              children: [
                // Income range
                TextFormField(
                  controller: _incomeController,
                  decoration: const InputDecoration(
                    labelText: 'Annual income range',
                    hintText: '45000-60000',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                    helperText: 'Enter your range, e.g. 45000-60000',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v != null && v.isNotEmpty ? null : 'Required',
                ),
                const SizedBox(height: 16),

                // Employment status
                DropdownButtonFormField<String>(
                  initialValue: _employmentStatus,
                  decoration: const InputDecoration(
                    labelText: 'Employment status',
                    prefixIcon: Icon(Icons.work_rounded),
                  ),
                  items: _employmentOptions
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s)),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _employmentStatus = v ?? 'Full-time'),
                ),
                const SizedBox(height: 16),

                // Household size
                TextFormField(
                  controller: _householdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Household size',
                    prefixIcon: Icon(Icons.people_rounded),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return n != null && n > 0 ? null : 'Enter a valid number';
                  },
                ),
                const SizedBox(height: 16),

                // Credit score
                TextFormField(
                  controller: _creditController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Credit score estimate (optional)',
                    hintText: '680',
                    prefixIcon: Icon(Icons.credit_score_rounded),
                    helperText: 'Leave blank if unknown',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 300 || n > 850) {
                      return 'Enter a score between 300 and 850';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Preferred location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Preferred location',
                    hintText: 'Atlanta, GA',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                  validator: (v) =>
                      v != null && v.isNotEmpty ? null : 'Required',
                ),
                const SizedBox(height: 16),

                // Rent or buy
                DropdownButtonFormField<String>(
                  initialValue: _rentOrBuy,
                  decoration: const InputDecoration(
                    labelText: 'Rent or buy preference',
                    prefixIcon: Icon(Icons.home_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'RENT', child: Text('Rent')),
                    DropdownMenuItem(value: 'BUY', child: Text('Buy')),
                  ],
                  onChanged: (v) =>
                      setState(() => _rentOrBuy = v ?? 'RENT'),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveProfile,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(_isSaving ? 'Saving…' : 'Save profile'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 8),

          // Sign out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
              ),
              onPressed: () async => session.logout(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
