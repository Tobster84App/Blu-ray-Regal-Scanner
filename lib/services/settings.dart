import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../recognition/ai_recognizer.dart';

/// App-Einstellungen. Sprache und Schwellwert in SharedPreferences,
/// API-Schlüssel verschlüsselt (flutter_secure_storage).
class Settings extends ChangeNotifier {
  Settings._(this._prefs, this._secure);

  static const _kLang = 'language'; // 'system' | 'de' | 'en'
  static const _kGreen = 'greenThreshold';
  static const _kGrid = 'gridView';
  static const _kTmdbKey = 'tmdbApiKey';
  static const _kAiEnabled = 'aiEnabled';
  static const _kAiBaseUrl = 'aiBaseUrl';
  static const _kAiModel = 'aiModel';
  static const _kAiKey = 'aiApiKey';

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;
  String _tmdbKeyOverride = '';
  String _aiKey = '';

  static Future<Settings> load() async {
    final s = Settings._(
      await SharedPreferences.getInstance(),
      const FlutterSecureStorage(),
    );
    try {
      s._tmdbKeyOverride = await s._secure.read(key: _kTmdbKey) ?? '';
      s._aiKey = await s._secure.read(key: _kAiKey) ?? '';
    } on Exception {
      s._tmdbKeyOverride = '';
    }
    return s;
  }

  String get languageSetting => _prefs.getString(_kLang) ?? 'system';

  /// Tatsächliche Sprache ('de' oder 'en').
  String get languageCode {
    final l = languageSetting;
    if (l == 'de' || l == 'en') return l;
    final sys = PlatformDispatcher.instance.locale.languageCode;
    return sys == 'de' ? 'de' : 'en';
  }

  Locale get locale => Locale(languageCode);

  /// Sprache für die Filmdaten, z. B. `de-DE`.
  String get metadataLanguage => languageCode == 'de' ? 'de-DE' : 'en-US';

  Future<void> setLanguage(String value) async {
    await _prefs.setString(_kLang, value);
    notifyListeners();
  }

  double get greenThreshold =>
      _prefs.getDouble(_kGreen) ?? const RecognitionConfig().greenThreshold;

  Future<void> setGreenThreshold(double v) async {
    await _prefs.setDouble(_kGreen, v);
    notifyListeners();
  }

  RecognitionConfig get recognitionConfig =>
      const RecognitionConfig().copyWith(greenThreshold: greenThreshold);

  bool get gridView => _prefs.getBool(_kGrid) ?? true;

  Future<void> setGridView(bool v) async {
    await _prefs.setBool(_kGrid, v);
    notifyListeners();
  }

  /// Eigener Schlüssel aus den Einstellungen, sonst der aus dem Build.
  String get tmdbApiKey =>
      _tmdbKeyOverride.isNotEmpty ? _tmdbKeyOverride : buildTmdbApiKey;

  String get tmdbKeyOverride => _tmdbKeyOverride;
  bool get hasBuildTmdbKey => buildTmdbApiKey.isNotEmpty;

  Future<void> setTmdbKeyOverride(String v) async {
    _tmdbKeyOverride = v.trim();
    if (_tmdbKeyOverride.isEmpty) {
      await _secure.delete(key: _kTmdbKey);
    } else {
      await _secure.write(key: _kTmdbKey, value: _tmdbKeyOverride);
    }
    notifyListeners();
  }

  // --- KI-Erkennung ---------------------------------------------------------

  /// KI-Erkennung eingeschaltet (nur wirksam mit Schlüssel).
  bool get aiEnabled => _prefs.getBool(_kAiEnabled) ?? false;
  bool get aiActive => aiEnabled && _aiKey.isNotEmpty;

  Future<void> setAiEnabled(bool v) async {
    await _prefs.setBool(_kAiEnabled, v);
    notifyListeners();
  }

  String get aiBaseUrl => _prefs.getString(_kAiBaseUrl) ?? AiRecognizer.defaultBaseUrl;
  String get aiModel => _prefs.getString(_kAiModel) ?? AiRecognizer.defaultModel;
  String get aiKey => _aiKey;

  Future<void> setAiConfig({required String baseUrl, required String model, required String key}) async {
    await _prefs.setString(_kAiBaseUrl, baseUrl.trim().isEmpty ? AiRecognizer.defaultBaseUrl : baseUrl.trim());
    await _prefs.setString(_kAiModel, model.trim().isEmpty ? AiRecognizer.defaultModel : model.trim());
    _aiKey = key.trim();
    if (_aiKey.isEmpty) {
      await _secure.delete(key: _kAiKey);
    } else {
      await _secure.write(key: _kAiKey, value: _aiKey);
    }
    notifyListeners();
  }

  AiRecognizer aiRecognizer({String? baseUrl, String? model, String? key}) => AiRecognizer(
        baseUrl: baseUrl ?? aiBaseUrl,
        model: model ?? aiModel,
        apiKey: key ?? _aiKey,
      );
}
