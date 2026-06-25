import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/theme/theme_controller.dart';
import 'core/db/app_database.dart';
import 'core/id/id_generator.dart';
import 'core/providers.dart';
import 'core/seed/seed_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase.open();
  final session = await SeedService(db, const IdGenerator()).ensureSeeded();
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sessionProvider.overrideWithValue(session),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const InventoryHubApp(),
    ),
  );
}
