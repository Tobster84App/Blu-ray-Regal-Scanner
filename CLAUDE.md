# Blu-ray-Regal-Scanner – Projektüberblick

Stand: 20.11.2026. Kurz halten, bei wichtigen Änderungen aktualisieren.

## Ziel
Flutter-App (Android zuerst, iOS später): Regalfoto mit Hüllenrücken → Titel erkennen → farbige Rahmen auf dem Foto → bestätigte Titel in lokale Filmdatenbank (Liste + Detailseite mit TMDB-Daten). Kostenlos, keine Werbung, kein Tracking, keine Konten, Daten nur auf dem Gerät. Version 1 nicht-kommerziell.

## Nutzer
Tobias Kern – programmiert nicht selbst, Windows-PC + Android-Handy, kein Mac. Erklärungen auf Deutsch, Schritt für Schritt. Rückfragen nummeriert (F1, F2 …). Bei Architekturentscheidungen erst fragen.

## Festgelegt
- Package-/Bundle-ID `de.planmycinema.discscanner` (Domain plan-my-cinema.de gehört Tobias) – nicht mehr ändern.
- App-Name nur in `lib/config/app_config.dart` (`APP_NAME`); Android liest ihn per Gradle-Regex, iOS-Anzeigename steht noch zusätzlich in `ios/Runner/Info.plist` (Phase 3 lösen).
- Flutter 3.50.1 stable. **Material kommt aus `package:material_ui`** (nicht mehr `flutter/material.dart`), Lokalisierungs-Delegates aus `GlobalMaterialLocalizations.delegates` von material_ui.
- Arbeitszweig `dev`; Tobias übernimmt nach `main`. Workflow `.github/workflows/android.yml` läuft auf main und dev.
- TMDB-Schlüssel: Secret `TMDB_API_KEY` (dart-define) ODER in der App (flutter_secure_storage) – In-App hat Vorrang. Repo ist öffentlich.
- Datenbank drift (SQLite), generierte Dateien (`*.g.dart`, `lib/l10n/app_localizations*.dart`) sind eingecheckt.
- Netzwerk dieser Cloud-Umgebung: dl.google.com, api.themoviedb.org, developers.google.com gesperrt → APK-Build und Emulator nur in GitHub Actions; hier nur `flutter analyze`/`flutter test`.

- Release-APK ohne R8/Minify (`isMinifyEnabled = false`): mit R8 stürzte ML Kit ab (NPE, 21.11.2026). Nicht wieder einschalten ohne Test auf Gerät.
- Impressum in der App (`lib/ui/imprint_screen.dart`, Angaben in `lib/config/legal_info.dart`): Anbieter Tobias Kern. KernDigit-Logo (Konzept 4, aus Drive „KernDigit/Logos“, freigestellt als `assets/kerndigit_logo*.png`) **nur im Impressum**. KernDigit ist kein angemeldetes Gewerbe → nur als Logo, nicht als Anbietername.

## Erkennung (lib/recognition)
ML Kit Latin auf Original + ±90° gedreht (`ocr_service.dart`, Rückrechnung `mapFromRotated`) → Duplikate raus, senkrechte Zeilen nach x zu Hüllen gruppieren (`spine_grouper.dart`) → Sperrliste (`blocklist.dart`; Studios nur, wenn ganze Zeile Studio) → Format (`format_detector.dart`) → TMDB `/search/multi` mit Varianten (`query_builder.dart`) → Bewertung `titleCoverage * (0.75 + 0.25 * spineCoverage)` gegen den ganzen Hüllentext (`matcher.dart`). Grün ≥ 0,85 und Abstand ≥ 0,05 zum Zweitbesten; gelb ≥ 0,5; grau = am Rand angeschnitten.
Messung: `integration_test/ocr_eval_test.dart` im Emulator (CI-Job ocr-eval) mit `test/fixtures/shelf_01.jpg`, Erwartung in `test/fixtures/shelf_01_expected.dart`; Bericht + Rohzeilen (`ocr_lines.json`) als Artefakt – Rohzeilen zum Nachjustieren in Unit-Tests verwenden.

## Phasen
1 MVP (in Arbeit) · 2 Export/Backup, KI-Modus (Gemini, eigener Schlüssel – vorher Gratis-Tarif-Bedingungen prüfen und berichten), Poster offline, Feinschliff · 3 iOS (Codemagic).

## Offen
- TMDB-Logo als Asset fehlt (themoviedb.org hier gesperrt) – `assets/tmdb_logo.png` ergänzen und in pubspec eintragen.
- ML-Kit-Datenübertragung an Google (Telemetrie) noch nicht geprüft (Doku-Seite hier gesperrt).
