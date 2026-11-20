import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
      responseDataCallback: (data) async {
        await Directory('build').create(recursive: true);
        await File('build/ocr_report.md').writeAsString('${data?['report'] ?? ''}');
        await File('build/ocr_lines.json').writeAsString('${data?['lines'] ?? '[]'}');
      },
    );
