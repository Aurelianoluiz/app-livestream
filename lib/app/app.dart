import 'package:flutter/material.dart';
import '../core/brand.dart';
import '../features/dashboard/dashboard_page.dart';

class LiveStudioApp extends StatelessWidget {
  const LiveStudioApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: Brand.name,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Brand.primary),
    home: const DashboardPage(),
  );
}
