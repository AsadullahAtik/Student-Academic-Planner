import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme/app_colors.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});

  final Widget child;

  static int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/timetable')) return 1;
    if (location.startsWith('/assignments')) return 2;
    if (location.startsWith('/subjects')) return 3;
    if (location.startsWith('/tools')) return 4;
    return 0; // Home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/timetable');
        break;
      case 2:
        context.go('/assignments');
        break;
      case 3:
        context.go('/subjects');
        break;
      case 4:
        context.go('/tools');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: child,
        ),
      ),
      bottomNavigationBar: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                  label: 'Routine',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment_rounded, color: AppColors.primary),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded, color: AppColors.primary),
                  label: 'Subjects',
                ),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.primary),
                  label: 'Tools',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
