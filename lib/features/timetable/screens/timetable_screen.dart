import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/pill_badge.dart';
import '../../app/theme/app_colors.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  static const days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  String selectedDay = 'Sunday';

  @override
  void initState() {
    super.initState();
    final currentDay = days[DateTime.now().weekday % 7];
    selectedDay = currentDay;
  }

  void _showAddEditClassDialog([ClassSlot? existing]) {
    final subjects = ref.read(subjectsProvider);
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a subject first!')),
      );
      return;
    }

    String subjectId = existing?.subjectId ?? subjects.first.id;
    String day = existing?.day ?? selectedDay;
    ClassType type = existing?.type ?? ClassType.lecture;
    final startTimeCtrl = TextEditingController(text: existing?.startTime ?? '09:00');
    final endTimeCtrl = TextEditingController(text: existing?.endTime ?? '10:30');
    final roomCtrl = TextEditingController(text: existing?.room ?? '');
    final teacherCtrl = TextEditingController(text: existing?.teacher ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add Class Routine' : 'Edit Class'),
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
                    DropdownButtonFormField<String>(
                      value: day,
                      decoration: const InputDecoration(labelText: 'Day of Week'),
                      items: days.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d));
                      }).toList>,
                      onChanged: (val) {
                        if (val != null) setDialogState(() => day = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<ClassType>(
                      value: type,
                      decoration: const InputDecoration(labelText: 'Class Type'),
                      items: ClassType.values.map((t) {
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
                            controller: startTimeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
                              hintText: '09:00',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: endTimeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'End Time',
                              hintText: '10:30',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: roomCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Room / Lab',
                        hintText: 'Room 302',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: teacherCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Teacher / Instructor (Optional)',
                      ),
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
                    final id = existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                    final sub = subjects.firstWhere((s) => s.id == subjectId);
                    final teacher = teacherCtrl.text.trim().isNotEmpty
                        ? teacherCtrl.text.trim()
                        : sub.teacher;

                    final updatedSlot = ClassSlot(
                      id: id,
                      subjectId: subjectId,
                      day: day,
                      startTime: startTimeCtrl.text.trim(),
                      endTime: endTimeCtrl.text.trim(),
                      room: roomCtrl.text.trim().isNotEmpty ? roomCtrl.text.trim() : 'TBA',
                      teacher: teacher,
                      type: type,
                    );

                    if (existing == null) {
                      ref.read(classesProvider.notifier).add(updatedSlot);
                    } else {
                      ref.read(classesProvider.notifier).update(updatedSlot);
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
  Widget build(BuildContext context) {
    final classes = ref.watch(classesProvider);
    final subjects = ref.watch(subjectsProvider);

    final dayClasses = classes.where((c) => c.day == selectedDay).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

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
        title: const Text('Weekly Routine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Class',
            onPressed: () => _showAddEditClassDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Day Selector Tabs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: days.map((d) {
                  final isSelected = d == selectedDay;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(d),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => selectedDay = d);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(),

          // Class List
          Expanded(
            child: dayClasses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 54,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No classes on $selectedDay',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to add a class slot to this day.',
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
                    itemCount: dayClasses.length,
                    itemBuilder: (context, index) {
                      final c = dayClasses[index];
                      final sub = getSubject(c.subjectId);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _showAddEditClassDialog(c),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: sub.color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            label: c.type.label,
                                            bgColor: c.type == ClassType.lab
                                                ? AppColors.accent
                                                    .withOpacity(0.15)
                                                : AppColors.primary
                                                    .withOpacity(0.15),
                                            textColor: c.type == ClassType.lab
                                                ? AppColors.accent
                                                : AppColors.primary,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        sub.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '🕒 ${c.startTime} - ${c.endTime}  •  📍 ${c.room}  •  👤 ${c.teacher}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppColors.danger, size: 20),
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    ref
                                        .read(classesProvider.notifier)
                                        .delete(c.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Class',
        onPressed: () => _showAddEditClassDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
