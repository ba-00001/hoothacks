import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_flutter/main.dart';

void main() {
  testWidgets('shows login experience when no session exists', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const HomePilotBootstrap());
    await tester.pumpAndSettle();

    expect(find.text('HomePilot AI'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
