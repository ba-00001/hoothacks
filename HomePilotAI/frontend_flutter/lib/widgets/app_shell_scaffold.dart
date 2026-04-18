import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_session.dart';

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.currentIndex,
    required this.title,
    required this.onSelect,
    required this.body,
  });

  final int currentIndex;
  final String title;
  final ValueChanged<int> onSelect;
  final Widget body;

  static const _items = [
    ('Dashboard', Icons.space_dashboard_rounded),
    ('Recommendations', Icons.auto_awesome_rounded),
    ('Listings', Icons.house_rounded),
    ('Saved', Icons.favorite_rounded),
    ('Grants', Icons.volunteer_activism_rounded),
    ('Mortgage', Icons.calculate_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const ListTile(
                title: Text(
                  'HomePilot AI',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Housing affordability assistant'),
              ),
              const Divider(),
              for (var i = 0; i < _items.length; i++)
                ListTile(
                  leading: Icon(_items[i].$2),
                  selected: i == currentIndex,
                  title: Text(_items[i].$1),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelect(i);
                  },
                ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Logout'),
                onTap: () async {
                  await context.read<AppSession>().logout();
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: body),
    );
  }
}
