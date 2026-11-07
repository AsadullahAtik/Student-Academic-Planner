import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../app/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final repo = ref.watch(localRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Storage'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile / Academic Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Profile',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(settings.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${settings.semester}\n${settings.department}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        _showEditProfileDialog(context, ref, settings);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Appearance Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appearance & Theme',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark Theme (Default)'),
                    value: ThemeMode.dark,
                    groupValue: settings.themeMode,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(settingsProvider.notifier).setThemeMode(val);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light Theme'),
                    value: ThemeMode.light,
                    groupValue: settings.themeMode,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(settingsProvider.notifier).setThemeMode(val);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('System Default'),
                    value: ThemeMode.system,
                    groupValue: settings.themeMode,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(settingsProvider.notifier).setThemeMode(val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Data Backup & Restore
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Backup & Management',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Export your local SQLite/JSON data for backup, or share it.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.file_upload_outlined),
                          label: const Text('Export JSON'),
                          onPressed: () {
                            final data = repo.exportAll();
                            final jsonStr = jsonEncode(data);
                            Share.share(
                              jsonStr,
                              subject: 'Academic Planner Backup Data',
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.file_download_outlined),
                          label: const Text('Restore Data'),
                          onPressed: () {
                            _showRestoreDialog(context, ref, repo);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_forever, color: AppColors.danger),
                    title: const Text(
                      'Clear All Application Data',
                      style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Resets all subjects, timetable, tasks, and notes.',
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      _showClearDataConfirmation(context, ref, repo);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: Text(
              'Student Academic Planner v1.0.0 (Offline-First)\nPrototype 2 Spec Compatible (No Attendance/CGPA)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    final nameCtrl = TextEditingController(text: settings.userName);
    final semesterCtrl = TextEditingController(text: settings.semester);
    final deptCtrl = TextEditingController(text: settings.department);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Student Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Student Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: semesterCtrl,
              decoration: const InputDecoration(labelText: 'Semester'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: deptCtrl,
              decoration: const InputDecoration(labelText: 'Department'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).update(
                    settings.copyWith(
                      userName: nameCtrl.text.trim(),
                      semester: semesterCtrl.text.trim(),
                      department: deptCtrl.text.trim(),
                    ),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(
      BuildContext context, WidgetRef ref, dynamic repo) {
    final jsonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from Backup JSON'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste your exported JSON backup data below:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: jsonCtrl,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '{"subjects": [...], "assignments": [...]}',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final map = jsonDecode(jsonCtrl.text.trim()) as Map<String, dynamic>;
                repo.importAll(map);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data restored successfully! Please restart app.')),
                );
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid backup JSON: $e')),
                );
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmation(
      BuildContext context, WidgetRef ref, dynamic repo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Reset'),
        content: const Text(
          'Are you sure you want to delete all academic records? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              repo.clearAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared.')),
              );
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
