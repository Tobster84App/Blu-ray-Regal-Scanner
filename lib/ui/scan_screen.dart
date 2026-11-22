import 'dart:io';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../data/collection_repository.dart';
import '../metadata/metadata_provider.dart';
import '../recognition/format_detector.dart';
import '../recognition/matcher.dart';
import '../recognition/models.dart';
import '../recognition/ocr_service.dart';
import '../recognition/spine_grouper.dart';
import '../recognition/spine_matcher.dart';
import '../services/app_services.dart';
import 'common.dart';
import 'manual_search_sheet.dart';
import 'settings_screen.dart';

/// Zeigt das Foto mit farbigen Rahmen um die erkannten Hüllen.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.imageBytes});
  final Uint8List imageBytes;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _services = AppServices.instance;
  final _ocr = OcrService();

  String? _progress;
  String? _error;
  OcrResult? _ocrResult;
  List<SpineResult> _results = [];
  bool _drawMode = false;
  Offset? _dragStart;
  Rect? _dragRect;
  bool _anyAccepted = false;

  /// Erster Fehler der Titelsuche (z. B. ungültiger TMDB-Schlüssel).
  String? get _searchError {
    for (final r in _results) {
      if (r.error != null) return r.error;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void dispose() {
    _ocr.dispose();
    // Foto löschen, wenn nichts übernommen wurde.
    final path = _ocrResult?.imagePath;
    if (path != null && !_anyAccepted) {
      File(path).delete().catchError((_) => File(path));
    }
    super.dispose();
  }

  Future<void> _run() async {
    final l10n = context.l10n;
    setState(() {
      _error = null;
      _progress = l10n.preparingImage;
    });
    try {
      final ocr = await _ocr.recognize(widget.imageBytes, onStep: (step) {
        if (!mounted) return;
        setState(() => _progress = switch (step) {
              'prepare' => l10n.preparingImage,
              'none' => l10n.ocrPass(1),
              'cw90' => l10n.ocrPass(2),
              _ => l10n.ocrPass(3),
            });
      });
      final cfg = _services.settings.recognitionConfig;
      final spines = groupSpines(ocr.lines,
          imageWidth: ocr.width, imageHeight: ocr.height, cfg: cfg);
      setState(() => _ocrResult = ocr);
      if (!_services.metadata.isConfigured) {
        setState(() {
          _results = spines
              .map((s) => SpineResult(
                    box: s.box,
                    polygon: s.polygon,
                    rawText: s.rawText,
                    cleanedText: s.cleanedText,
                    format: s.format,
                    status: s.cutOff ? MatchStatus.grey : MatchStatus.red,
                    candidates: const [],
                  ))
              .toList();
          _progress = null;
        });
        return;
      }
      final matcher = SpineMatcher(_services.metadata, cfg: cfg);
      final results = await matcher.matchAll(
        spines,
        language: _services.settings.metadataLanguage,
        onProgress: (d, t) {
          if (mounted) setState(() => _progress = l10n.searchingTitles(d, t));
        },
      );
      if (mounted) {
        setState(() {
          _results = results;
          _progress = null;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _progress = null;
        });
      }
    }
  }

  Future<AddOutcome?> _accept(SpineResult r, SearchHit hit, Set<DiscFormat> formats) async {
    try {
      final details = await _services.metadata.details(hit.id, hit.type,
          language: _services.settings.metadataLanguage);
      final (outcome, _) = await _services.repository.addOrMerge(
        details,
        formats: formats,
        scanPhotoPath: _ocrResult?.imagePath,
      );
      setState(() {
        r.chosen = hit;
        r.accepted = true;
        r.status = MatchStatus.green;
        _anyAccepted = true;
      });
      return outcome;
    } on Exception catch (e) {
      if (mounted) showSnack(context, context.l10n.error('$e'));
      return null;
    }
  }

  Set<DiscFormat> _defaultFormats(SpineResult r) => {r.format ?? DiscFormat.bluray};

  Future<void> _acceptAllGreen() async {
    var created = 0, merged = 0, unchanged = 0;
    final greens = _results
        .where((r) => r.status == MatchStatus.green && !r.accepted && r.best != null)
        .toList();
    for (final r in greens) {
      final o = await _accept(r, r.best!, _defaultFormats(r));
      switch (o) {
        case AddOutcome.created:
          created++;
        case AddOutcome.merged:
          merged++;
        case AddOutcome.unchanged:
          unchanged++;
        case null:
          break;
      }
    }
    if (mounted) showSnack(context, context.l10n.addedCount(created, merged, unchanged));
  }

  Future<void> _openSpine(SpineResult r) async {
    final hit = await showModalBottomSheet<(SearchHit, Set<DiscFormat>)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SpineSheet(result: r, initialFormats: _defaultFormats(r)),
    );
    if (hit != null && mounted) {
      final o = await _accept(r, hit.$1, hit.$2);
      if (o != null && mounted) {
        showSnack(context, context.l10n.addedCount(
            o == AddOutcome.created ? 1 : 0,
            o == AddOutcome.merged ? 1 : 0,
            o == AddOutcome.unchanged ? 1 : 0));
      }
    }
  }

  Future<void> _finishDraw(double scale) async {
    final rect = _dragRect;
    setState(() {
      _drawMode = false;
      _dragRect = null;
      _dragStart = null;
    });
    final hit = await showManualSearch(context);
    if (hit == null || !mounted) return;
    if (rect == null || rect.width < 8 || rect.height < 8) {
      // Nur angetippt: ohne Rahmen direkt suchen und übernehmen.
      final r = SpineResult(
        box: const Box(0, 0, 0, 0),
        rawText: '',
        cleanedText: '',
        format: null,
        status: MatchStatus.green,
        candidates: [ScoredHit(hit, 1)],
        manual: true,
      );
      await _openSpine(r);
      return;
    }
    final box = Box(rect.left / scale, rect.top / scale, rect.right / scale, rect.bottom / scale);
    final r = SpineResult(
      box: box,
      rawText: '',
      cleanedText: '',
      format: null,
      status: MatchStatus.green,
      candidates: [ScoredHit(hit, 1)],
      manual: true,
    );
    setState(() => _results.add(r));
    await _openSpine(r);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final counts = {for (final s in MatchStatus.values) s: _results.where((r) => r.status == s).length};
    final greenOpen = _results
        .where((r) => r.status == MatchStatus.green && !r.accepted)
        .length;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanShelf),
        actions: [
          IconButton(
            tooltip: l10n.addMissingSpine,
            icon: Icon(_drawMode ? Icons.close : Icons.crop_free),
            onPressed: _ocrResult == null ? null : () => setState(() => _drawMode = !_drawMode),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_services.metadata.isConfigured)
            MaterialBanner(
              content: Text(l10n.noTmdbKey),
              actions: [
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  child: Text(l10n.openSettings),
                ),
              ],
            ),
          if (_progress == null && _searchError != null)
            MaterialBanner(
              content: Text(l10n.searchFailed(_searchError!)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  child: Text(l10n.openSettings),
                ),
              ],
            ),
          if (_progress != null) ...[
            const LinearProgressIndicator(),
            Padding(padding: const EdgeInsets.all(8), child: Text(_progress!)),
          ],
          if (_error != null)
            ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text(l10n.error(_error!)),
              trailing: TextButton(onPressed: _run, child: Text(l10n.retry)),
            ),
          if (_ocrResult != null && _progress == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                _drawMode
                    ? l10n.drawSpineHint
                    : _results.isEmpty
                        ? l10n.noSpinesFound
                        : '${l10n.scanSummary(counts[MatchStatus.green]!, counts[MatchStatus.yellow]!, counts[MatchStatus.red]!, counts[MatchStatus.grey]!)}\n${l10n.zoomHint}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(child: _buildImage()),
        ],
      ),
      bottomNavigationBar: _ocrResult == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.done_all),
                        label: Text(l10n.acceptAllGreen(greenOpen)),
                        onPressed: greenOpen == 0 ? null : _acceptAllGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImage() {
    final ocr = _ocrResult;
    if (ocr == null) {
      return Center(child: Image.memory(widget.imageBytes, fit: BoxFit.contain, cacheWidth: 1200));
    }
    return LayoutBuilder(builder: (context, constraints) {
      final scale = (constraints.maxWidth / ocr.width) < (constraints.maxHeight / ocr.height)
          ? constraints.maxWidth / ocr.width
          : constraints.maxHeight / ocr.height;
      final w = ocr.width * scale, h = ocr.height * scale;
      Widget content = SizedBox(
        width: w,
        height: h,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.file(File(ocr.imagePath), fit: BoxFit.fill, cacheWidth: 3000),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _BoxPainter(_results, scale, _dragRect),
              ),
            ),
          ],
        ),
      );
      if (_drawMode) {
        content = GestureDetector(
          onPanStart: (d) => setState(() {
            _dragStart = d.localPosition;
            _dragRect = Rect.fromPoints(d.localPosition, d.localPosition);
          }),
          onPanUpdate: (d) => setState(() {
            _dragRect = Rect.fromPoints(_dragStart!, d.localPosition);
          }),
          onPanEnd: (_) => _finishDraw(scale),
          child: content,
        );
      } else {
        content = GestureDetector(
          onTapUp: (d) {
            final p = d.localPosition / scale;
            for (final r in _results.reversed) {
              if (pointInPolygon(Pt(p.dx, p.dy), r.polygon)) {
                _openSpine(r);
                return;
              }
            }
          },
          child: content,
        );
      }
      return InteractiveViewer(
        maxScale: 10,
        panEnabled: !_drawMode,
        scaleEnabled: !_drawMode,
        child: Center(child: content),
      );
    });
  }
}

class _BoxPainter extends CustomPainter {
  _BoxPainter(this.results, this.scale, this.dragRect);
  final List<SpineResult> results;
  final double scale;
  final Rect? dragRect;

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in results) {
      if (r.polygon.length < 3) continue;
      final path = Path()
        ..addPolygon([for (final p in r.polygon) Offset(p.x * scale, p.y * scale)], true);
      final color = statusColor(r.status);
      if (r.accepted) {
        canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.35));
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = r.accepted ? 3 : 2,
      );
    }
    if (dragRect != null) {
      canvas.drawRect(
        dragRect!,
        Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_BoxPainter old) => true;
}

/// Details zu einer Hülle: erkannter Text, Format, Vorschläge.
class _SpineSheet extends StatefulWidget {
  const _SpineSheet({required this.result, required this.initialFormats});
  final SpineResult result;
  final Set<DiscFormat> initialFormats;

  @override
  State<_SpineSheet> createState() => _SpineSheetState();
}

class _SpineSheetState extends State<_SpineSheet> {
  late final Set<DiscFormat> _formats = {...widget.initialFormats};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = widget.result;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.square, color: statusColor(r.status)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                r.accepted ? l10n.accepted : (r.best?.label ?? l10n.noMatchHint),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ]),
          if (r.status == MatchStatus.grey) ...[
            const SizedBox(height: 8),
            Text(l10n.cutOffHint, style: TextStyle(color: theme.colorScheme.error)),
          ],
          if (!r.manual) ...[
            const SizedBox(height: 12),
            Text(l10n.recognizedText, style: theme.textTheme.labelLarge),
            Text(r.rawText.isEmpty ? l10n.noTextRecognized : r.rawText),
          ],
          if (r.error != null) ...[
            const SizedBox(height: 8),
            Text(l10n.searchFailed(r.error!), style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 12),
          Text(l10n.formats, style: theme.textTheme.labelLarge),
          Wrap(
            spacing: 8,
            children: [
              for (final f in DiscFormat.values)
                FilterChip(
                  label: Text(formatLabel(context, f)),
                  selected: _formats.contains(f),
                  onSelected: (v) => setState(() {
                    if (v) {
                      _formats.add(f);
                    } else if (_formats.length > 1) {
                      _formats.remove(f);
                    }
                  }),
                ),
            ],
          ),
          if (r.candidates.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.suggestions, style: theme.textTheme.labelLarge),
            for (final c in r.candidates)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Poster(url: c.hit.posterUrl, width: 40, height: 60),
                title: Text(c.hit.label),
                subtitle: Text(
                    '${c.hit.type == MediaType.tv ? l10n.tvShow : l10n.movie} · ${(c.score * 100).round()} %'),
                trailing: const Icon(Icons.add_circle_outline),
                onTap: () => Navigator.pop(context, (c.hit, _formats)),
              ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.search),
            label: Text(l10n.manualSearch),
            onPressed: () async {
              final hit = await showManualSearch(context, initial: r.cleanedText);
              if (hit != null && context.mounted) {
                Navigator.pop(context, (hit, _formats));
              }
            },
          ),
        ],
      ),
    );
  }
}
