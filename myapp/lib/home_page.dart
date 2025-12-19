import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/group_model.dart';
import 'groups_page.dart';
import 'l10n/app_localizations.dart';
import 'map_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    //  Kolla om en grupp är vald för att visa kartan/profilen.
    final groupId = context.select<GroupModel, String?>((m) => m.selectedGroupId);
    final canUseGroupTabs = groupId != null;
    final l = AppLocalizations.of(context)!;

    if (!canUseGroupTabs && _index != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _index = 1);
      });
    }

    final pages = <Widget>[
      canUseGroupTabs
          ? const MapPage()
          : _NeedsGroupPage(
              icon: Icons.map_outlined,
              title: l.map,
              onOpenGroups: () => setState(() => _index = 1),
            ),
      const GroupsPage(),
      canUseGroupTabs
          ? const ProfilePage()
          : _NeedsGroupPage(
              icon: Icons.person_outline,
              title: l.profile,
              onOpenGroups: () => setState(() => _index = 1),
            ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (!canUseGroupTabs && i != 1) {
            setState(() => _index = 1);
            return;
          }
          setState(() => _index = i);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: l.map,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: l.groups,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l.profile,
          ),
        ],
      ),
    );
  }
}

class _NeedsGroupPage extends StatelessWidget {
  const _NeedsGroupPage({
    required this.icon,
    required this.title,
    required this.onOpenGroups,
  });

  final IconData icon;
  final String title;
  final VoidCallback onOpenGroups;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l.selectGroupFirst,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onOpenGroups,
                child: Text(l.goToGroups),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
