import 'package:flutter/material.dart';
import '../core/brand.dart';
import '../core/theme.dart';
import '../core/theme_controller.dart';
import '../features/auth/login_page.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'app_shell.dart';

class LiveStudioApp extends StatefulWidget {
  const LiveStudioApp({super.key});

  @override
  State<LiveStudioApp> createState() => _LiveStudioAppState();
}

class _LiveStudioAppState extends State<LiveStudioApp> {
  final _auth = AuthService();
  final _storage = StorageService();
  bool? _authenticated;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _storage.init();
    await AppThemeController.load(_storage);
    final authenticated = await _auth.isAuthenticated();
    if (mounted) setState(() => _authenticated = authenticated);
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) setState(() => _authenticated = false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.mode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: Brand.name,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          home: _authenticated == null
              ? Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : _authenticated!
                  ? AppShell(onLogout: _logout)
                  : LoginPage(onLoggedIn: _load),
        );
      },
    );
  }
}
