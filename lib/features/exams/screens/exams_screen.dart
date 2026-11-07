import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/pill_badge.dart';
import '../../app/theme/app_colors.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  void _showAddEditExamDialog(BuildContext context, WidgetRef ref, [Exam? existing]) {
    final subjects = ref.read(subjectsProvider);
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a subject first!')),
      );
      return;
    }

    String subjectId = existing?.subjectId ?? subjects.first.id;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final timeCtrl = TextEditingController(text: existing?.time ?? '10:00 AM');
    final locationCtrl = TextEditingController(text: existing?.location ?? '');
    ExamType type = existing?.type ?? ExamType.midterm;
    DateTime date = existing?.date ?? DateTime.now().add(const Duration(days: 14));
    String prepStatus = existing?.prepStatus ?? 'Not Started';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Schedule Exam' : 'Edit Exam'),
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
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Exam Title',
                        hintText: 'Midterm Assessment',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<ExamType>(
                      value: type,
                      decoration: const InputDecoration(labelText: 'Exam Type'),
                      items: ExamType.values.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.label));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => type = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: timeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Time',
                              hintText: '10:00 AM',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: locationCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Hall / Room',
                              hintText: 'Hall B',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Exam Date', style: TextStyle(fontSize: 13)),
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
                    DropdownButtonFormField<String>(
                      value: prepStatus,
                      decoration: const InputDecoration(labelText: 'Preparation Status'),
                      items: ['Not Started', 'In Progress', 'Reviewing', 'Ready']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => prepStatus = val);
                      },
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
                    if (titleCtrl.text.trim().isEmpty) return;
                    final id = existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

                    final exam = Exam(
                      id: id,
                      subjectId: subjectId,
                      type: type,
                      title: titleCtrl.text.trim(),
                      date: date,
                      time: timeCtrl.text.trim(),
                      location: locationCtrl.text.trim().isNotEmpty ? locationCtrl.text.trim() : 'TBA',
                      prepStatus: prepStatus,
                    );

                    if (existing == null) {
                      ref.read(examsProvider.notifier).add(exam);
                    } else {
                      ref.read(examsProvider.notifier).update(exam);
                    }

                    Navigator.pop(ctx);
                  },
                  child: Text(existing == null ? 'Schedule' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exams = ref.watch(examsProvider);
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
        title: const Text('Exams & Quizzes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Exam',
            onPressed: () => _showAddEditExamDialog(context, ref),
          ),
        ],
      ),
      body: exams.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_late_outlined,
                    size: 54,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No exams scheduled',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + to schedule an upcoming quiz or final.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final e = exams[index];
                final sub = getSubject(e.subjectId);
                final daysLeft = e.daysUntil;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                PillBadge(
                                  label: e.type.label,
                                  bgColor: Colors.purple.withOpacity(0.15),
                                  textColor: Colors.purple,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  sub.code,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: sub.color,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: daysLeft <= 3
                                    ? AppColors.danger.withOpacity(0.15)
                                    : AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                daysLeft < 0
                                    ? 'Passed'
                                    : (daysLeft == 0 ? 'Today!' : '$daysLeft days left'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: daysLeft <= 3 ? AppColors.danger : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          e.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '📅 ${e.date.toLocal().toString().split(' ')[0]} at ${e.time}  •  📍 ${e.location}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Prep: ${e.prepStatus}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _showAddEditExamDialog(context, ref, e),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppColors.danger, size: 18),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    ref.read(examsProvider.notifier).delete(e.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Schedule Exam',
        onPressed: () => _showAddEditExamDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
