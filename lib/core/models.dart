// Core models for the Academic Planner app
// All fields match prototype2.html data structure

import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

// ─── Subject ───────────────────────────────────────────────────────────────
class Subject {
  final String id;
  final String name;
  final String code;
  final String teacher;
  final double credit;
  final String semester;
  final String colorHex;

  const Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.teacher,
    required this.credit,
    required this.semester,
    required this.colorHex,
  });

  Color get color => AppColors.hexToColor(colorHex);

  Subject copyWith({
    String? id,
    String? name,
    String? code,
    String? teacher,
    double? credit,
    String? semester,
    String? colorHex,
  }) =>
      Subject(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        teacher: teacher ?? this.teacher,
        credit: credit ?? this.credit,
        semester: semester ?? this.semester,
        colorHex: colorHex ?? this.colorHex,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'teacher': teacher,
        'credit': credit,
        'semester': semester,
        'colorHex': colorHex,
      };

  factory Subject.fromJson(Map<String, dynamic> j) => Subject(
        id: j['id'] as String,
        name: j['name'] as String,
        code: j['code'] as String,
        teacher: j['teacher'] as String,
        credit: (j['credit'] as num).toDouble(),
        semester: j['semester'] as String,
        colorHex: j['colorHex'] as String? ?? '#4F46E5',
      );
}

// ─── Class / Timetable Slot ────────────────────────────────────────────────
enum ClassType { lecture, lab, tutorial }

extension ClassTypeExt on ClassType {
  String get label {
    switch (this) {
      case ClassType.lecture:
        return 'Lecture';
      case ClassType.lab:
        return 'Lab';
      case ClassType.tutorial:
        return 'Tutorial';
    }
  }

  static ClassType fromString(String s) {
    switch (s.toLowerCase()) {
      case 'lab':
        return ClassType.lab;
      case 'tutorial':
        return ClassType.tutorial;
      default:
        return ClassType.lecture;
    }
  }
}

class ClassSlot {
  final String id;
  final String subjectId;
  final String day; // 'Sunday'..'Saturday'
  final String startTime; // 'HH:mm'
  final String endTime;
  final String room;
  final String teacher;
  final ClassType type;

  const ClassSlot({
    required this.id,
    required this.subjectId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.teacher,
    required this.type,
  });

  ClassSlot copyWith({
    String? id,
    String? subjectId,
    String? day,
    String? startTime,
    String? endTime,
    String? room,
    String? teacher,
    ClassType? type,
  }) =>
      ClassSlot(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        day: day ?? this.day,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        room: room ?? this.room,
        teacher: teacher ?? this.teacher,
        type: type ?? this.type,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'day': day,
        'startTime': startTime,
        'endTime': endTime,
        'room': room,
        'teacher': teacher,
        'type': type.label,
      };

  factory ClassSlot.fromJson(Map<String, dynamic> j) => ClassSlot(
        id: j['id'] as String,
        subjectId: subjectId ?? this.subjectId,
        day: j['day'] as String,
        startTime: j['startTime'] as String,
        endTime: j['endTime'] as String,
        room: j['room'] as String,
        teacher: j['teacher'] as String,
        type: ClassTypeExt.fromString(j['type'] as String? ?? 'Lecture'),
      );
}

// ─── Assignment ────────────────────────────────────────────────────────────
enum AssignmentPriority { low, medium, high }

extension AssignmentPriorityExt on AssignmentPriority {
  String get label {
    switch (this) {
      case AssignmentPriority.low:
        return 'Low';
      case AssignmentPriority.medium:
        return 'Medium';
      case AssignmentPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case AssignmentPriority.low:
        return AppColors.secondary;
      case AssignmentPriority.medium:
        return AppColors.accent;
      case AssignmentPriority.high:
        return AppColors.danger;
    }
  }

  static AssignmentPriority fromString(String s) {
    switch (s.toLowerCase()) {
      case 'high':
        return AssignmentPriority.high;
      case 'medium':
        return AssignmentPriority.medium;
      default:
        return AssignmentPriority.low;
    }
  }
}

enum AssignmentStatus { pending, inProgress, completed }

extension AssignmentStatusExt on AssignmentStatus {
  String get label {
    switch (this) {
      case AssignmentStatus.pending:
        return 'Pending';
      case AssignmentStatus.inProgress:
        return 'In Progress';
      case AssignmentStatus.completed:
        return 'Completed';
    }
  }

  static AssignmentStatus fromString(String s) {
    switch (s.toLowerCase().replaceAll(' ', '')) {
      case 'completed':
        return AssignmentStatus.completed;
      case 'inprogress':
        return AssignmentStatus.inProgress;
      default:
        return AssignmentStatus.pending;
    }
  }

  static AssignmentStatus fromProgress(int progress) {
    if (progress >= 100) return AssignmentStatus.completed;
    if (progress > 0) return AssignmentStatus.inProgress;
    return AssignmentStatus.pending;
  }
}

class Assignment {
  final String id;
  final String subjectId;
  final String title;
  final String desc;
  final DateTime deadline;
  final AssignmentPriority priority;
  final AssignmentStatus status;
  final int progress; // 0–100

  const Assignment({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.desc,
    required this.deadline,
    required this.priority,
    required this.status,
    required this.progress,
  });

  bool get isOverdue =>
      status != AssignmentStatus.completed && deadline.isBefore(DateTime.now());

  Assignment copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? desc,
    DateTime? deadline,
    AssignmentPriority? priority,
    AssignmentStatus? status,
    int? progress,
  }) =>
      Assignment(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        desc: desc ?? this.desc,
        deadline: deadline ?? this.deadline,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        progress: progress ?? this.progress,
      );

  Assignment withProgress(int pct) {
    final clamped = pct.clamp(0, 100);
    return copyWith(
      progress: clamped,
      status: AssignmentStatusExt.fromProgress(clamped),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'title': title,
        'desc': desc,
        'deadline': deadline.toIso8601String(),
        'priority': priority.label,
        'status': status.label,
        'progress': progress,
      };

  factory Assignment.fromJson(Map<String, dynamic> j) {
    final progress = (j['progress'] as num?)?.toInt() ?? 0;
    return Assignment(
      id: j['id'] as String,
      subjectId: j['subjectId'] as String,
      title: j['title'] as String,
      desc: j['desc'] as String? ?? '',
      deadline: DateTime.parse(j['deadline'] as String),
      priority: AssignmentPriorityExt.fromString(j['priority'] as String? ?? 'Low'),
      status: j['status'] != null
          ? AssignmentStatusExt.fromString(j['status'] as String)
          : AssignmentStatusExt.fromProgress(progress),
      progress: progress,
    );
  }
}

// ─── Exam ──────────────────────────────────────────────────────────────────
enum ExamType { quiz, midterm, finalExam, practical }

extension ExamTypeExt on ExamType {
  String get label {
    switch (this) {
      case ExamType.quiz:
        return 'Quiz';
      case ExamType.midterm:
        return 'Midterm';
      case ExamType.finalExam:
        return 'Final';
      case ExamType.practical:
        return 'Practical';
    }
  }

  static ExamType fromString(String s) {
    switch (s.toLowerCase()) {
      case 'quiz':
        return ExamType.quiz;
      case 'midterm':
        return ExamType.midterm;
      case 'practical':
        return ExamType.practical;
      default:
        return ExamType.finalExam;
    }
  }
}

class Exam {
  final String id;
  final String subjectId;
  final ExamType type;
  final String title;
  final DateTime date;
  final String time; // '10:00 AM'
  final String location;
  final String prepStatus; // 'Not Started', 'In Progress', 'Reviewing', 'Ready'

  const Exam({
    required this.id,
    required this.subjectId,
    required this.type,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.prepStatus,
  });

  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDate = DateTime(date.year, date.month, date.day);
    return examDate.difference(today).inDays;
  }

  Exam copyWith({
    String? id,
    String? subjectId,
    ExamType? type,
    String? title,
    DateTime? date,
    String? time,
    String? location,
    String? prepStatus,
  }) =>
      Exam(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        type: type ?? this.type,
        title: title ?? this.title,
        date: date ?? this.date,
        time: time ?? this.time,
        location: location ?? this.location,
        prepStatus: prepStatus ?? this.prepStatus,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'type': type.label,
        'title': title,
        'date': date.toIso8601String().split('T').first,
        'time': time,
        'location': location,
        'prepStatus': prepStatus,
      };

  factory Exam.fromJson(Map<String, dynamic> j) => Exam(
        id: j['id'] as String,
        subjectId: j['subjectId'] as String,
        type: ExamTypeExt.fromString(j['type'] as String? ?? 'Final'),
        title: j['title'] as String,
        date: DateTime.parse(j['date'] as String),
        time: j['time'] as String,
        location: j['location'] as String? ?? '',
        prepStatus: j['prepStatus'] as String? ?? 'Not Started',
      );
}

// ─── Study Session ─────────────────────────────────────────────────────────
class StudySession {
  final String id;
  final String subjectId;
  final DateTime date;
  final String startTime;
  final int plannedMinutes;
  final int actualMinutes;
  final int progress; // 0–100
  final bool completed;
  final String goal;

  const StudySession({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.startTime,
    required this.plannedMinutes,
    required this.actualMinutes,
    required this.progress,
    required this.completed,
    required this.goal,
  });

  StudySession copyWith({
    String? id,
    String? subjectId,
    DateTime? date,
    String? startTime,
    int? plannedMinutes,
    int? actualMinutes,
    int? progress,
    bool? completed,
    String? goal,
  }) =>
      StudySession(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        date: date ?? this.date,
        startTime: startTime ?? this.startTime,
        plannedMinutes: plannedMinutes ?? this.plannedMinutes,
        actualMinutes: actualMinutes ?? this.actualMinutes,
        progress: progress ?? this.progress,
        completed: completed ?? this.completed,
        goal: goal ?? this.goal,
      );

  StudySession withProgress(int pct) {
    final clamped = pct.clamp(0, 100);
    return copyWith(
      progress: clamped,
      completed: clamped >= 100,
      actualMinutes: (plannedMinutes * clamped / 100).round(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'date': date.toIso8601String().split('T').first,
        'startTime': startTime,
        'plannedMinutes': plannedMinutes,
        'actualMinutes': actualMinutes,
        'progress': progress,
        'completed': completed,
        'goal': goal,
      };

  factory StudySession.fromJson(Map<String, dynamic> j) => StudySession(
        id: j['id'] as String,
        subjectId: j['subjectId'] as String,
        date: DateTime.parse(j['date'] as String),
        startTime: j['startTime'] as String,
        plannedMinutes: (j['plannedMinutes'] as num).toInt(),
        actualMinutes: (j['actualMinutes'] as num?)?.toInt() ?? 0,
        progress: (j['progress'] as num?)?.toInt() ?? 0,
        completed: j['completed'] as bool? ?? false,
        goal: j['goal'] as String? ?? '',
      );
}

// ─── Note ──────────────────────────────────────────────────────────────────
class Note {
  final String id;
  final String subjectId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Note(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'] as String,
        subjectId: j['subjectId'] as String,
        title: j['title'] as String,
        content: j['content'] as String? ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );
}

// ─── App Settings ──────────────────────────────────────────────────────────
class AppSettings {
  final ThemeMode themeMode;
  final String userName;
  final String semester;
  final String department;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.userName = 'Student',
    this.semester = 'Current Semester',
    this.department = 'Computer Science',
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? userName,
    String? semester,
    String? department,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        userName: userName ?? this.userName,
        semester: semester ?? this.semester,
        department: department ?? this.department,
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'userName': userName,
        'semester': semester,
        'department': department,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        themeMode: ThemeMode.values.firstWhere(
          (e) => e.name == j['themeMode'],
          orElse: () => ThemeMode.dark,
        ),
        userName: j['userName'] as String? ?? 'Student',
        semester: j['semester'] as String? ?? 'Current Semester',
        department: j['department'] as String? ?? 'Computer Science',
      );
}
