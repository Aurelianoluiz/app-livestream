import 'package:flutter/material.dart';
import '../core/brand.dart';
import '../core/theme.dart';
import 'app_shell.dart';

class LiveStudioApp extends StatelessWidget {
  const LiveStudioApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: Brand.name,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AppShell(),
      );
}
