import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/main.dart';

void main() {
  testWidgets('Unimote app renders remote screen and navigation bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: UnimoteApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify initial remote screen header & navigation options exist
    expect(find.text('Living Room TV (Mock)'), findsOneWidget);
    expect(find.text('PAIRED'), findsOneWidget);
    expect(find.byIcon(Icons.settings_remote_rounded), findsWidgets);
    expect(find.byIcon(Icons.wifi_tethering_rounded), findsOneWidget);
    expect(find.byIcon(Icons.alt_route_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
  });

  testWidgets('Navigation bar switches between tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: UnimoteApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Discovery tab
    await tester.tap(find.text('Discovery'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Device Discovery'), findsOneWidget);

    // Tap Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Dark Mode Default'), findsOneWidget);
  });
}
