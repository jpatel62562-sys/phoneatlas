import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:phoneatlas/phoneatlas.dart';

void main() {
  testWidgets('PhoneAtlas example app boots and displays showcase elements', (
    tester,
  ) async {
    // Increase test surface size for showcase view
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const PhoneAtlasExampleApp());
    await tester.pumpAndSettle();

    // Verify title and banner
    expect(find.text('PhoneAtlas Showcase'), findsOneWidget);
    expect(find.text('PhoneAtlas Flutter Package'), findsOneWidget);

    // Verify PhoneAtlasField is rendered
    expect(find.byType(PhoneAtlasField), findsOneWidget);
    expect(find.text('🇮🇳'), findsWidgets);
    expect(find.text('+91'), findsWidgets);

    // Verify buttons
    expect(find.text('Validate & Submit'), findsOneWidget);
    expect(find.text('Reset Form'), findsOneWidget);

    // Tap Validate button
    await tester.tap(find.text('Validate & Submit'));
    await tester.pumpAndSettle();

    // 9876543210 is a valid 10-digit Indian number -> shows submitted message
    expect(find.textContaining('Submitted:'), findsOneWidget);

    // Toggle isValidate switch off
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Bypassed (isValidate: false)'), findsOneWidget);

    // Switch country via chip (e.g. US)
    final usChip = find.widgetWithText(FilterChip, 'United States (+1)');
    expect(usChip, findsOneWidget);
    await tester.tap(usChip);
    await tester.pumpAndSettle();

    expect(find.text('🇺🇸'), findsWidgets);
    expect(find.text('+1'), findsWidgets);
  });
}
