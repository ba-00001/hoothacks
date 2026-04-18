import 'package:flutter/material.dart';

import 'chatbot_screen.dart';
import '../widgets/app_shell_scaffold.dart';
import 'dashboard_screen.dart';
import 'grant_eligibility_screen.dart';
import 'listings_screen.dart';
import 'mortgage_estimate_screen.dart';
import 'profile_screen.dart';
import 'recommendations_screen.dart';
import 'saved_properties_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const _titles = [
    'Chatbot',
    'Dashboard',
    'Recommendations',
    'Listings',
    'Saved Properties',
    'Grant Eligibility',
    'Mortgage Estimate',
    'My Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ChatbotScreen(),
      const DashboardScreen(),
      const RecommendationsScreen(),
      const ListingsScreen(),
      const SavedPropertiesScreen(),
      const GrantEligibilityScreen(),
      const MortgageEstimateScreen(),
      const ProfileScreen(),
    ];

    return AppShellScaffold(
      currentIndex: _currentIndex,
      title: _titles[_currentIndex],
      onSelect: (index) => setState(() => _currentIndex = index),
      body: screens[_currentIndex],
    );
  }
}
