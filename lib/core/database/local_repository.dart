import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models.dart';

/// Central local-storage repository.
/// All data is stored as JSON in SharedPreferences.
/// Keys are prefixed with [_prefix] to avoid collisions.
class LocalRepository {
  static const _prefix = 'ap_';
  static const _keySubjects = '${_prefix}subjects';
  static const _keyClasses = '${_prefix}classes';
  static const _keyAssignments = '${_prefix}assignments';
  static const _keyExams = '${_prefix}exams';
  static const _keySessions = '${_prefix}study_sessions';
  static const _keyNotes = '${_prefix}notes';
  static const _keySettings = '${_prefix}settings';

  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  LocalRepository(this._prefs) {
    _seedIfEmpty();
  }

  String get newId => _uuid.v4();

  // ─── SEED ──────────────────────────────────────────────────────────────
  void _seedIfEmpty() {
    if (_prefs.containsKey(_keySubjects)) return;
    final now = DateTime.now();

    final subjects = [
      Subject(id: 's1', name: 'Operating Systems', code: 'CSE-311', teacher: 'Dr. K. Rahman', credit: 3.0, semester: '5th', colorHex: '#4F46E5'),
      Subject(id: 's2', name: 'Database Systems', code: 'CSE-313', teacher: 'Prof. Farhana Haque', credit: 3.0, semester: '5th', colorHex: '#0D9488'),
      Subject(id: 's3', name: 'Software Engineering', code: 'CSE-315', teacher: 'Engr. M. Tariq', credit: 3.0, semester: '5th', colorHex: '#F59E0B'),
      Subject(id: 's4', name: 'Computer Networks', code: 'CSE-317', teacher: 'Dr. A. Chowdhury', credit: 3.0, semester: '5th', colorHex: '#EC4899'),
      Subject(id: 's5', name: 'Numerical Methods', code: 'MTH-205', teacher: 'Dr. Shafiul Alam', credit: 3.0, semester: '5th', colorHex: '#8B5CF6'),
    ];

    final classes = [
      ClassSlot(id: 'c1', subjectId: 's1', day: 'Sunday', startTime: '09:00', endTime: '10:30', room: 'Lab-402', teacher: 'Dr. K. Rahman', type: ClassType.lecture),
      ClassSlot(id: 'c2', subjectId: 's2', day: 'Sunday', startTime: '11:00', endTime: '12:30', room: 'Room-501', teacher: 'Prof. Farhana', type: ClassType.lecture),
      ClassSlot(id: 'c3', subjectId: 's3', day: 'Monday', startTime: '10:00', endTime: '11:30', room: 'Room-302', teacher: 'Engr. Tariq', type: ClassType.lecture),
      ClassSlot(id: 'c4', subjectId: 's1', day: 'Tuesday', startTime: '14:00', endTime: '16:00', room: 'OS Lab 1', teacher: 'Dr. K. Rahman', type: ClassType.lab),
      ClassSlot(id: 'c5', subjectId: 's4', day: 'Wednesday', startTime: '09:30', endTime: '11:00', room: 'Room-204', teacher: 'Dr. A. Chowdhury', type: ClassType.lecture),
      ClassSlot(id: 'c6', subjectId: 's5', day: 'Thursday', startTime: '11:30', endTime: '13:00', room: 'Room-105', teacher: 'Dr. Shafiul', type: ClassType.tutorial),
    ];

    final assignments = [
      Assignment(id: 'a1', subjectId: 's1', title: 'Process Synchronization & Semaphore Lab Report', desc: 'Implement producer-consumer problem using POSIX semaphores.', deadline: now.add(const Duration(days: 2)), priority: AssignmentPriority.high, status: AssignmentStatus.inProgress, progress: 65),
      Assignment(id: 'a2', subjectId: 's2', title: 'B+ Tree Indexing Queries', desc: 'Solve SQL benchmark optimization problems.', deadline: now.add(const Duration(days: 5)), priority: AssignmentPriority.medium, status: AssignmentStatus.pending, progress: 20),
      Assignment(id: 'a3', subjectId: 's3', title: 'Sprint Backlog & User Stories', desc: 'Submit Jira project link and PDF export.', deadline: now.add(const Duration(days: 8)), priority: AssignmentPriority.low, status: AssignmentStatus.completed, progress: 100),
    ];

    final exams = [
      Exam(id: 'e1', subjectId: 's1', type: ExamType.midterm, title: 'Operating Systems Midterm', date: now.add(const Duration(days: 11)), time: '10:00 AM', location: 'Auditorium Hall B', prepStatus: 'In Progress'),
      Exam(id: 'e2', subjectId: 's2', type: ExamType.quiz, title: 'Relational Algebra Quiz 2', date: now.add(const Duration(days: 4)), time: '11:15 AM', location: 'Room 501', prepStatus: 'Not Started'),
      Exam(id: 'e3', subjectId: 's4', type: ExamType.practical, title: 'Packet Tracer Network Lab Exam', date: now.add(const Duration(days: 18)), time: '02:00 PM', location: 'Network Lab 2', prepStatus: 'Reviewing'),
    ];

    final sessions = [
      StudySession(id: 'ss1', subjectId: 's1', date: now, startTime: '19:00', plannedMinutes: 90, actualMinutes: 75, progress: 85, completed: false, goal: "Deadlock prevention and Banker's Algorithm"),
      StudySession(id: 'ss2', subjectId: 's2', date: now.add(const Duration(days: 1)), startTime: '20:30', plannedMinutes: 60, actualMinutes: 20, progress: 35, completed: false, goal: '2NF and 3NF Normalization rules practice'),
    ];

    final notes = [
      Note(id: 'n1', subjectId: 's1', title: 'Race Condition & Critical Section Notes', content: 'A critical section is a piece of code that accesses shared resources. 3 criteria: Mutual Exclusion, Progress, Bounded Waiting.', createdAt: now.subtract(const Duration(days: 2)), updatedAt: now.subtract(const Duration(days: 2))),
      Note(id: 'n2', subjectId: 's5', title: 'Runge-Kutta 4th Order Formulas', content: 'y_{n+1} = y_n + 1/6(k1 + 2k2 + 2k3 + k4)h. Very high numerical stability.', createdAt: now.subtract(const Duration(days: 3)), updatedAt: now.subtract(const Duration(days: 3))),
    ];

    _saveList(_keySubjects, subjects.map((e) => e.toJson()).toList());
    _saveList(_keyClasses, classes.map((e) => e.toJson()).toList());
    _saveList(_keyAssignments, assignments.map((e) => e.toJson()).toList());
    _saveList(_keyExams, exams.map((e) => e.toJson()).toList());
    _saveList(_keySessions, sessions.map((e) => e.toJson()).toList());
    _saveList(_keyNotes, notes.map((e) => e.toJson()).toList());
    _saveSettings(const AppSettings(
      userName: 'Shakib Al Hasan',
      semester: 'Spring 2026 (Semester 5)',
      department: 'Computer Science & Engineering',
    ));
  }

  // ─── GENERIC HELPERS ───────────────────────────────────────────────────
  void _saveList(String key, List<Map<String, dynamic>> list) {
    _prefs.setString(key, jsonEncode(list));
  }

  List<Map<String, dynamic>> _loadList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  // ─── SUBJECTS ─────────────────────────────────────────────────────────
  List<Subject> getSubjects() =>
      _loadList(_keySubjects).map(Subject.fromJson).toList();

  void saveSubjects(List<Subject> list) =>
      _saveList(_keySubjects, list.map((e) => e.toJson()).toList());

  Subject addSubject(Subject s) {
    final list = getSubjects()..add(s);
    saveSubjects(list);
    return s;
  }

  void updateSubject(Subject s) {
    final list = getSubjects().map((e) => e.id == s.id ? s : e).toList();
    saveSubjects(list);
  }

  void deleteSubject(String id) {
    saveSubjects(getSubjects().where((e) => e.id != id).toList());
  }

  // ─── CLASSES ─────────────────────────────────────────────────────────
  List<ClassSlot> getClasses() =>
      _loadList(_keyClasses).map(ClassSlot.fromJson).toList();

  void saveClasses(List<ClassSlot> list) =>
      _saveList(_keyClasses, list.map((e) => e.toJson()).toList());

  ClassSlot addClass(ClassSlot c) {
    final list = getClasses()..add(c);
    saveClasses(list);
    return c;
  }

  void updateClass(ClassSlot c) {
    final list = getClasses().map((e) => e.id == c.id ? c : e).toList();
    saveClasses(list);
  }

  void deleteClass(String id) {
    saveClasses(getClasses().where((e) => e.id != id).toList());
  }

  // ─── ASSIGNMENTS ─────────────────────────────────────────────────────
  List<Assignment> getAssignments() =>
      _loadList(_keyAssignments).map(Assignment.fromJson).toList();

  void saveAssignments(List<Assignment> list) =>
      _saveList(_keyAssignments, list.map((e) => e.toJson()).toList());

  Assignment addAssignment(Assignment a) {
    final list = getAssignments()..add(a);
    saveAssignments(list);
    return a;
  }

  void updateAssignment(Assignment a) {
    final list = getAssignments().map((e) => e.id == a.id ? a : e).toList();
    saveAssignments(list);
  }

  void deleteAssignment(String id) {
    saveAssignments(getAssignments().where((e) => e.id != id).toList());
  }

  // ─── EXAMS ───────────────────────────────────────────────────────────
  List<Exam> getExams() =>
      _loadList(_keyExams).map(Exam.fromJson).toList();

  void saveExams(List<Exam> list) =>
      _saveList(_keyExams, list.map((e) => e.toJson()).toList());

  Exam addExam(Exam e) {
    final list = getExams()..add(e);
    saveExams(list);
    return e;
  }

  void updateExam(Exam e) {
    final list = getExams().map((x) => x.id == e.id ? e : x).toList();
    saveExams(list);
  }

  void deleteExam(String id) {
    saveExams(getExams().where((e) => e.id != id).toList());
  }

  // ─── STUDY SESSIONS ──────────────────────────────────────────────────
  List<StudySession> getSessions() =>
      _loadList(_keySessions).map(StudySession.fromJson).toList();

  void saveSessions(List<StudySession> list) =>
      _saveList(_keySessions, list.map((e) => e.toJson()).toList());

  StudySession addSession(StudySession s) {
    final list = getSessions()..add(s);
    saveSessions(list);
    return s;
  }

  void updateSession(StudySession s) {
    final list = getSessions().map((e) => e.id == s.id ? s : e).toList();
    saveSessions(list);
  }

  void deleteSession(String id) {
    saveSessions(getSessions().where((e) => e.id != id).toList());
  }

  // ─── NOTES ───────────────────────────────────────────────────────────
  List<Note> getNotes() =>
      _loadList(_keyNotes).map(Note.fromJson).toList();

  void saveNotes(List<Note> list) =>
      _saveList(_keyNotes, list.map((e) => e.toJson()).toList());

  Note addNote(Note n) {
    final list = getNotes()..add(n);
    saveNotes(list);
    return n;
  }

  void updateNote(Note n) {
    final list = getNotes().map((e) => e.id == n.id ? n : e).toList();
    saveNotes(list);
  }

  void deleteNote(String id) {
    saveNotes(getNotes().where((e) => e.id != id).toList());
  }

  // ─── SETTINGS ────────────────────────────────────────────────────────
  AppSettings getSettings() {
    final raw = _prefs.getString(_keySettings);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  void _saveSettings(AppSettings s) {
    _prefs.setString(_keySettings, jsonEncode(s.toJson()));
  }

  void saveSettings(AppSettings s) => _saveSettings(s);

  // ─── BACKUP / RESTORE ─────────────────────────────────────────────────
  Map<String, dynamic> exportAll() => {
        'subjects': _loadList(_keySubjects),
        'classes': _loadList(_keyClasses),
        'assignments': _loadList(_keyAssignments),
        'exams': _loadList(_keyExams),
        'studySessions': _loadList(_keySessions),
        'notes': _loadList(_keyNotes),
        'settings': getSettings().toJson(),
        'exportedAt': DateTime.now().toIso8601String(),
      };

  void importAll(Map<String, dynamic> data) {
    if (data['subjects'] != null) {
      _saveList(_keySubjects, (data['subjects'] as List).cast<Map<String, dynamic>>());
    }
    if (data['classes'] != null) {
      _saveList(_keyClasses, (data['classes'] as List).cast<Map<String, dynamic>>());
    }
    if (data['assignments'] != null) {
      _saveList(_keyAssignments, (data['assignments'] as List).cast<Map<String, dynamic>>());
    }
    if (data['exams'] != null) {
      _saveList(_keyExams, (data['exams'] as List).cast<Map<String, dynamic>>());
    }
    if (data['studySessions'] != null) {
      _saveList(_keySessions, (data['studySessions'] as List).cast<Map<String, dynamic>>());
    }
    if (data['notes'] != null) {
      _saveList(_keyNotes, (data['notes'] as List).cast<Map<String, dynamic>>());
    }
    if (data['settings'] != null) {
      _saveSettings(AppSettings.fromJson(data['settings'] as Map<String, dynamic>));
    }
  }

  void clearAll() {
    _prefs.remove(_keySubjects);
    _prefs.remove(_keyClasses);
    _prefs.remove(_keyAssignments);
    _prefs.remove(_keyExams);
    _prefs.remove(_keySessions);
    _prefs.remove(_keyNotes);
    _prefs.remove(_keySettings);
  }
}
