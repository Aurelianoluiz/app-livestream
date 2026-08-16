import 'package:flutter/material.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/media/media_library.dart';
import '../features/transmissions/transmissions_page.dart';
import '../features/settings/settings_page.dart';

class AppShell extends StatefulWidget {
  final Future<void> Function() onLogout;
  const AppShell({super.key, required this.onLogout});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardPage(),
      const MediaLibrary(),
      const TransmissionsPage(),
      SettingsPage(onLogout: widget.onLogout),
    ];
    const items = [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Início'),
      NavigationDestination(icon: Icon(Icons.perm_media_outlined), selectedIcon: Icon(Icons.perm_media), label: 'Mídia'),
      NavigationDestination(icon: Icon(Icons.live_tv_outlined), selectedIcon: Icon(Icons.live_tv), label: 'Lives'),
      NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Config.'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        final body = IndexedStack(index: _index, children: pages);
        if (!desktop) {
          return Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              destinations: items,
              onDestinationSelected: (value) => setState(() => _index = value),
            ),
          );
        }
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: (value) => setState(() => _index = value),
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
                  child: Icon(Icons.live_tv, size: 32, color: Theme.of(context).colorScheme.primary),
                ),
                destinations: items.map((item) => NavigationRailDestination(icon: item.icon, selectedIcon: item.selectedIcon, label: Text(item.label))).toList(),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}
