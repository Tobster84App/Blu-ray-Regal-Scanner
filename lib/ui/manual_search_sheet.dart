import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../metadata/metadata_provider.dart';
import '../services/app_services.dart';
import 'common.dart';

/// Manuelle Titelsuche. Gibt den gewählten Treffer zurück.
Future<SearchHit?> showManualSearch(BuildContext context, {String initial = ''}) {
  return showModalBottomSheet<SearchHit>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ManualSearch(initial: initial),
  );
}

class _ManualSearch extends StatefulWidget {
  const _ManualSearch({required this.initial});
  final String initial;

  @override
  State<_ManualSearch> createState() => _ManualSearchState();
}

class _ManualSearchState extends State<_ManualSearch> {
  late final _controller = TextEditingController(text: widget.initial);
  List<SearchHit> _hits = const [];
  bool _loading = false;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initial.isNotEmpty) _search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.length < 2) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final s = AppServices.instance;
    try {
      final hits = await s.metadata.search(q, language: s.settings.metadataLanguage);
      if (mounted) setState(() => _hits = hits);
    } on Exception catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: l10n.manualSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), _search);
                },
                onSubmitted: (_) => _search(),
              ),
            ),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.searchFailed(_error!)),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _hits.length,
                itemBuilder: (_, i) {
                  final h = _hits[i];
                  return ListTile(
                    leading: Poster(url: h.posterUrl, width: 40, height: 60),
                    title: Text(h.label),
                    subtitle: Text(h.type == MediaType.tv ? l10n.tvShow : l10n.movie),
                    onTap: () => Navigator.pop(context, h),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
