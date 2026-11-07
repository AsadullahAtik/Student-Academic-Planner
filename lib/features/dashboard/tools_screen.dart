import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Modules & Tools'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildToolCard(
            context,
            title: 'Study Planner',
            subtitle: 'Focus sessions & goals',
            icon: Icons.psychology_rounded,
            color: AppColors.accent,
            onTap: () => context.push('/study'),
          ),
          _buildToolCard(
            context,
            title: 'Unified Calendar',
            subtitle: 'Exams, tasks & routine',
            icon: Icons.calendar_month_rounded,
            color: Colors.purple,
            onTap: () => context.push('/calendar'),
          ),
          _buildToolCard(
            context,
            title: 'Subject Notes',
            subtitle: 'Lecture summaries & formulas',
            icon: Icons.edit_note_rounded,
            color: AppColors.secondary,
            onTap: () => context.push('/notes'),
          ),
          _buildToolCard(
            context,
            title: 'Exams & Quizzes',
            subtitle: 'Schedules & countdown',
            icon: Icons.assignment_late_rounded,
            color: AppColors.danger,
            onTap: () => context.push('/exams'),
          ),
          _buildToolCard(
            context,
            title: 'Settings',
            subtitle: 'Data backup, restore & themes',
            icon: Icons.settings_rounded,
            color: Colors.blueGrey,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
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
}
