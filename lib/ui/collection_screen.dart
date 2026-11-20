import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../data/collection_repository.dart';
import '../data/database.dart';
import '../metadata/metadata_provider.dart';
import '../recognition/format_detector.dart';
import '../services/app_services.dart';
import 'about_screen.dart';
import 'common.dart';
import 'detail_screen.dart';
import 'imprint_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final _services = AppServices.instance;
  CollectionFilter _filter = const CollectionFilter();
  bool _searching = false;

  Future<void> _scan() async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(l10n.takePhoto),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(l10n.pickFromGallery),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    // Ohne maxWidth/imageQuality liefert image_picker die volle Auflösung.
    final file = await ImagePicker().pickImage(source: source, requestFullMetadata: false);
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScanScreen(imageBytes: bytes)),
    );
  }

  Future<void> _showFilters(List<MediaItem> all) async {
    final genres = {for (final i in all) ...i.genres}.toList()..sort();
    final result = await showModalBottomSheet<CollectionFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _FilterSheet(filter: _filter, genres: genres),
    );
    if (result != null) setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: _services.settings,
      builder: (context, _) => StreamBuilder<List<MediaItem>>(
        stream: _services.repository.watchAll(),
        builder: (context, snap) {
          final all = snap.data ?? const <MediaItem>[];
          final items = applyFilter(all, _filter);
          final grid = _services.settings.gridView;
          int count(DiscFormat f) => all.where((i) => i.formats.contains(f)).length;
          return Scaffold(
            appBar: AppBar(
              title: _searching
                  ? TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: l10n.searchCollection,
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => setState(() => _filter = _filter.copyWith(query: v)),
                    )
                  : Text(l10n.collection),
              actions: [
                IconButton(
                  tooltip: l10n.search,
                  icon: Icon(_searching ? Icons.close : Icons.search),
                  onPressed: () => setState(() {
                    _searching = !_searching;
                    if (!_searching) _filter = _filter.copyWith(query: '');
                  }),
                ),
                IconButton(
                  tooltip: l10n.filter,
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilters(all),
                ),
                IconButton(
                  tooltip: grid ? l10n.listView : l10n.gridView,
                  icon: Icon(grid ? Icons.view_list : Icons.grid_view),
                  onPressed: () => _services.settings.setGridView(!grid),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => switch (v) {
                        'settings' => const SettingsScreen(),
                        'imprint' => const ImprintScreen(),
                        _ => const AboutScreen(),
                      },
                    ),
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'settings', child: Text(l10n.settings)),
                    PopupMenuItem(value: 'about', child: Text(l10n.about)),
                    PopupMenuItem(value: 'imprint', child: Text(l10n.imprint)),
                  ],
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _scan,
              icon: const Icon(Icons.document_scanner_outlined),
              label: Text(l10n.scanShelf),
            ),
            body: Column(
              children: [
                if (all.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      l10n.countSummary(all.length, count(DiscFormat.dvd),
                          count(DiscFormat.bluray), count(DiscFormat.uhd)),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Expanded(
                  child: all.isEmpty
                      ? _empty(l10n.emptyCollection)
                      : items.isEmpty
                          ? _empty(l10n.noResults)
                          : grid
                              ? _grid(items)
                              : _list(items),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _empty(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text, textAlign: TextAlign.center),
        ),
      );

  void _open(MediaItem i) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(itemId: i.id)),
      );

  String _formatsShort(MediaItem i) => [
        if (i.hasUhd) 'UHD',
        if (i.hasBluray) 'BD',
        if (i.hasDvd) 'DVD',
      ].join(' · ');

  Widget _grid(List<MediaItem> items) => GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 140,
          childAspectRatio: 0.52,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: items.length,
        itemBuilder: (_, idx) {
          final i = items[idx];
          return InkWell(
            onTap: () => _open(i),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 2 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Poster(url: i.posterUrl),
                  ),
                ),
                const SizedBox(height: 4),
                Text(i.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall),
                Text(_formatsShort(i),
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          );
        },
      );

  Widget _list(List<MediaItem> items) => ListView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: items.length,
        itemBuilder: (_, idx) {
          final i = items[idx];
          return ListTile(
            leading: Poster(url: i.posterUrl, width: 40, height: 60),
            title: Text(i.title),
            subtitle: Text([
              if (i.year != null) '${i.year}',
              _formatsShort(i),
              if (i.type == MediaType.tv) context.l10n.tvShow,
            ].where((s) => s.isNotEmpty).join(' · ')),
            trailing: i.watched ? const Icon(Icons.visibility, size: 18) : null,
            onTap: () => _open(i),
          );
        },
      );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.filter, required this.genres});
  final CollectionFilter filter;
  final List<String> genres;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late CollectionFilter f = widget.filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme.labelLarge;
    Widget chip<T>(String label, T? value, T? current, void Function(T?) set) => ChoiceChip(
          label: Text(label),
          selected: value == current,
          onSelected: (_) => setState(() => set(value)),
        );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.sort, style: t),
          Wrap(spacing: 8, children: [
            for (final s in SortField.values)
              chip<SortField>(
                switch (s) {
                  SortField.title => l10n.sortTitle,
                  SortField.year => l10n.sortYear,
                  SortField.added => l10n.sortAdded,
                  SortField.rating => l10n.sortRating,
                },
                s,
                f.sort,
                (v) => f = f.copyWith(sort: v),
              ),
          ]),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.descending),
            value: f.descending,
            onChanged: (v) => setState(() => f = f.copyWith(descending: v)),
          ),
          Text(l10n.format, style: t),
          Wrap(spacing: 8, children: [
            chip<DiscFormat>(l10n.all, null, f.format, (v) => f = f.copyWith(format: () => v)),
            for (final x in DiscFormat.values)
              chip<DiscFormat>(formatLabel(context, x), x, f.format, (v) => f = f.copyWith(format: () => v)),
          ]),
          const SizedBox(height: 8),
          Text(l10n.type, style: t),
          Wrap(spacing: 8, children: [
            chip<MediaType>(l10n.all, null, f.type, (v) => f = f.copyWith(type: () => v)),
            chip<MediaType>(l10n.movie, MediaType.movie, f.type, (v) => f = f.copyWith(type: () => v)),
            chip<MediaType>(l10n.tvShow, MediaType.tv, f.type, (v) => f = f.copyWith(type: () => v)),
          ]),
          const SizedBox(height: 8),
          Text(l10n.watched, style: t),
          Wrap(spacing: 8, children: [
            chip<bool>(l10n.all, null, f.watched, (v) => f = f.copyWith(watched: () => v)),
            chip<bool>(l10n.watched, true, f.watched, (v) => f = f.copyWith(watched: () => v)),
            chip<bool>(l10n.notWatched, false, f.watched, (v) => f = f.copyWith(watched: () => v)),
          ]),
          if (widget.genres.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(l10n.genre, style: t),
            Wrap(spacing: 8, children: [
              chip<String>(l10n.all, null, f.genre, (v) => f = f.copyWith(genre: () => v)),
              for (final g in widget.genres)
                chip<String>(g, g, f.genre, (v) => f = f.copyWith(genre: () => v)),
            ]),
          ],
          const SizedBox(height: 16),
          Row(children: [
            TextButton(
              onPressed: () => Navigator.pop(context, CollectionFilter(query: widget.filter.query)),
              child: Text(l10n.resetFilters),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.pop(context, f),
              child: Text(l10n.save),
            ),
          ]),
        ],
      ),
    );
  }
}
