import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/models.dart';

void main() {
  group('Assignment Model and Progress Calculation Tests', () {
    test('Initial assignment progress sets correct status', () {
      final a0 = Assignment(
        id: '1',
        subjectId: 's1',
        title: 'Task 1',
        desc: '',
        deadline: DateTime.now(),
        priority: AssignmentPriority.high,
        status: AssignmentStatus.pending,
        progress: 0,
      );
      expect(a0.progress, 0);
      expect(a0.status, AssignmentStatus.pending);

      // In-progress update (e.g. 50%)
      final a50 = a0.withProgress(50);
      expect(a50.progress, 50);
      expect(a50.status, AssignmentStatus.inProgress);

      // Completed update (100%)
      final a100 = a0.withProgress(100);
      expect(a100.progress, 100);
      expect(a100.status, AssignmentStatus.completed);
    });

    test('Progress clamps between 0 and 100', () {
      final a = Assignment(
        id: '1',
        subjectId: 's1',
        title: 'Task Clamp',
        desc: '',
        deadline: DateTime.now(),
        priority: AssignmentPriority.low,
        status: AssignmentStatus.pending,
        progress: 0,
      );

      final over = a.withProgress(150);
      expect(over.progress, 100);
      expect(over.status, AssignmentStatus.completed);

      final under = a.withProgress(-20);
      expect(under.progress, 0);
      expect(under.status, AssignmentStatus.pending);
    });

    test('Overdue logic calculates accurately', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final overdueTask = Assignment(
        id: '1',
        subjectId: 's1',
        title: 'Past Task',
        desc: '',
        deadline: pastDate,
        priority: AssignmentPriority.high,
        status: AssignmentStatus.inProgress,
        progress: 60,
      );
      expect(overdueTask.isOverdue, true);

      final completedPastTask = overdueTask.withProgress(100);
      expect(completedPastTask.isOverdue, false);
    });
  });

  group('StudySession Model Tests', () {
    test('StudySession progress adjusts actualMinutes and completed flag', () {
      final ss = StudySession(
        id: 'ss1',
        subjectId: 's1',
        date: DateTime.now(),
        startTime: '10:00',
        plannedMinutes: 100,
        actualMinutes: 0,
        progress: 0,
        completed: false,
        goal: 'Read chapter 3',
      );

      final updated = ss.withProgress(80);
      expect(updated.progress, 80);
      expect(updated.actualMinutes, 80);
      expect(updated.completed, false);

      final done = ss.withProgress(100);
      expect(done.progress, 100);
      expect(done.actualMinutes, 100);
      expect(done.completed, true);
    });
  });

  group('Subject and Exam Models Serialization Tests', () {
    test('Subject toJson and fromJson preserve all fields', () {
      const sub = Subject(
        id: 's100',
        name: 'Artificial Intelligence',
        code: 'CSE-401',
        teacher: 'Dr. Turing',
        credit: 3.5,
        semester: '7th',
        colorHex: '#0D9488',
      );

      final json = sub.toJson();
      final revived = Subject.fromJson(json);

      expect(revived.id, sub.id);
      expect(revived.name, sub.name);
      expect(revived.code, sub.code);
      expect(revived.credit, 3.5);
      expect(revived.colorHex, '#0D9488');
    });

    test('Exam countdown calculation returns correct days', () {
      final now = DateTime.now();
      final futureDate = DateTime(now.year, now.month, now.day + 5, 10, 0);
      final exam = Exam(
        id: 'e1',
        subjectId: 's1',
        type: ExamType.midterm,
        title: 'OS Midterm',
        date: futureDate,
        time: '10:00 AM',
        location: 'Room 101',
        prepStatus: 'Reviewing',
      );

      expect(exam.daysUntil, 5);
    });
  });
}
