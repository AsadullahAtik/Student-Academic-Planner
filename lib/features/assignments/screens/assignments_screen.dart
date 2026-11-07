import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/pill_badge.dart';
import '../../core/widgets/progress_bar.dart';
import '../../app/theme/app_colors.dart';

class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  String filter = 'All'; // 'All', 'Pending', 'Completed'

  void _showAddEditAssignmentDialog([Assignment? existing]) {
    final subjects = ref.read(subjectsProvider);
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a subject first!')),
      );
      return;
    }

    String subjectId = existing?.subjectId ?? subjects.first.id;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.desc ?? '');
    AssignmentPriority priority = existing?.priority ?? AssignmentPriority.medium;
    DateTime deadline = existing?.deadline ?? DateTime.now().add(const Duration(days: 3));
    int progress = existing?.progress ?? 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'New Assignment' : 'Edit Assignment'),
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
                        labelText: 'Title / Task Name',
                        hintText: 'Lab Report 2',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description / Instructions',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<AssignmentPriority>(
                      value: priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: AssignmentPriority.values.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: p.color, size: 12),
                              const SizedBox(width: 8),
                              Text('${p.label} Priority'),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => priority = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Deadline Date', style: TextStyle(fontSize: 13)),
                      subtitle: Text(
                        '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today_outlined),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: deadline,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() => deadline = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    if (titleCtrl.text.trim().isEmpty) return;
                    final id = existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

                    final assignment = Assignment(
                      id: id,
                      subjectId: subjectId,
                      title: titleCtrl.text.trim(),
                      desc: descCtrl.text.trim(),
                      deadline: deadline,
                      priority: priority,
                      status: AssignmentStatusExt.fromProgress(progress),
                      progress: progress,
                    );

                    if (existing == null) {
                      ref.read(assignmentsProvider.notifier).add(assignment);
                    } else {
                      ref.read(assignmentsProvider.notifier).update(assignment);
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
    final assignments = ref.watch(assignmentsProvider);
    final subjects = ref.watch(subjectsProvider);

    List<Assignment> filtered = assignments;
    if (filter == 'Pending') {
      filtered = assignments.where((a) => a.status != AssignmentStatus.completed).toList();
    } else if (filter == 'Completed') {
      filtered = assignments.where((a) => a.status == AssignmentStatus.completed).toList();
    }

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
        title: const Text('Assignments & Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'New Task',
            onPressed: () => _showAddEditAssignmentDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Pending', 'Completed'].map((f) {
                final isSelected = filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => filter = f);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),

          // Task List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.task_alt_rounded,
                          size: 54,
                          color: AppColors.success,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'All clear!',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No tasks found in this section.',
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
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final a = filtered[index];
                      final sub = getSubject(a.subjectId);
                      final isDone = a.status == AssignmentStatus.completed;

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
                                          : AppColors.primary,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(assignmentsProvider.notifier)
                                          .toggleComplete(a.id);
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            PillBadge(
                                              label: a.priority.label,
                                              textColor: a.priority.color,
                                              bgColor: a.priority.color
                                                  .withOpacity(0.15),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              sub.code,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: sub.color,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            PillBadge(
                                              label: a.status.label,
                                              bgColor: isDone
                                                  ? AppColors.success
                                                      .withOpacity(0.15)
                                                  : AppColors.primary
                                                      .withOpacity(0.15),
                                              textColor: isDone
                                                  ? AppColors.success
                                                  : AppColors.primary,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          a.title,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            decoration: isDone
                                                ? TextDecoration.lineThrough
                                                : null,
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
                                        _showAddEditAssignmentDialog(a);
                                      } else if (val == 'delete') {
                                        ref
                                            .read(assignmentsProvider.notifier)
                                            .delete(a.id);
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
                                            style: TextStyle(
                                                color: AppColors.danger)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (a.desc.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 48),
                                  child: Text(
                                    a.desc,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 48),
                                child: Text(
                                  '📅 Due: ${a.deadline.toLocal().toString().split(' ')[0]}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: a.isOverdue
                                        ? AppColors.danger
                                        : AppColors.accent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Progress bar and Interactive Slider
                              ProgressBar(
                                progress: a.progress,
                                height: 8,
                              ),
                              const SizedBox(height: 8),
                              ProgressEditor(
                                initialProgress: a.progress,
                                onChanged: (val) {
                                  ref
                                      .read(assignmentsProvider.notifier)
                                      .setProgress(a.id, val);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New Task',
        onPressed: () => _showAddEditAssignmentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
