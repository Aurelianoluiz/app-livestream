import 'package:flutter/material.dart';
import '../core/brand.dart';
import '../core/theme.dart';
import '../features/auth/login_page.dart';
import '../services/auth_service.dart';
import 'app_shell.dart';

class LiveStudioApp extends StatefulWidget {
  const LiveStudioApp({super.key});

  @override
  State<LiveStudioApp> createState() => _LiveStudioAppState();
}

class _LiveStudioAppState extends State<LiveStudioApp> {
  final _auth = AuthService();
  bool? _authenticated;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final authenticated = await _auth.isAuthenticated();
    if (mounted) setState(() => _authenticated = authenticated);
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) setState(() => _authenticated = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Brand.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: _authenticated == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _authenticated!
              ? AppShell(onLogout: _logout)
              : LoginPage(onLoggedIn: _loadSession),
    );
  }
}
