import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/pill_badge.dart';
import '../../app/theme/app_colors.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  void _showAddEditSubjectDialog(BuildContext context, WidgetRef ref, [Subject? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final teacherCtrl = TextEditingController(text: existing?.teacher ?? '');
    final creditCtrl = TextEditingController(text: existing?.credit.toString() ?? '3.0');
    final semesterCtrl = TextEditingController(text: existing?.semester ?? '5th');
    String colorHex = existing?.colorHex ?? '#4F46E5';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add New Course' : 'Edit Course'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Subject / Course Name',
                        hintText: 'Operating Systems',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: codeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Course Code',
                              hintText: 'CSE-311',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: creditCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Credits',
                              hintText: '3.0',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: teacherCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Instructor / Teacher',
                        hintText: 'Dr. John Doe',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: semesterCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                        hintText: '5th',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Color Tag:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppColors.subjectPalette.map((color) {
                        final hex = AppColors.colorToHex(color);
                        final isSelected = hex == colorHex;
                        return GestureDetector(
                          onTap: () => setDialogState(() => colorHex = hex),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
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
                    if (nameCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) return;
                    final id = existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                    final credit = double.tryParse(creditCtrl.text.trim()) ?? 3.0;

                    final sub = Subject(
                      id: id,
                      name: nameCtrl.text.trim(),
                      code: codeCtrl.text.trim(),
                      teacher: teacherCtrl.text.trim(),
                      credit: credit,
                      semester: semesterCtrl.text.trim(),
                      colorHex: colorHex,
                    );

                    if (existing == null) {
                      ref.read(subjectsProvider.notifier).add(sub);
                    } else {
                      ref.read(subjectsProvider.notifier).update(sub);
                    }

                    Navigator.pop(ctx);
                  },
                  child: Text(existing == null ? 'Add' : 'Save'),
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
    final subjects = ref.watch(subjectsProvider);
    final classes = ref.watch(classesProvider);
    final assignments = ref.watch(assignmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Subject',
            onPressed: () => _showAddEditSubjectDialog(context, ref),
          ),
        ],
      ),
      body: subjects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 54,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No enrolled subjects',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + to add your first course.',
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
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final s = subjects[index];
                final subClasses = classes.where((c) => c.subjectId == s.id).toList();
                final pendingTasks = assignments
                    .where((a) => a.subjectId == s.id && a.status != AssignmentStatus.completed)
                    .toList();

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
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: s.color,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  s.code,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PillBadge(
                                  label: '${s.credit} Credits',
                                  bgColor: AppColors.primary.withOpacity(0.1),
                                  textColor: AppColors.primary,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Edit',
                                  onPressed: () => _showAddEditSubjectDialog(context, ref, s),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppColors.danger, size: 18),
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    ref.read(subjectsProvider.notifier).delete(s.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (s.teacher.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '👤 ${s.teacher}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '📅 ${subClasses.length} weekly classes',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                            Text(
                              '📝 ${pendingTasks.length} pending task(s)',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
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
        tooltip: 'Add Subject',
        onPressed: () => _showAddEditSubjectDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
