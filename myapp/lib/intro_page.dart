import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/auth_model.dart';
import 'data/cache_model.dart';
import 'data/find_model.dart';
import 'data/group_model.dart';
import 'data/settings_model.dart';
import 'groups_page.dart';
import 'l10n/app_localizations.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AuthModel>();
    final groups = context.watch<GroupModel>();
    final cacheModel = context.watch<CacheModel>();
    final findModel = context.watch<FindModel>();
    final user = auth.user;
    final name = user?.displayName?.trim();
    final email = user?.email;
    final greeting = name?.isNotEmpty == true
        ? name!
        : (email ?? 'Geocachare');
    final group = groups.selectedGroup;

    return Scaffold(
      appBar: AppBar(
        title: Text(group == null ? '${l.hello}, $greeting' : '${group.name} • ${l.hello}, $greeting'),
        actions: [
          IconButton(
            tooltip: l.theme,
            onPressed: () => context.read<SettingsModel>().toggleTheme(),
            icon: const Icon(Icons.brightness_6_outlined),
          ),
          IconButton(
            tooltip: l.settings,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: l.groups,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GroupsPage()),
              );
            },
            icon: const Icon(Icons.groups_outlined),
          ),
          IconButton(
            tooltip: l.profile,
            onPressed: () {
              final cacheModel = context.read<CacheModel>();
              final findModel = context.read<FindModel>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: cacheModel),
                      ChangeNotifierProvider.value(value: findModel),
                    ],
                    child: const ProfilePage(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: l.logout,
            onPressed: () => context.read<AuthModel>().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${l.cachesLabel}: ${cacheModel.caches.length} • ${l.foundLabel}: ${findModel.foundCacheIds.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final cacheModel = context.read<CacheModel>();
                final findModel = context.read<FindModel>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: cacheModel,
                      child: ChangeNotifierProvider.value(
                        value: findModel,
                        child: const MapPage(),
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.map_outlined),
              label: Text(l.openMap),
            ),
          ],
        ),
      ),
    );
  }
}
