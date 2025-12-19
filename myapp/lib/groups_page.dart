import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/group_model.dart';
import 'l10n/app_localizations.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  bool _busy = false;
  static final TextEditingController _codeController = TextEditingController();

  Future<void> _createGroup() async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      useRootNavigator: false,
      builder: (context) => AlertDialog(
        title: Text(l.createGroup),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l.groupName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l.create),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    if (!mounted) return;

    setState(() => _busy = true);
    try {
      await context.read<GroupModel>().createGroup(name);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _joinGroup() async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      useRootNavigator: false,
      builder: (context) => AlertDialog(
        title: Text(l.joinGroup),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l.code),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l.join),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty) return;
    if (!mounted) return;

    setState(() => _busy = true);
    try {
      await context.read<GroupModel>().joinGroup(code.trim().toUpperCase());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<GroupModel>();
    final groups = model.groups;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.groups),
        actions: [
          IconButton(
            onPressed: _busy ? null : _joinGroup,
            icon: const Icon(Icons.group_add_outlined),
            tooltip: l.joinGroup,
          ),
          IconButton(
            onPressed: _busy ? null : _createGroup,
            icon: const Icon(Icons.add),
            tooltip: l.createGroup,
          ),
        ],
      ),
      body: model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (groups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: Text(l.noGroups)),
                  ),
                for (final group in groups)
                  ListTile(
                    title: Text(group.name),
                    subtitle: Text('${l.code}: ${group.code}'),
                    trailing: model.selectedGroupId == group.id ? const Icon(Icons.check_circle) : null,
                    onTap: () {
                      context.read<GroupModel>().selectGroup(group.id);
                      Navigator.of(context).maybePop();
                    },
                  ),
                const SizedBox(height: 12),
                Text(l.joinGroup),
                const SizedBox(height: 6),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l.code,
                    hintText: l.enterCode,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final code = _codeController.text.trim().toUpperCase();
                          if (code.isEmpty) return;
                          try {
                            await context.read<GroupModel>().joinGroup(code);
                            if (!mounted) return;
                            _codeController.clear();
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        },
                  child: Text(l.join),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _busy ? null : _createGroup,
                  child: Text(l.createGroup),
                ),
              ],
            ),
    );
  }
}
