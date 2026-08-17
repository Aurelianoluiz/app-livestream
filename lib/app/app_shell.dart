import 'package:flutter/material.dart';
import '../core/brand.dart';
import '../core/theme_controller.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/media/media_library.dart';
import '../features/transmissions/transmissions_page.dart';
import '../features/reports/reports_page.dart';
import '../features/settings/settings_page.dart';

class AppShell extends StatefulWidget {
  final Future<void> Function() onLogout;
  const AppShell({super.key, required this.onLogout});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String group;
  const _NavItem(this.icon, this.activeIcon, this.label, this.group);
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _collapsed = false;

  static const _items = [
    _NavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Início', 'PRINCIPAL'),
    _NavItem(Icons.perm_media_outlined, Icons.perm_media_rounded, 'Mídia', 'CONTEÚDO'),
    _NavItem(Icons.live_tv_outlined, Icons.live_tv_rounded, 'Lives', 'CONTEÚDO'),
    _NavItem(Icons.assessment_outlined, Icons.assessment_rounded, 'Relatórios', 'GESTÃO'),
    _NavItem(Icons.settings_outlined, Icons.settings_rounded, 'Configurações', 'GESTÃO'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardPage(),
      const MediaLibrary(),
      const TransmissionsPage(),
      const ReportsPage(),
      SettingsPage(onLogout: widget.onLogout),
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
              destinations: _items
                  .map((item) => NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.activeIcon),
                        label: item.label == 'Configurações' ? 'Config.' : item.label,
                      ))
                  .toList(),
              onDestinationSelected: (value) => setState(() => _index = value),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              _Sidebar(
                collapsed: _collapsed,
                items: _items,
                selectedIndex: _index,
                onToggle: () => setState(() => _collapsed = !_collapsed),
                onSelected: (value) => setState(() => _index = value),
                onThemeToggle: () {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  AppThemeController.setDarkMode(!isDark);
                },
                onLogout: widget.onLogout,
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

class _Sidebar extends StatelessWidget {
  final bool collapsed;
  final List<_NavItem> items;
  final int selectedIndex;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelected;
  final VoidCallback onThemeToggle;
  final Future<void> Function() onLogout;

  const _Sidebar({
    required this.collapsed,
    required this.items,
    required this.selectedIndex,
    required this.onToggle,
    required this.onSelected,
    required this.onThemeToggle,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = collapsed ? 82.0 : 252.0;
    final groups = <String, List<int>>{};
    for (var i = 0; i < items.length; i++) {
      groups.putIfAbsent(items[i].group, () => []).add(i);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(right: BorderSide(color: scheme.outlineVariant.withOpacity(0.6))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Brand.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Brand.primary.withOpacity(0.28)),
                    ),
                    child: const Icon(Icons.live_tv_rounded, color: Brand.primary),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LIVE STUDIO ASR', style: TextStyle(fontWeight: FontWeight.w900)),
                          SizedBox(height: 2),
                          Text('Central de comando', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                  IconButton(
                    tooltip: collapsed ? 'Expandir menu' : 'Recolher menu',
                    onPressed: onToggle,
                    icon: Icon(collapsed ? Icons.menu_rounded : Icons.menu_open_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final entry in groups.entries) ...[
                      if (!collapsed)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      for (final index in entry.value) _item(context, index),
                      if (!collapsed) const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 10),
              _footerButton(
                context,
                icon: Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                label: Theme.of(context).brightness == Brightness.dark ? 'Modo claro' : 'Modo escuro',
                onTap: onThemeToggle,
              ),
              const SizedBox(height: 6),
              _footerButton(
                context,
                icon: Icons.logout_rounded,
                label: 'Sair',
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index) {
    final item = items[index];
    final selected = selectedIndex == index;
    final scheme = Theme.of(context).colorScheme;
    final tile = Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: selected ? Brand.primary.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: selected ? Border.all(color: Brand.primary.withOpacity(0.22)) : null,
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 14),
        leading: Icon(selected ? item.activeIcon : item.icon, color: selected ? Brand.primary : scheme.onSurfaceVariant),
        title: collapsed ? null : Text(item.label, style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
        selected: selected,
        onTap: () => onSelected(index),
      ),
    );

    return collapsed
        ? Tooltip(message: item.label, child: tile)
        : tile;
  }

  Widget _footerButton(BuildContext context, {required IconData icon, required String label, required FutureOr<void> Function() onTap}) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onTap(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 14, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: scheme.onSurfaceVariant),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
