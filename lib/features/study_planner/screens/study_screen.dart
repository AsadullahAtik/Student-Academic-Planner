import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/pill_badge.dart';
import '../../core/widgets/progress_bar.dart';
import '../../app/theme/app_colors.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  void _showAddEditSessionDialog([StudySession? existing]) {
    final subjects = ref.read(subjectsProvider);
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a subject first!')),
      );
      return;
    }

    String subjectId = existing?.subjectId ?? subjects.first.id;
    final goalCtrl = TextEditingController(text: existing?.goal ?? '');
    final durationCtrl = TextEditingController(text: existing?.plannedMinutes.toString() ?? '60');
    final timeCtrl = TextEditingController(text: existing?.startTime ?? '19:00');
    DateTime date = existing?.date ?? DateTime.now();
    int progress = existing?.progress ?? 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'New Study Session' : 'Edit Study Session'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: subjectId,
                      decoration: const InputDecoration(labelText: 'Subject'),
                      items: subjects.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text('${s.code} - ${s.name}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => subjectId = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: goalCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Study Goal / Topic',
                        hintText: 'Chapter 4 Algorithms practice',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: durationCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Planned Mins',
                              hintText: '60',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: timeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
                              hintText: '19:00',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Target Date', style: TextStyle(fontSize: 13)),
                      subtitle: Text(
                        date.toLocal().toString().split(' ')[0],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today_outlined),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: date,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() => date = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Initial Progress: $progress%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Slider(
                          value: progress.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          onChanged: (val) {
                            setDialogState(() => progress = val.round());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (goalCtrl.text.trim().isEmpty) return;
                    final id = existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                    final planned = int.tryParse(durationCtrl.text.trim()) ?? 60;

                    final session = StudySession(
                      id: id,
                      subjectId: subjectId,
                      date: date,
                      startTime: timeCtrl.text.trim(),
                      plannedMinutes: planned,
                      actualMinutes: (planned * progress / 100).round(),
                      progress: progress,
                      completed: progress >= 100,
                      goal: goalCtrl.text.trim(),
                    );

                    if (existing == null) {
                      ref.read(studySessionsProvider.notifier).add(session);
                    } else {
                      ref.read(studySessionsProvider.notifier).update(session);
                    }

                    Navigator.pop(ctx);
                  },
                  child: Text(existing == null ? 'Create' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(studySessionsProvider);
    final subjects = ref.watch(subjectsProvider);

    Subject getSubject(String id) {
      return subjects.firstWhere(
        (s) => s.id == id,
        orElse: () => const Subject(
          id: '?',
          name: 'General',
          code: 'GEN',
          teacher: '',
          credit: 0,
          semester: '',
          colorHex: '#4F46E5',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New Session',
            onPressed: () => _showAddEditSessionDialog(),
          ),
        ],
      ),
      body: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.psychology_outlined,
                    size: 54,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No study sessions planned',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + to create a study target and set progress bars.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final ss = sessions[index];
                final sub = getSubject(ss.subjectId);
                final isDone = ss.completed || ss.progress >= 100;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isDone
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isDone
                                    ? AppColors.success
                                    : AppColors.accent,
                              ),
                              onPressed: () {
                                ref
                                    .read(studySessionsProvider.notifier)
                                    .toggleComplete(ss.id);
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        sub.code,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: sub.color,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      PillBadge(
                                        label: '${ss.plannedMinutes} min target',
                                        bgColor:
                                            AppColors.accent.withOpacity(0.15),
                                        textColor: AppColors.accent,
                                      ),
                                      if (isDone) ...[
                                        const SizedBox(width: 6),
                                        const PillBadge(
                                          label: 'Completed',
                                          bgColor: Colors.greenAccent,
                                          textColor: Colors.green,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ss.goal,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      decoration:
                                          isDone ? TextDecoration.lineThrough : null,
                                      color: isDone
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5)
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showAddEditSessionDialog(ss);
                                } else if (val == 'delete') {
                                  ref
                                      .read(studySessionsProvider.notifier)
                                      .delete(ss.id);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete',
                                      style:
                                          TextStyle(color: AppColors.danger)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 48),
                          child: Text(
                            '📅 ${ss.date.toLocal().toString().split(' ')[0]} at ${ss.startTime} • Done: ${ss.actualMinutes}/${ss.plannedMinutes}m',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Progress Bar & Slider
                        ProgressBar(
                          progress: ss.progress,
                          height: 8,
                        ),
                        const SizedBox(height: 8),
                        ProgressEditor(
                          initialProgress: ss.progress,
                          onChanged: (val) {
                            ref
                                .read(studySessionsProvider.notifier)
                                .setProgress(ss.id, val);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New Session',
        onPressed: () => _showAddEditSessionDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
