import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/pill_badge.dart';
import '../../core/widgets/progress_bar.dart';
import '../../app/theme/app_colors.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);
    final classes = ref.watch(classesProvider);
    final assignments = ref.watch(assignmentsProvider);
    final exams = ref.watch(examsProvider);
    final sessions = ref.watch(studySessionsProvider);

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final selectedDayName = weekdays[selectedDate.weekday - 1];
    final dateStr = selectedDate.toLocal().toString().split(' ')[0];

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

    // Filter events for selected date
    final dateClasses = classes.where((c) => c.day == selectedDayName).toList();
    final dateAssignments = assignments.where((a) {
      return a.deadline.toLocal().toString().split(' ')[0] == dateStr;
    }).toList();
    final dateExams = exams.where((e) {
      return e.date.toLocal().toString().split(' ')[0] == dateStr;
    }).toList();
    final dateSessions = sessions.where((s) {
      return s.date.toLocal().toString().split(' ')[0] == dateStr;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unified Academic Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: 'Today',
            onPressed: () {
              setState(() => selectedDate = DateTime.now());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Date Picker Strip (7 days around selected)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(14, (index) {
                  final date = DateTime.now().add(Duration(days: index - 3));
                  final isSelected = date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;
                  final dayShort = weekdays[date.weekday - 1].substring(0, 3);

                  return GestureDetector(
                    onTap: () => setState(() => selectedDate = date),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayShort,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white70
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const Divider(),

          // Events List for Selected Day
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Schedule for $selectedDayName, $dateStr',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Classes section
                if (dateClasses.isNotEmpty) ...[
                  const Text('CLASSES',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const SizedBox(height: 6),
                  ...dateClasses.map((c) {
                    final sub = getSubject(c.subjectId);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.school, color: AppColors.primary),
                        title: Text('${sub.code} - ${sub.name}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${c.startTime} - ${c.endTime} • ${c.room}',
                            style: const TextStyle(fontSize: 11)),
                        trailing: PillBadge(label: c.type.label),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // Exams section
                if (dateExams.isNotEmpty) ...[
                  const Text('EXAMS',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger)),
                  const SizedBox(height: 6),
                  ...dateExams.map((e) {
                    final sub = getSubject(e.subjectId);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.assignment_late,
                            color: AppColors.danger),
                        title: Text(e.title,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${sub.code} at ${e.time} • ${e.location}',
                            style: const TextStyle(fontSize: 11)),
                        trailing: PillBadge(
                          label: e.type.label,
                          textColor: AppColors.danger,
                          bgColor: AppColors.danger.withOpacity(0.15),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // Assignments due section
                if (dateAssignments.isNotEmpty) ...[
                  const Text('ASSIGNMENTS DUE',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent)),
                  const SizedBox(height: 6),
                  ...dateAssignments.map((a) {
                    final sub = getSubject(a.subjectId);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${sub.code}: ${a.title}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                PillBadge(
                                  label: a.priority.label,
                                  textColor: a.priority.color,
                                  bgColor: a.priority.color.withOpacity(0.15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ProgressBar(
                              progress: a.progress,
                              height: 6,
                              labelFontSize: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // Study Sessions section
                if (dateSessions.isNotEmpty) ...[
                  const Text('STUDY TARGETS',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary)),
                  const SizedBox(height: 6),
                  ...dateSessions.map((ss) {
                    final sub = getSubject(ss.subjectId);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${sub.code}: ${ss.goal}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                PillBadge(
                                  label: '${ss.plannedMinutes}m',
                                  textColor: AppColors.secondary,
                                  bgColor: AppColors.secondary.withOpacity(0.15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ProgressBar(
                              progress: ss.progress,
                              height: 6,
                              labelFontSize: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],

                if (dateClasses.isEmpty &&
                    dateExams.isEmpty &&
                    dateAssignments.isEmpty &&
                    dateSessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No events recorded for this date.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
