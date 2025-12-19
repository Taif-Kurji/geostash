import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/auth_page.dart';
import 'package:myapp/l10n/app_localizations.dart';

void main() {
  testWidgets('AuthPage renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AuthPage(),
      ),
    );
    expect(find.text('GeoStash'), findsOneWidget);
  });
}
