import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/timetable/screens/timetable_screen.dart';
import '../features/assignments/screens/assignments_screen.dart';
import '../features/subjects/screens/subjects_screen.dart';
import '../features/dashboard/tools_screen.dart';
import '../features/study_planner/screens/study_screen.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/notes/screens/notes_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/exams/screens/exams_screen.dart';
import 'scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/timetable',
          name: 'timetable',
          builder: (context, state) => const TimetableScreen(),
        ),
        GoRoute(
          path: '/assignments',
          name: 'assignments',
          builder: (context, state) => const AssignmentsScreen(),
        ),
        GoRoute(
          path: '/subjects',
          name: 'subjects',
          builder: (context, state) => const SubjectsScreen(),
        ),
        GoRoute(
          path: '/tools',
          name: 'tools',
          builder: (context, state) => const ToolsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/study',
      name: 'study',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const StudyScreen(),
    ),
    GoRoute(
      path: '/calendar',
      name: 'calendar',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/notes',
      name: 'notes',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotesScreen(),
    ),
    GoRoute(
      path: '/exams',
      name: 'exams',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ExamsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
