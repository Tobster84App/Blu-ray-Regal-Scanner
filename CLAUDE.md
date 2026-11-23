# Blu-ray-Regal-Scanner – Projektüberblick

Stand: 20.11.2026. Kurz halten, bei wichtigen Änderungen aktualisieren.

## Ziel
Flutter-App (Android zuerst, iOS später): Regalfoto mit Hüllenrücken → Titel erkennen → farbige Rahmen auf dem Foto → bestätigte Titel in lokale Filmdatenbank (Liste + Detailseite mit TMDB-Daten). Kostenlos, keine Werbung, kein eigenes Tracking, keine Konten, Daten nur auf dem Gerät. Version 1 nicht-kommerziell.

## Nutzer
Tobias Kern – programmiert nicht selbst, Windows-PC + Android-Handy, kein Mac. Erklärungen auf Deutsch, Schritt für Schritt. Rückfragen nummeriert (F1, F2 …). Bei Architekturentscheidungen erst fragen.

## Festgelegt
- Package-/Bundle-ID `de.planmycinema.discscanner` (Domain plan-my-cinema.de gehört Tobias) – nicht mehr ändern.
- App-Name nur in `lib/config/app_config.dart` (`APP_NAME`); Android liest ihn per Gradle-Regex, iOS-Anzeigename steht noch zusätzlich in `ios/Runner/Info.plist` (Phase 3 lösen).
- Flutter 3.50.1 stable. **Material kommt aus `package:material_ui`** (nicht mehr `flutter/material.dart`), Lokalisierungs-Delegates aus `GlobalMaterialLocalizations.delegates` von material_ui.
- Auslieferung: Artefakt `apk` = Testversion MIT TMDB-Schlüssel (nur angemeldet); bei jedem Push zusätzlich öffentliches GitHub-Release OHNE Schlüssel, fester Link `releases/latest/download/<APP_NAME>.apk`, 5 neueste Releases bleiben.
- Arbeitszweig `dev`; Tobias übernimmt nach `main`. Workflow `.github/workflows/android.yml` läuft auf main und dev.
- TMDB-Schlüssel: Secret `TMDB_API_KEY` (dart-define) ODER in der App (flutter_secure_storage) – In-App hat Vorrang. Repo ist öffentlich.
- Datenbank drift (SQLite), generierte Dateien (`*.g.dart`, `lib/l10n/app_localizations*.dart`) sind eingecheckt.
- Cloud-Umgebung „Tobias Apps (Scanner + Throne)“: TMDB (Schlüssel per Proxy für api.themoviedb.org hinterlegt), developers.google.com, storage.googleapis.com erlaubt; Setup-Skript installiert Flutter. dl.google.com gesperrt → APK-Build und Emulator nur in GitHub Actions. Live-Test der Treffersuche: `TMDB_API_KEY=eyJproxy dart run tool/live_match.dart` (Proxy ersetzt den Platzhalter).

- Release-APK ohne R8/Minify (`isMinifyEnabled = false`): mit R8 stürzte ML Kit ab (NPE, 21.11.2026). Nicht wieder einschalten ohne Test auf Gerät.
- ML Kit sendet Nutzungs-/Diagnosedaten an Google (Gerät, App-Version, Installations-ID; keine Fotos/Texte), nicht abschaltbar. Entscheidung 22.11.2026: offenlegen → `lib/ui/privacy_screen.dart`. Nicht mit „kein Tracking“ werben.
- Impressum in der App (`lib/ui/imprint_screen.dart`, Angaben in `lib/config/legal_info.dart`): Anbieter Tobias Kern. KernDigit-Logo (Konzept 4, aus Drive „KernDigit/Logos“, freigestellt als `assets/kerndigit_logo*.png`) **nur im Impressum**. KernDigit ist kein angemeldetes Gewerbe → nur als Logo, nicht als Anbietername.

## Erkennung (lib/recognition)
ML Kit Latin: EIN Durchlauf über das Foto (ML Kit liest senkrechte Schrift selbst; ±90°-Durchläufe brachten nichts, Messung 22.11.), dann jede Zeile mit Sicherheit < 0,6 einzeln ausschneiden und in beiden Leserichtungen nachlesen – Titel von unten nach oben liest ML Kit sonst „auf dem Kopf“ (`ocr_service.dart`) → Sperrliste auch fuzzy („UTRAHD“, „Blusay“, Bestellnummern) → Duplikate raus (gleiche Achse + Überlappung), senkrechte Zeilen nach x auf Bildmitte entlang ihrer Neigung gruppieren – Eckpunkte von ML Kit, Hüllen stehen oft schräg (`spine_grouper.dart`, Faktor `spineGapFactor` 0,55 × Summe der Schrifthöhen; Regressionstest mit echten Rohdaten `test/real_ocr_test.dart`), Rahmen als schräges Viereck → Sperrliste (`blocklist.dart`; Studios nur, wenn ganze Zeile Studio) → Format (`format_detector.dart`) → TMDB `/search/multi` mit Varianten (`query_builder.dart`; TMDB verlangt alle Wörter → bei < gelb Ersatzsuchen: Wörter weglassen, lange Wörter auf 5 Zeichen kürzen) → Bewertung `titleCoverage * (0.75 + 0.25 * spineCoverage)` gegen den ganzen Hüllentext (`matcher.dart`). Grün ≥ 0,85 und Abstand ≥ 0,05 zum Zweitbesten (bei Gleichstand grün nur, wenn ≥ 3× so populär wie alle gleich guten; Filme ×1 vor Serien ×0,97, umgekehrt bei Serien-Hinweis wie „Staffel“/„Disc Set“); Grün zusätzlich nur, wenn der Titel ≥ 45 % der Buchstaben auf der Hülle erklärt und TMDB-Beliebtheit ≥ 1,5 (gegen Zufallstreffer; Kehrseite: „John Wick“ + „Keanu Reeves“ wird gelb). Andere Lesungen derselben Zeile aus den 3 Durchläufen bleiben als `alternatives` erhalten und werden zeilenweise gesucht und bewertet. gelb ≥ 0,5; grau = am Rand angeschnitten.
Offline-Schleife ohne Emulator: `TMDB_API_KEY=eyJproxy dart run tool/replay.dart test/fixtures/ocr_lines_run15.json` (echte Rohdaten + echtes TMDB). Stand 22.11.: 34 grün (≈31 richtig), 52 gelb, 56 rot, 20 grau über 8 Fotos.
Messung: `integration_test/ocr_eval_test.dart` im Emulator (CI-Job ocr-eval, Profile-Modus) über alle `test/fixtures/*.jpg` (8 Regalfotos von Tobias, 04+05 stark verwackelt; Download zur Laufzeit von raw.githubusercontent), Erwartung bisher nur für shelf_01 in `test/fixtures/shelf_01_expected.dart`; Bericht + Rohzeilen (`ocr_lines.json`) als Artefakt – Rohzeilen zum Nachjustieren in Unit-Tests verwenden.

## Gemini-Messung (23.11.2026)
`tool/gemini_eval.dart` (OpenAI-kompatible Schnittstelle `/v1beta/openai/chat/completions`, Schlüssel per Proxy als Bearer – der native Endpunkt verlangt `x-goog-api-key`, das kann das Credential-Formular nicht). `gemini-3.5-flash-lite`: 133/155 richtig (86 %, jeder Soll-Titel zählt einmal; John Wick: Kapitel 2 liest Gemini nur als „John Wick“; Soll-Listen in `test/fixtures/expected.json` sind Claudes Entwurf und teils falsch → real höher), ~4 s und ~1.250/700 Tokens pro Foto, 10 falsch grün. ML Kit im Vergleich: ~31 richtige Grüne. Boxen (`box_2d`, 0–1000) kommen, sind aber ungenau (teils halbe Hülle versetzt, manchmal verschachtelt `[[…]]`). Bedingungen: EU erlaubt, im EWR keine Trainingsnutzung auch im Gratis-Tarif; Weitergabe an andere EU-Nutzer nur mit Paid Services.

## KI-Modus (eingebaut 23.11.2026)
`lib/recognition/ai_recognizer.dart`: OpenAI-kompatible Schnittstelle, Adresse/Modell/Schlüssel in den Einstellungen (Standard Gemini `gemini-3.5-flash-lite`, Schlüssel jeder Nutzer selbst, Link aistudio.google.com/apikey; einmalige Einwilligung beim Einschalten). Antwortformat per `json_schema` erzwungen + Notfall-Parser. Ablauf im Scan: Foto vorbereiten → KI und ML Kit parallel → KI-Titel sofort bei TMDB suchen und mit ungefähren KI-Rahmen zeigen → nach ML Kit Rahmen per `snapToOcrSpines` (x-Überlappung ≥ 50 %) einrasten. KI-Fehler → Hinweis + ML-Kit-Ergebnis. Treffersuche: Teilnummer auf der Hülle muss im Titel stehen (sonst ×0,8); Haupttitel vor „ – “/„: “ zählt mit ×0,9.

## Phasen
1 MVP (in Arbeit) · 2 Export/Backup, KI-Modus (Gemini, eigener Schlüssel – vorher Gratis-Tarif-Bedingungen prüfen und berichten), Poster offline, Feinschliff · 3 iOS (Codemagic).

## Offen
- TMDB-Logo als Asset fehlt (themoviedb.org hier gesperrt) – `assets/tmdb_logo.png` ergänzen und in pubspec eintragen.
