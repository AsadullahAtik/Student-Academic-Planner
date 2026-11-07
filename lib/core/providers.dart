import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/database/local_repository.dart';
import '../core/models.dart';

// ─── Shared Preferences ───────────────────────────────────────────────────
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

// ─── Local Repository ─────────────────────────────────────────────────────
final localRepositoryProvider = Provider<LocalRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalRepository(prefs);
});

// ─── Settings Provider ─────────────────────────────────────────────────────
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final repo = ref.read(localRepositoryProvider);
    return repo.getSettings();
  }

  void update(AppSettings s) {
    final repo = ref.read(localRepositoryProvider);
    repo.saveSettings(s);
    state = s;
  }

  void setThemeMode(ThemeMode mode) {
    update(state.copyWith(themeMode: mode));
  }

  void setUserName(String name) => update(state.copyWith(userName: name));
  void setSemester(String s) => update(state.copyWith(semester: s));
  void setDepartment(String d) => update(state.copyWith(department: d));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

// ─── Subjects Provider ─────────────────────────────────────────────────────
class SubjectsNotifier extends Notifier<List<Subject>> {
  @override
  List<Subject> build() {
    return ref.read(localRepositoryProvider).getSubjects();
  }

  void _persist() {
    ref.read(localRepositoryProvider).saveSubjects(state);
  }

  void add(Subject s) {
    state = [...state, s];
    _persist();
  }

  void update(Subject s) {
    state = state.map((e) => e.id == s.id ? s : e).toList();
    _persist();
  }

  void delete(String id) {
    state = state.where((e) => e.id != id).toList();
    _persist();
  }

  Subject? findById(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

final subjectsProvider = NotifierProvider<SubjectsNotifier, List<Subject>>(
  SubjectsNotifier.new,
);

// ─── Classes / Timetable Provider ─────────────────────────────────────────
class ClassesNotifier extends Notifier<List<ClassSlot>> {
  @override
  List<ClassSlot> build() {
    return ref.read(localRepositoryProvider).getClasses();
  }

  void _persist() {
    ref.read(localRepositoryProvider).saveClasses(state);
  }

  void add(ClassSlot c) {
    state = [...state, c];
    _persist();
  }

  void update(ClassSlot c) {
    state = state.map((e) => e.id == c.id ? c : e).toList();
    _persist();
  }

  void delete(String id) {
    state = state.where((e) => e.id != id).toList();
    _persist();
  }

  List<ClassSlot> forDay(String day) =>
      state.where((c) => c.day == day).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
}

final classesProvider = NotifierProvider<ClassesNotifier, List<ClassSlot>>(
  ClassesNotifier.new,
);

// ─── Assignments Provider ─────────────────────────────────────────────────
class AssignmentsNotifier extends Notifier<List<Assignment>> {
  @override
  List<Assignment> build() {
    return ref.read(localRepositoryProvider).getAssignments();
  }

  void _persist() {
    ref.read(localRepositoryProvider).saveAssignments(state);
  }

  void add(Assignment a) {
    state = [...state, a];
    _persist();
  }

  void update(Assignment a) {
    state = state.map((e) => e.id == a.id ? a : e).toList();
    _persist();
  }

  void delete(String id) {
    state = state.where((e) => e.id != id).toList();
    _persist();
  }

  void setProgress(String id, int pct) {
    final a = state.firstWhere((e) => e.id == id, orElse: () => throw StateError('Not found'));
    update(a.withProgress(pct));
  }

  void toggleComplete(String id) {
    final a = state.firstWhere((e) => e.id == id, orElse: () => throw StateError('Not found'));
    if (a.status == AssignmentStatus.completed) {
      update(a.withProgress(0));
    } else {
      update(a.withProgress(100));
    }
  }
}

final assignmentsProvider =
    NotifierProvider<AssignmentsNotifier, List<Assignment>>(
  AssignmentsNotifier.new,
);

// ─── Exams Provider ───────────────────────────────────────────────────────
class ExamsNotifier extends Notifier<List<Exam>> {
  @override
  List<Exam> build() {
    return ref.read(localRepositoryProvider).getExams();
  }

  void _persist() {
    ref.read(localRepositoryProvider).saveExams(state);
  }

  void add(Exam e) {
    state = [...state, e];
    _persist();
  }

  void update(Exam e) {
    state = state.map((x) => x.id == e.id ? e : x).toList();
    _persist();
  }

  void delete(String id) {
    state = state.where((e) => e.id != id).toList();
    _persist();
  }

  void updatePrepStatus(String id, String status) {
    final e = state.firstWhere((x) => x.id == id, orElse: () => throw StateError('Not found'));
    update(e.copyWith(prepStatus: status));
  }
}

final examsProvider = NotifierProvider<ExamsNotifier, List<Exam>>(
  ExamsNotifier.new,
);

// ─── Study Sessions Provider ──────────────────────────────────────────────
class StudySessionsNotifier extends Notifier<List<StudySession>> {
  @override
  List<StudySession> build() {
    return ref.read(localRepositoryProvider).getSessions();
  }

  void _persist() {
    ref.read(localRepositoryProvider).saveSessions(state);
  }

  void add(StudySession s) {
    state = [...state, s];
    _persist();
  }

  void update(StudySession s) {
    state = state.map((e) => e.id == s.id ? s : e).toList();
    _persist();
  }

  void delete(String id) {
    state = state.where((e) => e.id != id).toList();
    _persist();
  }

  void setProgress(String id, int pct) {
    final s = state.firstWhere((e) => e.id == id, orElse: () => throw StateError('Not found'));
    update(s.withProgress(pct));
  }

  void toggleComplete(String id) {
    final s = state.firstWhere((e) => e.id == id, orElse: () => throw StateError('Not found'));
    update(s.withProgress(s.completed ? 0 : 100));
  }
}

final studySessionsProvider =
    NotifierProvider<StudySessionsNotifier, List<StudySession>>(
  StudySessionsNotifier.new,
);

// ─── Notes Provider ───────────────────────────────────────────────────────
class NotesNotifier extends Notifier<List<Note>> {
  @override
  List<Note> build() {
    return ref.read(localRepositoryProvider).getNotes();
  }

  void _persist() {
    ref.read(localRepositoryProvider).saveNotes(state);
  }

  void add(Note n) {
    state = [...state, n];
    _persist();
  }

  void update(Note n) {
    state = state.map((e) => e.id == n.id ? n : e).toList();
    _persist();
  }

  void delete(String id) {
    state = state.where((e) => e.id != id).toList();
    _persist();
  }
}

final notesProvider = NotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

// ─── Convenience derived providers ───────────────────────────────────────
final pendingAssignmentsProvider = Provider<List<Assignment>>((ref) {
  return ref
      .watch(assignmentsProvider)
      .where((a) => a.status != AssignmentStatus.completed)
      .toList();
});

final upcomingExamsProvider = Provider<List<Exam>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(examsProvider)
      .where((e) => e.date.isAfter(now))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

final activeSesssionsProvider = Provider<List<StudySession>>((ref) {
  return ref
      .watch(studySessionsProvider)
      .where((s) => !s.completed)
      .toList();
});
