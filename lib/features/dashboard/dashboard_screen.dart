import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/pill_badge.dart';
import '../../core/widgets/progress_bar.dart';
import '../../app/theme/app_colors.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final subjects = ref.watch(subjectsProvider);
    final classes = ref.watch(classesProvider);
    final assignments = ref.watch(assignmentsProvider);
    final exams = ref.watch(examsProvider);
    final studySessions = ref.watch(studySessionsProvider);

    final pendingAssignments =
        assignments.where((a) => a.status != AssignmentStatus.completed).toList();
    final activeGoals = studySessions.where((s) => !s.completed).toList();

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final todayDay = days[DateTime.now().weekday - 1];
    final todayClasses = classes.where((c) => c.day == todayDay).toList()
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Academic Planner',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  settings.semester,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              settings.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(settingsProvider.notifier).setThemeMode(
                    settings.themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Hi, ${settings.userName} 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            Text(
              '${settings.semester} • ${settings.department}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),

            // Top KPI Cards
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    context,
                    title: "Today's Class",
                    value: '${todayClasses.length}',
                    subtext: todayDay,
                    valueColor: AppColors.primary,
                    onTap: () => context.go('/timetable'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildKpiCard(
                    context,
                    title: 'Pending Tasks',
                    value: '${pendingAssignments.length}',
                    subtext: 'Deadlines',
                    valueColor: AppColors.accent,
                    onTap: () => context.go('/assignments'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildKpiCard(
                    context,
                    title: 'Study Goals',
                    value: '${activeGoals.length}',
                    subtext: 'Active',
                    valueColor: AppColors.secondary,
                    onTap: () => context.push('/study'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Action Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickPill(
                    context,
                    label: 'Routine',
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.primary,
                    onTap: () => context.go('/timetable'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickPill(
                    context,
                    label: 'Calendar',
                    icon: Icons.date_range_rounded,
                    color: AppColors.secondary,
                    onTap: () => context.push('/calendar'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickPill(
                    context,
                    label: 'Study Plan',
                    icon: Icons.psychology_rounded,
                    color: AppColors.accent,
                    onTap: () => context.push('/study'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickPill(
                    context,
                    label: 'Notes',
                    icon: Icons.edit_note_rounded,
                    color: Colors.purple,
                    onTap: () => context.push('/notes'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickPill(
                    context,
                    label: 'Exams',
                    icon: Icons.assignment_late_rounded,
                    color: AppColors.danger,
                    onTap: () => context.push('/exams'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Today's Routine Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_filled,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      "Today's Routine",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Text(
                  todayDay,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (todayClasses.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No classes scheduled for today! 🎉 Enjoy your day!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              )
            else
              ...todayClasses.map((c) {
                final sub = getSubject(c.subjectId);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: sub.color.withOpacity(0.15),
                      child: Text(
                        sub.code.length > 3 ? sub.code.substring(0, 3) : sub.code,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: sub.color,
                        ),
                      ),
                    ),
                    title: Text(
                      sub.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${c.startTime} - ${c.endTime} • ${c.room}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: PillBadge(
                      label: c.type.label,
                      bgColor: c.type == ClassType.lab
                          ? AppColors.accent.withOpacity(0.15)
                          : AppColors.primary.withOpacity(0.15),
                      textColor: c.type == ClassType.lab
                          ? AppColors.accent
                          : AppColors.primary,
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),

            // Tasks & Deadlines Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pending_actions_rounded,
                        size: 18, color: AppColors.accent),
                    SizedBox(width: 8),
                    Text(
                      'Upcoming Tasks & Deadlines',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.go('/assignments'),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (pendingAssignments.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No pending tasks! All caught up. 🚀',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              )
            else
              ...pendingAssignments.take(3).map((a) {
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
                            Row(
                              children: [
                                PillBadge(
                                  label: a.priority.label,
                                  textColor: a.priority.color,
                                  bgColor: a.priority.color.withOpacity(0.15),
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
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline,
                                  size: 20),
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Mark Complete',
                              onPressed: () {
                                ref
                                    .read(assignmentsProvider.notifier)
                                    .toggleComplete(a.id);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          a.title,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
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

            const SizedBox(height: 20),

            // Upcoming Exams Snapshot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assignment_late_outlined,
                        size: 18, color: AppColors.danger),
                    SizedBox(width: 8),
                    Text(
                      'Upcoming Exams',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.push('/exams'),
                  child: const Text(
                    '+ Add / View',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (exams.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No upcoming exams recorded.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              )
            else
              ...exams.take(2).map((e) {
                final sub = getSubject(e.subjectId);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      e.title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${e.date.toLocal().toString().split(' ')[0]} at ${e.time} • ${e.location}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: PillBadge(
                      label: e.type.label,
                      textColor: Colors.purple,
                      bgColor: Colors.purple.withOpacity(0.15),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtext,
    required Color valueColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: TextStyle(
                  fontSize: 10,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildQuickPill(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
