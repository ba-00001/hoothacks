import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_session.dart';
import '../services/profile_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _employmentController = TextEditingController(text: 'Full-time');
  final _householdController = TextEditingController(text: '1');
  final _creditController = TextEditingController();
  final _locationController = TextEditingController();
  String _rentOrBuy = 'RENT';
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AppSession>().user;
    _incomeController.text = user?.incomeRange ?? _incomeController.text;
    _employmentController.text =
        user?.employmentStatus ?? _employmentController.text;
    _householdController.text =
        user?.householdSize?.toString() ?? _householdController.text;
    _creditController.text = user?.creditEstimate?.toString() ?? '';
    _locationController.text = user?.preferredLocation ?? _locationController.text;
    _rentOrBuy = user?.rentOrBuy ?? _rentOrBuy;
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _employmentController.dispose();
    _householdController.dispose();
    _creditController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updatedUser = await context.read<ProfileService>().updateProfile(
            incomeRange: _incomeController.text.trim(),
            employmentStatus: _employmentController.text.trim(),
            householdSize: int.parse(_householdController.text.trim()),
            creditEstimate: _creditController.text.trim().isEmpty
                ? null
                : int.parse(_creditController.text.trim()),
            preferredLocation: _locationController.text.trim(),
            rentOrBuy: _rentOrBuy,
          );
      if (!mounted) return;
      await context.read<AppSession>().updateUser(updatedUser);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tell HomePilot about your housing goals',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This profile powers your affordability estimate, grant matches, and property ranking.',
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _incomeController,
                        decoration: const InputDecoration(
                          labelText: 'Income range',
                          hintText: '45000-60000',
                        ),
                        validator: (value) =>
                            value != null && value.isNotEmpty ? null : 'Enter income range',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _employmentController,
                        decoration: const InputDecoration(
                          labelText: 'Employment status',
                        ),
                        validator: (value) =>
                            value != null && value.isNotEmpty ? null : 'Enter employment status',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _householdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Household size'),
                        validator: (value) {
                          final parsed = int.tryParse(value ?? '');
                          return parsed != null && parsed > 0
                              ? null
                              : 'Enter a valid household size';
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _creditController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Credit estimate (optional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Preferred location',
                          hintText: 'Atlanta, GA',
                        ),
                        validator: (value) =>
                            value != null && value.isNotEmpty ? null : 'Enter a location',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _rentOrBuy,
                        decoration: const InputDecoration(
                          labelText: 'Rent or buy preference',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'RENT', child: Text('Rent')),
                          DropdownMenuItem(value: 'BUY', child: Text('Buy')),
                        ],
                        onChanged: (value) => setState(() => _rentOrBuy = value ?? 'RENT'),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          child: Text(_isSaving ? 'Saving...' : 'Complete profile'),
                        ),
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
