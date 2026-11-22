# Blu-ray-Regal-Scanner (Arbeitstitel „DiscScanner“)

Android-App (später auch iOS), die auf einem Foto deines Regals die Titel der
Blu-ray-/UHD-/DVD-Hüllen erkennt und sie in eine lokale Filmdatenbank
übernimmt. Kostenlos, ohne Werbung, ohne Konto. Alle Daten
bleiben auf dem Gerät.

* Texterkennung: Google ML Kit auf dem Gerät (Fotos bleiben lokal; ML Kit sendet Nutzungs-/Diagnosedaten an Google – siehe Datenschutz-Seite in der App)
* Filmdaten: [TMDB](https://www.themoviedb.org/) – *This product uses the TMDB API but is not endorsed or certified by TMDB.*
* App-Name: Platzhalter `APP_NAME` in `lib/config/app_config.dart` (nur dort ändern)
* Package-ID: `de.planmycinema.discscanner`

---

## 1. TMDB-API-Schlüssel beantragen (einmalig, kostenlos)

1. Konto anlegen auf <https://www.themoviedb.org/signup> und die Bestätigungsmail anklicken.
2. Anmelden → oben rechts auf dein Profilbild → **Einstellungen** → links **API**.
3. **„Einen API-Schlüssel anfordern“** bzw. „Create“ → Typ **Developer** wählen.
4. Bedingungen akzeptieren und das Formular ausfüllen:
   * Nutzungsart: *Persönlich / nicht-kommerziell*
   * Anwendungsname: z. B. „DiscScanner (privat)“
   * Anwendungs-URL: `https://github.com/Tobster84App/Blu-ray-Regal-Scanner`
   * Beschreibung: „Private Android-App zum Katalogisieren meiner eigenen Filmsammlung.“
5. Danach siehst du zwei Werte: **API-Schlüssel** (kurz) und **API-Lesezugriffstoken** (lang, beginnt mit `eyJ`). Die App kann mit beiden umgehen.

**Den Schlüssel nie in Dateien im Repository schreiben.**

## 2. Schlüssel in die App bringen – zwei Wege

**Weg A (empfohlen bei öffentlichem Repository):** In der App unter
*Einstellungen → Eigener TMDB-Schlüssel* eintragen. Er wird verschlüsselt auf
dem Handy gespeichert und steckt nicht in der APK.

**Weg B:** Als GitHub-Secret. Dann wird er beim Bauen in die APK eingebaut.
1. Repository auf GitHub öffnen → **Settings** → links **Secrets and variables** → **Actions**.
2. **New repository secret** → Name `TMDB_API_KEY`, Wert = dein Schlüssel → **Add secret**.

> ⚠️ Bei Weg B kann jeder, der die APK hat, den Schlüssel mit etwas Aufwand
> auslesen. Bei einem öffentlichen Repository können alle angemeldeten
> GitHub-Nutzer die APK-Artefakte herunterladen.

Das Secret wird außerdem für die automatische Messung der Erkennung (Abschnitt 5) gebraucht.

## 3. APK herunterladen und auf Android installieren

**Öffentliche Version (einfachster Weg, ohne eingebauten TMDB-Schlüssel):**
1. Auf dem Handy in Chrome öffnen: <https://github.com/Tobster84App/Blu-ray-Regal-Scanner/releases/latest/download/DiscScanner.apk>
   (Übersicht aller Versionen: <https://github.com/Tobster84App/Blu-ray-Regal-Scanner/releases>)
2. Die heruntergeladene `DiscScanner.apk` antippen (Benachrichtigung oder App „Dateien“ → Downloads).
3. Nach dem Installieren in der App unter ⋮ → **Einstellungen** den TMDB-Schlüssel eintragen.

**Testversion mit eingebautem Schlüssel (nur angemeldet):** Reiter **Actions** → neuester grüner Lauf → unten unter **Artifacts** auf **apk** (ZIP mit `…-test.apk`). Auf dem Handy dafür im Chrome-Menü „Desktopwebsite“ einschalten, sonst ist der Link nicht anklickbar.

**Installieren:** Android fragt beim ersten Mal, ob die App (z. B. Chrome oder „Dateien“) **Apps aus unbekannten Quellen installieren** darf → **Einstellungen** → Schalter einschalten → zurück → **Installieren**. Warnt Google Play Protect, weil die App nicht aus dem Play Store kommt: **Weitere Details** → **Trotzdem installieren**.

Updates: neue APK genauso installieren. Das klappt nur, wenn sie mit **demselben** Schlüssel signiert ist (siehe 4). Sonst die alte App vorher deinstallieren – dabei geht die Sammlung verloren (Backup kommt in Phase 2).

## 4. Eigener Signatur-Schlüssel (Keystore) unter Windows

Bis das erledigt ist, signiert der Workflow mit einem Debug-Schlüssel. Der
kann sich zwischen Läufen ändern, dann lassen sich Updates nicht über die alte
Version installieren.

1. **Java installieren** (enthält das Werkzeug `keytool`): <https://adoptium.net/de/temurin/releases/> → Windows x64, JDK 17 oder 21, `.msi` → installieren (Haken bei „Set JAVA_HOME“ und „Add to PATH“).
2. **PowerShell** öffnen (Startmenü → „PowerShell“) und in einen Ordner wechseln, z. B. `cd $HOME\Documents`.
3. Schlüssel erzeugen:
   ```powershell
   keytool -genkeypair -v -keystore discscanner-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias discscanner
   ```
   Passwort zweimal eingeben (gut merken, im Passwortmanager speichern), die Fragen nach Name usw. beantworten (Ort und Land reichen), zum Schluss `ja` bzw. `yes`.
4. Datei für GitHub umwandeln (landet in der Zwischenablage):
   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("$PWD\discscanner-release.jks")) | Set-Clipboard
   ```
5. Auf GitHub unter **Settings → Secrets and variables → Actions** vier Secrets anlegen:
   | Name | Wert |
   |---|---|
   | `ANDROID_KEYSTORE_BASE64` | Inhalt der Zwischenablage (Strg+V) |
   | `ANDROID_KEYSTORE_PASSWORD` | dein Passwort |
   | `ANDROID_KEY_ALIAS` | `discscanner` |
   | `ANDROID_KEY_PASSWORD` | dein Passwort (dasselbe) |
6. **Die `.jks`-Datei und das Passwort sicher aufbewahren** (z. B. zusätzlich auf einem USB-Stick). Ohne sie kannst du später keine Updates derselben App mehr ausliefern. Nie ins Repository legen.

Nach der Umstellung einmal die alte (debug-signierte) App deinstallieren und die neue installieren.

## 5. Erkennung messen (Referenzfoto)

Liegt `test/fixtures/shelf_01.jpg` im Repository, startet der Workflow einen
Android-Emulator, lässt die Erkennung auf dem Foto laufen und vergleicht mit
der Liste in `test/fixtures/shelf_01_expected.dart`. Das Ergebnis steht im
Lauf unter **Summary** und als Artefakt **ocr-bericht**. Ohne Secret
`TMDB_API_KEY` wird nur die Texterkennung gemessen, keine Treffersuche.

## Für Entwickler

```bash
flutter pub get
flutter test
flutter run --dart-define=TMDB_API_KEY=...       # oder Schlüssel in der App eintragen
dart run build_runner build                      # nach Änderungen an lib/data/database.dart
flutter gen-l10n                                 # nach Änderungen an lib/l10n/*.arb
```

Aufbau:
* `lib/recognition/` – Erkennung: ML Kit (`ocr_service.dart`), Hüllen trennen (`spine_grouper.dart`), Sperrliste (`blocklist.dart` – hier Störwörter ergänzen), Formaterkennung, Treffer-Bewertung (`matcher.dart`)
* `lib/metadata/` – austauschbare Datenquelle (`MetadataProvider`), TMDB-Umsetzung
* `lib/data/` – SQLite-Datenbank (drift)
* `lib/ui/` – Bildschirme
* `lib/l10n/` – Texte Deutsch/Englisch

Flutter-Version: 3.50.1 (stable). Seit Flutter 3.47 kommt Material aus dem Paket `material_ui`.
