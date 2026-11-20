import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/collection_repository.dart';
import '../data/database.dart';
import '../metadata/metadata_provider.dart';
import '../recognition/format_detector.dart';
import '../services/app_services.dart';
import 'common.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.itemId});
  final int itemId;

  @override
  Widget build(BuildContext context) {
    final repo = AppServices.instance.repository;
    return StreamBuilder<MediaItem?>(
      stream: repo.watchItem(itemId),
      builder: (context, snap) {
        final item = snap.data;
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: snap.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink(),
          );
        }
        return _DetailView(item: item);
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.item});
  final MediaItem item;

  Future<void> _refresh(BuildContext context) async {
    final s = AppServices.instance;
    try {
      final d = await s.metadata.details(item.externalId, item.type,
          language: s.settings.metadataLanguage);
      await s.repository.updateMetadata(item.id, d);
      if (context.mounted) showSnack(context, context.l10n.reloadDone(1));
    } on Exception catch (e) {
      if (context.mounted) showSnack(context, context.l10n.error('$e'));
    }
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.deleteConfirm(item.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete)),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.pop(context);
      await AppServices.instance.repository.delete(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFmt = DateFormat.yMd(locale);
    final facts = [
      if (item.year != null) '${item.year}',
      if (item.runtimeMinutes != null) l10n.runtimeMinutes(item.runtimeMinutes!),
      if (item.seasons != null) l10n.seasons(item.seasons!),
      if (item.certification != null) item.certification!,
      if (item.voteAverage != null && item.voteAverage! > 0)
        l10n.tmdbRating(item.voteAverage!.toStringAsFixed(1)),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: item.backdropUrl == null ? null : 220,
            flexibleSpace: item.backdropUrl == null
                ? null
                : FlexibleSpaceBar(background: Poster(url: item.backdropUrl)),
            actions: [
              IconButton(
                tooltip: l10n.refreshData,
                icon: const Icon(Icons.refresh),
                onPressed: () => _refresh(context),
              ),
              IconButton(
                tooltip: l10n.delete,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Poster(url: item.posterUrl, width: 110, height: 165),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: theme.textTheme.headlineSmall),
                          if (item.originalTitle != null && item.originalTitle != item.title)
                            Text(item.originalTitle!, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Text(facts.join(' · ')),
                          const SizedBox(height: 4),
                          Text(item.genres.join(', '), style: theme.textTheme.bodySmall),
                          if (item.trailerKey != null) ...[
                            const SizedBox(height: 8),
                            FilledButton.tonalIcon(
                              icon: const Icon(Icons.play_arrow),
                              label: Text(l10n.watchTrailer),
                              onPressed: () => launchUrl(
                                Uri.parse('https://www.youtube.com/watch?v=${item.trailerKey}'),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (item.overview != null) ...[
                  const SizedBox(height: 16),
                  Text(l10n.overview, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(item.overview!),
                ],
                if (item.directors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(item.type == MediaType.tv ? l10n.creator : l10n.director,
                      style: theme.textTheme.titleMedium),
                  Text(item.directors.join(', ')),
                ],
                if (item.cast.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.cast, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: item.cast.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final c = item.cast[i];
                        return SizedBox(
                          width: 80,
                          child: Column(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Poster(url: c.profileUrl, width: 70, height: 90),
                            ),
                            Text(c.name, maxLines: 2, textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis, style: theme.textTheme.labelSmall),
                            if (c.character != null)
                              Text(c.character!, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                          ]),
                        );
                      },
                    ),
                  ),
                ],
                const Divider(height: 32),
                Text(l10n.myData, style: theme.textTheme.titleMedium),
                _OwnFields(item: item),
                const SizedBox(height: 16),
                Text(l10n.addedOn(dateFmt.format(item.addedAt)), style: theme.textTheme.bodySmall),
                Text(l10n.lastUpdated(dateFmt.format(item.lastFetched)), style: theme.textTheme.bodySmall),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Eigene Felder: Formate, Ausgabe, gesehen, Bewertung, Standort, Notizen.
class _OwnFields extends StatefulWidget {
  const _OwnFields({required this.item});
  final MediaItem item;

  @override
  State<_OwnFields> createState() => _OwnFieldsState();
}

class _OwnFieldsState extends State<_OwnFields> {
  late final _location = TextEditingController(text: widget.item.location ?? '');
  late final _notes = TextEditingController(text: widget.item.notes ?? '');
  final _repo = AppServices.instance.repository;

  @override
  void dispose() {
    _saveTexts();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _saveTexts() {
    final loc = _location.text.trim(), notes = _notes.text.trim();
    if (loc == (widget.item.location ?? '') && notes == (widget.item.notes ?? '')) return;
    _repo.updateFields(
      widget.item.id,
      MediaItemsCompanion(
        location: Value(loc.isEmpty ? null : loc),
        notes: Value(notes.isEmpty ? null : notes),
      ),
    );
  }

  void _set(MediaItemsCompanion c) => _repo.updateFields(widget.item.id, c);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final i = widget.item;
    final t = Theme.of(context).textTheme.labelLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(l10n.formats, style: t),
        Wrap(spacing: 8, children: [
          for (final f in DiscFormat.values)
            FilterChip(
              label: Text(formatLabel(context, f)),
              selected: i.formats.contains(f),
              onSelected: (v) => _set(switch (f) {
                DiscFormat.dvd => MediaItemsCompanion(hasDvd: Value(v)),
                DiscFormat.bluray => MediaItemsCompanion(hasBluray: Value(v)),
                DiscFormat.uhd => MediaItemsCompanion(hasUhd: Value(v)),
              }),
            ),
        ]),
        const SizedBox(height: 8),
        Text(l10n.edition, style: t),
        Wrap(spacing: 8, children: [
          FilterChip(
            label: Text(l10n.steelbook),
            selected: i.isSteelbook,
            onSelected: (v) => _set(MediaItemsCompanion(isSteelbook: Value(v))),
          ),
          FilterChip(
            label: Text(l10n.mediabook),
            selected: i.isMediabook,
            onSelected: (v) => _set(MediaItemsCompanion(isMediabook: Value(v))),
          ),
          FilterChip(
            label: Text(l10n.boxset),
            selected: i.isBoxset,
            onSelected: (v) => _set(MediaItemsCompanion(isBoxset: Value(v))),
          ),
        ]),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.watched),
          value: i.watched,
          onChanged: (v) => _set(MediaItemsCompanion(watched: Value(v))),
        ),
        Row(children: [
          Expanded(child: Text(l10n.myRating)),
          DropdownButton<int?>(
            value: i.userRating,
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.noRating)),
              for (var r = 1; r <= 10; r++) DropdownMenuItem(value: r, child: Text('$r')),
            ],
            onChanged: (v) => _set(MediaItemsCompanion(userRating: Value(v))),
          ),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: _location,
          decoration: InputDecoration(labelText: l10n.location, border: const OutlineInputBorder()),
          onEditingComplete: _saveTexts,
          onTapOutside: (_) => _saveTexts(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          minLines: 2,
          maxLines: 6,
          decoration: InputDecoration(labelText: l10n.notes, border: const OutlineInputBorder()),
          onTapOutside: (_) => _saveTexts(),
        ),
      ],
    );
  }
}
