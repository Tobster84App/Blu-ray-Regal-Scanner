import 'package:discscanner/config/legal_info.dart';
import 'package:discscanner/l10n/app_localizations.dart';
import 'package:discscanner/ui/imprint_screen.dart';
import 'package:discscanner/ui/privacy_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget app(Locale locale, Brightness b, {Widget home = const ImprintScreen()}) => MaterialApp(
      locale: locale,
      theme: ThemeData(brightness: b),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      home: home,
    );

void main() {
  testWidgets('Impressum DE hell: Logo und Anbieter', (t) async {
    await t.pumpWidget(app(const Locale('de'), Brightness.light));
    await t.pumpAndSettle();
    expect(find.text('Angaben gemäß § 5 DDG'), findsOneWidget);
    expect(find.textContaining(providerName), findsWidgets);
    final img = t.widget<Image>(find.byType(Image));
    expect((img.image as AssetImage).assetName, 'assets/kerndigit_logo.png');
  });

  testWidgets('Impressum EN dunkel: helles Logo, Übersetzungshinweis', (t) async {
    await t.pumpWidget(app(const Locale('en'), Brightness.dark));
    await t.pumpAndSettle();
    expect(find.textContaining('German version is legally binding'), findsOneWidget);
    final img = t.widget<Image>(find.byType(Image));
    expect((img.image as AssetImage).assetName, 'assets/kerndigit_logo_dark.png');
  });

  testWidgets('Datenschutz nennt ML-Kit-Übertragung (DE/EN)', (t) async {
    await t.pumpWidget(app(const Locale('de'), Brightness.light, home: const PrivacyScreen()));
    await t.pumpAndSettle();
    expect(find.textContaining('Nutzungs- und Diagnosedaten an Google'), findsOneWidget);
    await t.pumpWidget(app(const Locale('en'), Brightness.light, home: const PrivacyScreen()));
    await t.pumpAndSettle();
    expect(find.textContaining('usage and diagnostic data to Google'), findsOneWidget);
  });
}
