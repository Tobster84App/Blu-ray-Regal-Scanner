import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppServices.instance = await AppServices.create();
  runApp(const DiscScannerApp());
}
