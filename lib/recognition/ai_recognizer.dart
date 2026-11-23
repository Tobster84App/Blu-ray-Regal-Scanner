import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'format_detector.dart';
import 'models.dart';

/// Eine von der KI erkannte Hülle.
class AiSpine {
  const AiSpine({required this.title, this.format, this.cutOff = false, this.box});

  final String title;
  final DiscFormat? format;
  final bool cutOff;

  /// Rahmen in Bildpixeln (ungefähr), falls die KI einen geliefert hat.
  final Box? box;
}

class AiException implements Exception {
  AiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

/// KI-Erkennung über eine OpenAI-kompatible Schnittstelle.
///
/// Voreingestellt ist Google Gemini (`.../v1beta/openai`). Andere Dienste mit
/// demselben Anfrageformat lassen sich über [baseUrl] und [model] anschließen.
class AiRecognizer {
  AiRecognizer({
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  static const defaultBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/openai';
  static const defaultModel = 'gemini-3.5-flash-lite';
  static const keyUrl = 'https://aistudio.google.com/apikey';

  final String baseUrl;
  final String model;
  final String apiKey;
  final http.Client _client;

  static const prompt = '''
On the photo there are cases of movies or TV shows (Blu-ray, 4K UHD, DVD) on a shelf.
Read every visible case spine from left to right.
For each case give the title exactly as printed on the spine, including additions such as
"Kapitel 3", "Uprising", numbers, "Vol. 2" or subtitles. Actor names, studios, logos and
article numbers are not part of the title.
Return only JSON:
{"spines": [{"title": "...", "format": "UHD|BD|DVD|unknown", "cut_off": true/false, "box_2d": [ymin, xmin, ymax, xmax]}]}
cut_off = true if the case is cut off at the left or right edge of the photo.
box_2d encloses the whole spine, coordinates normalized to 0-1000.
If you cannot read a title, use "title": null.''';

  Uri get _endpoint {
    final b = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$b/chat/completions');
  }

  /// Prüft Schlüssel und Modell mit einer kurzen Textanfrage.
  Future<void> testConnection() async {
    await _post({
      'model': model,
      'max_tokens': 5,
      'messages': [
        {'role': 'user', 'content': 'Reply with OK.'},
      ],
    });
  }

  /// Erkennt die Hüllen auf einem (aufrecht gedrehten) JPEG.
  Future<List<AiSpine>> recognize(Uint8List jpeg, {required double width, required double height}) async {
    final body = await _post({
      'model': model,
      'temperature': 0,
      'response_format': {
        'type': 'json_schema',
        'json_schema': {
          'name': 'spines',
          'schema': {
            'type': 'object',
            'properties': {
              'spines': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {
                    'title': {'type': 'string', 'nullable': true},
                    'format': {'type': 'string', 'enum': ['UHD', 'BD', 'DVD', 'unknown']},
                    'cut_off': {'type': 'boolean'},
                    'box_2d': {'type': 'array', 'items': {'type': 'integer'}},
                  },
                  'required': ['title', 'format', 'cut_off', 'box_2d'],
                },
              },
            },
            'required': ['spines'],
          },
        },
      },
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,${base64Encode(jpeg)}'},
            },
          ],
        },
      ],
    });
    final content = (((body['choices'] as List?)?.firstOrNull as Map?)?['message'] as Map?)?['content'];
    if (content is! String) throw AiException('Leere Antwort der KI');
    return parseResponse(content, width: width, height: height);
  }

  Future<Map<String, dynamic>> _post(Map<String, dynamic> payload) async {
    if (apiKey.trim().isEmpty) throw AiException('Kein KI-Schlüssel');
    final res = await _client
        .post(
          _endpoint,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${apiKey.trim()}',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 90));
    if (res.statusCode != 200) {
      var msg = res.body;
      try {
        final j = jsonDecode(res.body);
        final e = j is List ? j.first['error'] : j['error'];
        if (e is Map && e['message'] is String) msg = e['message'] as String;
      } on Object {
        // Rohtext behalten
      }
      if (msg.length > 300) msg = msg.substring(0, 300);
      throw AiException('KI ${res.statusCode}: $msg', statusCode: res.statusCode);
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  /// Öffentlich für Tests. Verträgt Code-Zäunen, Listen statt Objekt und
  /// verschachtelte Rahmen (`[[ymin, xmin, ymax, xmax]]`).
  static List<AiSpine> parseResponse(String content, {required double width, required double height}) {
    var text = content.trim();
    text = text.replaceAll(RegExp(r'^```(?:json)?\s*', multiLine: true), '').replaceAll('```', '').trim();
    Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      decoded = _lenientParse(text);
    }
    final list = decoded is Map ? decoded['spines'] : decoded;
    if (list is! List) return const [];
    final out = <AiSpine>[];
    for (final item in list.whereType<Map>()) {
      final title = item['title'];
      if (title is! String || title.trim().isEmpty) continue;
      Box? box;
      Object? b = item['box_2d'] ?? item['box'];
      while (b is List && b.isNotEmpty && b.first is List) {
        b = b.first;
      }
      if (b is List && b.length == 4 && b.every((v) => v is num)) {
        final v = b.cast<num>().map((n) => n.toDouble()).toList();
        box = Box(v[1] / 1000 * width, v[0] / 1000 * height, v[3] / 1000 * width, v[2] / 1000 * height);
      }
      out.add(AiSpine(
        title: title.trim(),
        format: switch ('${item['format']}'.toUpperCase()) {
          'UHD' || '4K' => DiscFormat.uhd,
          'BD' || 'BLU-RAY' || 'BLURAY' => DiscFormat.bluray,
          'DVD' => DiscFormat.dvd,
          _ => null,
        },
        cutOff: item['cut_off'] == true,
        box: box,
      ));
    }
    return out;
  }
}

/// Notfall-Parser für fehlerhaftes JSON (z. B. fehlende Klammern): liest die
/// Felder je Eintrag ab „"title":“ bis zum nächsten „"title":“.
List<Map<String, Object?>> _lenientParse(String text) {
  final out = <Map<String, Object?>>[];
  final starts = RegExp(r'"title"\s*:').allMatches(text).map((m) => m.start).toList();
  for (var i = 0; i < starts.length; i++) {
    final seg = text.substring(starts[i], i + 1 < starts.length ? starts[i + 1] : text.length);
    final title = RegExp(r'"title"\s*:\s*"((?:[^"\\]|\\.)*)"').firstMatch(seg)?.group(1);
    if (title == null) continue;
    final format = RegExp(r'"format"\s*:\s*"([^"]*)"').firstMatch(seg)?.group(1);
    final cut = RegExp(r'"cut_off"\s*:\s*(true|false)').firstMatch(seg)?.group(1) == 'true';
    final boxMatch = RegExp(r'"box_2d"\s*:\s*\[+\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)').firstMatch(seg);
    out.add({
      'title': title.replaceAll(r'\"', '"'),
      'format': format,
      'cut_off': cut,
      if (boxMatch != null) 'box_2d': [for (var g = 1; g <= 4; g++) num.parse(boxMatch.group(g)!)],
    });
  }
  return out;
}

/// Ordnet KI-Hüllen den (genaueren) ML-Kit-Rahmen zu: gleiche Reihenfolge von
/// links nach rechts, größte waagerechte Überlappung. Gibt für jede KI-Hülle
/// den passenden ML-Kit-Index zurück (oder -1).
List<int> snapToOcrSpines(List<AiSpine> ai, List<Spine> ocr) {
  final used = <int>{};
  final result = List<int>.filled(ai.length, -1);
  for (var i = 0; i < ai.length; i++) {
    final b = ai[i].box;
    if (b == null) continue;
    var best = -1;
    var bestOverlap = 0.0;
    for (var j = 0; j < ocr.length; j++) {
      if (used.contains(j)) continue;
      final o = ocr[j].box;
      final overlap = (b.right < o.right ? b.right : o.right) - (b.left > o.left ? b.left : o.left);
      final rel = overlap / (o.width < b.width ? o.width : b.width);
      if (rel > bestOverlap) {
        bestOverlap = rel;
        best = j;
      }
    }
    if (best >= 0 && bestOverlap >= 0.5) {
      used.add(best);
      result[i] = best;
    }
  }
  return result;
}
