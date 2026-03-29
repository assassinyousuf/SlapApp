import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../application/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Use AI Detection Mode'),
            subtitle: const Text('Toggle between Rule-based and TensorFlow Lite model'),
            value: state.aiModeEnabled,
            onChanged: (val) {
              final current = ref.read(appStateProvider);
              ref.read(appStateProvider.notifier).updateState(current.copyWith(aiModeEnabled: val));
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Slap Sensitivity Threshold'),
            subtitle: Text('Current: ${state.sensitivity.toStringAsFixed(1)} (Lower = More sensitive)'),
          ),
          Slider(
            value: state.sensitivity,
            min: 5,
            max: 50,
            divisions: 45,
            label: state.sensitivity.toStringAsFixed(1),
            onChanged: (val) {
              final current = ref.read(appStateProvider);
              ref.read(appStateProvider.notifier).updateState(current.copyWith(sensitivity: val));
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Sound Pack'),
            subtitle: Text(state.selectedSoundPack),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Future sound pack selection
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton.icon(
              onPressed: () async {
                final storageStr = ref.read(storageServiceProvider);
                final files = await storageStr.getDatasetFiles();
                if (files.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No datasets found to export.')),
                    );
                  }
                  return;
                }
                
                final xFiles = files.map((f) => XFile(f.path)).toList();
                // ignore: deprecated_member_use
                await Share.shareXFiles(xFiles, text: 'SlapSense Dataset Export');
              },
              icon: const Icon(Icons.share),
              label: const Text('Export Dataset Files'),
            ),
          ),
        ],
      ),
    );
  }
}
