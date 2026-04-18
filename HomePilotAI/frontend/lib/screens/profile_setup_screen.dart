import 'package:flutter/material.dart';
import '../main.dart';
import 'dashboard_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final int userId;
  const ProfileSetupScreen({super.key, required this.userId});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameC = TextEditingController();
  final _locationC = TextEditingController();
  String _incomeRange = '50k-75k';
  String _employment = 'employed';
  int _householdSize = 1;
  int _creditEstimate = 650;
  String _rentOrBuy = 'rent';
  bool _loading = false;

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await api.updateProfile(widget.userId, {
        'name': _nameC.text,
        'incomeRange': _incomeRange,
        'employmentStatus': _employment,
        'householdSize': _householdSize,
        'creditEstimate': _creditEstimate,
        'preferredLocation': _locationC.text,
        'rentOrBuy': _rentOrBuy,
      });
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, 
                  children: [
                    Text('Tell HomePilot about your housing goals', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    const Text('This profile powers your affordability estimate, grant matches, and property ranking.'),
                    const SizedBox(height: 24),
                    TextField(controller: _nameC, decoration: const InputDecoration(labelText: 'Full Name')),
                    const SizedBox(height: 16),
                    TextField(controller: _locationC, decoration: const InputDecoration(labelText: 'Preferred Location')),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _incomeRange,
                      decoration: const InputDecoration(labelText: 'Income Range'),
                      items: ['under_25k','25k-50k','50k-75k','75k-100k','100k-150k','150k+']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _incomeRange = v!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _employment,
                      decoration: const InputDecoration(labelText: 'Employment Status'),
                      items: ['employed','self-employed','unemployed','student','retired']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _employment = v!),
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: Text('Household Size: $_householdSize')),
                      Expanded(flex: 2, child: Slider(
                        value: _householdSize.toDouble(), min: 1, max: 10, divisions: 9,
                        label: '$_householdSize',
                        onChanged: (v) => setState(() => _householdSize = v.round()),
                      )),
                    ]),
                    Row(children: [
                      Expanded(child: Text('Credit Estimate: $_creditEstimate')),
                      Expanded(flex: 2, child: Slider(
                        value: _creditEstimate.toDouble(), min: 300, max: 850, divisions: 11,
                        label: '$_creditEstimate',
                        onChanged: (v) => setState(() => _creditEstimate = v.round()),
                      )),
                    ]),
                    const SizedBox(height: 16),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'rent', label: Text('Rent'), icon: Icon(Icons.apartment)),
                        ButtonSegment(value: 'buy', label: Text('Buy'), icon: Icon(Icons.house)),
                      ],
                      selected: {_rentOrBuy},
                      onSelectionChanged: (v) => setState(() => _rentOrBuy = v.first),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _loading ? null : _save,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save & Continue', style: TextStyle(fontSize: 16)),
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