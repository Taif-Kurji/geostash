import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/auth_model.dart';
import 'data/cache_model.dart';
import 'map_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();
    final cacheModel = context.watch<CacheModel>();
    final user = auth.user;
    final name = user?.displayName?.trim();
    final email = user?.email;
    final greeting = name?.isNotEmpty == true
        ? name!
        : (email ?? 'Geocachare');

    return Scaffold(
      appBar: AppBar(
        title: Text('Hej, $greeting'),
        actions: [
          IconButton(
            tooltip: 'Logga ut',
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
              'Du har ${cacheModel.caches.length} cacher sparade.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final cacheModel = context.read<CacheModel>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: cacheModel,
                      child: const MapPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.map_outlined),
              label: const Text('Öppna kartan'),
            ),
          ],
        ),
      ),
    );
  }
}
