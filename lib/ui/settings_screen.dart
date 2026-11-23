import 'package:material_ui/material_ui.dart';

import '../services/app_services.dart';
import 'about_screen.dart';
import 'common.dart';
import '../recognition/ai_recognizer.dart';

import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _s = AppServices.instance;
  late final _key = TextEditingController(text: _s.settings.tmdbKeyOverride);
  bool _obscure = true;

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  Future<void> _changeLanguage(String value) async {
    final before = _s.settings.metadataLanguage;
    await _s.settings.setLanguage(value);
    if (!mounted || before == _s.settings.metadataLanguage) return;
    final items = await _s.repository.all();
    if (items.isEmpty || !_s.metadata.isConfigured || !mounted) return;
    final l10n = context.l10n;
    final reload = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.reloadDataQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
    if (reload != true || !mounted) return;
    final progress = ValueNotifier<(int, int)>((0, items.length));
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: ValueListenableBuilder(
          valueListenable: progress,
          builder: (_, p, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: p.$2 == 0 ? null : p.$1 / p.$2),
              const SizedBox(height: 12),
              Text(l10n.reloading(p.$1, p.$2)),
            ],
          ),
        ),
      ),
    );
    final n = await _s.repository.refresh(
      _s.metadata,
      language: _s.settings.metadataLanguage,
      onProgress: (d, t) => progress.value = (d, t),
    );
    if (mounted) {
      Navigator.pop(context);
      showSnack(context, l10n.reloadDone(n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: _s.settings,
      builder: (context, _) {
        final st = _s.settings;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.settings)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              ListTile(
                title: Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              RadioGroup<String>(
                groupValue: st.languageSetting,
                onChanged: (v) => v == null ? null : _changeLanguage(v),
                child: Column(
                  children: [
                    RadioListTile(
                      value: 'system',
                      title: Text(l10n.languageSystem),
                    ),
                    RadioListTile(value: 'de', title: Text(l10n.german)),
                    RadioListTile(value: 'en', title: Text(l10n.english)),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  l10n.greenThreshold(st.greenThreshold.toStringAsFixed(2)),
                ),
              ),
              Slider(
                value: st.greenThreshold,
                min: 0.6,
                max: 0.98,
                divisions: 19,
                label: st.greenThreshold.toStringAsFixed(2),
                onChanged: st.setGreenThreshold,
              ),
              const Divider(),
              const _AiSettings(),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _key,
                      obscureText: _obscure,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: l10n.tmdbKey,
                        helperText: l10n.tmdbKeyHelp,
                        helperMaxLines: 3,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    if (st.hasBuildTmdbKey) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.tmdbKeyFromBuild,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () async {
                          await st.setTmdbKeyOverride(_key.text);
                          if (context.mounted) showSnack(context, l10n.save);
                        },
                        child: Text(l10n.save),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.about),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Einstellungen für die KI-Erkennung (eigener Schlüssel).
class _AiSettings extends StatefulWidget {
  const _AiSettings();

  @override
  State<_AiSettings> createState() => _AiSettingsState();
}

class _AiSettingsState extends State<_AiSettings> {
  final _st = AppServices.instance.settings;
  late final _key = TextEditingController(text: _st.aiKey);
  late final _model = TextEditingController(text: _st.aiModel);
  late final _url = TextEditingController(text: _st.aiBaseUrl);
  bool _obscure = true;
  bool _testing = false;

  @override
  void dispose() {
    _key.dispose();
    _model.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _save() =>
      _st.setAiConfig(baseUrl: _url.text, model: _model.text, key: _key.text);

  Future<void> _toggle(bool on) async {
    final l10n = context.l10n;
    if (on && _key.text.trim().isEmpty) showSnack(context, l10n.aiNoKey);
    if (on) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.aiConsentTitle),
          content: SingleChildScrollView(child: Text(l10n.aiConsentText)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.aiConsentAccept),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await _st.setAiEnabled(on);
  }

  Future<void> _test() async {
    final l10n = context.l10n;
    if (_key.text.trim().isEmpty) {
      showSnack(context, l10n.aiNoKey);
      return;
    }
    setState(() => _testing = true);
    await _save();
    try {
      await _st.aiRecognizer().testConnection();
      if (mounted) showSnack(context, l10n.aiTestOk);
    } on Exception catch (e) {
      if (mounted) showSnack(context, l10n.error('$e'));
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: _st,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.aiSection, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(l10n.aiExplain, style: theme.textTheme.bodySmall),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.aiEnable),
              value: _st.aiEnabled,
              onChanged: _toggle,
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.aiGetKey),
              onPressed: () => launchUrl(
                Uri.parse(AiRecognizer.keyUrl),
                mode: LaunchMode.externalApplication,
              ),
            ),
            const SizedBox(height: 4),
            Text(l10n.aiGetKeyHelp, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: _key,
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: l10n.aiKey,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _model,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.aiModel,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(l10n.aiAdvanced, style: theme.textTheme.bodyMedium),
              children: [
                TextField(
                  controller: _url,
                  autocorrect: false,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: l10n.aiBaseUrl,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 8),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _testing ? null : _test,
                  child: _testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.aiTest),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    await _save();
                    if (context.mounted) showSnack(context, l10n.save);
                  },
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
