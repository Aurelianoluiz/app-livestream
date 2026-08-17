import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppThemeController {
  AppThemeController._();

  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.dark);

  static Future<void> load(StorageService storage) async {
    final settings = await storage.loadSettings();
    final dark = settings['darkMode'] as bool? ?? true;
    mode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  static void setDarkMode(bool enabled) {
    mode.value = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}
