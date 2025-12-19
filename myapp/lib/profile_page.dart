import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/auth_model.dart';
import 'data/cache_model.dart';
import 'data/find_model.dart';
import 'data/group_model.dart';
import 'l10n/app_localizations.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AuthModel>();
    final groups = context.watch<GroupModel>();
    final cacheModel = context.watch<CacheModel>();
    final findModel = context.watch<FindModel>();

    final user = auth.user;
    final email = user?.email ?? '';
    final group = groups.selectedGroup;
    final createdCount = cacheModel.caches.where((c) => c.ownerId == user?.uid).length;
    final foundCount = findModel.foundCacheIds.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(email.isEmpty ? l.profile : email, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(group == null ? l.groups : group.name),
          const SizedBox(height: 16),
          Text('${l.createdCaches}: $createdCount'),
          const SizedBox(height: 4),
          Text('${l.foundCaches}: $foundCount'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            child: Text(l.settings),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              context.read<AuthModel>().signOut();
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: Text(l.logout),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Radera konto'),
                  content: const Text('Detta tar bort ditt konto. Vill du fortsätta?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Avbryt'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Radera'),
                    ),
                  ],
                ),
              );
              if (ok != true || !context.mounted) return;
              try {
                await context.read<AuthModel>().deleteAccount();
                if (!context.mounted) return;
                Navigator.of(context).popUntil((r) => r.isFirst);
              } on FirebaseAuthException catch (e) {
                if (!context.mounted) return;
                final msg = e.code == 'requires-recent-login'
                    ? 'Logga in igen och försök på nytt.'
                    : (e.message ?? e.code);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Radera konto'),
          ),
        ],
      ),
    );
  }
}
