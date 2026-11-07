# 🎓 Student Academic Planner (Flutter Mobile & Web)

A modern, responsive, offline-first Flutter application designed for students to organize courses, weekly class routines, assignment progress with interactive bars, exams, daily study goals, and lecture notes.

> **Specification Note**: Built according to **Prototype 2** specifications:
> - **Attendance & CGPA modules omitted**
> - **Interactive Progress Bars & Sliders added for Assignments, Study Planner & Calendar**
> - **Offline-first architecture** with full local JSON/SQLite persistence and Backup/Restore.

---

## 📱 Features

1. **Dashboard (Home View)**:
   - Greeting, current active semester, and academic department details.
   - Live KPI cards: Today's class count, pending tasks, active study targets.
   - Today's routine slots with Next Class indicator.
   - Upcoming deadlines and exam countdowns.
2. **Weekly Timetable / Class Routine**:
   - Day-of-week switcher tabs (Sunday–Saturday).
   - Lecture, Lab, and Tutorial slot categorization.
   - Room number, instructor name, and time slots.
3. **Assignments & Tasks**:
   - Filter by All, Pending, or Completed.
   - Priority badges (Low, Medium, High).
   - **Interactive visual progress bar**: slider + preset buttons (`25%`, `50%`, `75%`, `100%`).
   - Automatically updates status (`Pending` -> `In Progress` -> `Completed`).
4. **Enrolled Subjects Management**:
   - Course name, code, credit hours, semester, teacher name.
   - Dynamic subject color palette tags.
   - Overview of weekly classes and pending tasks per course.
5. **Study Planner**:
   - Focus sessions with planned duration and goals.
   - Live percentage progress bar with presets.
6. **Unified Academic Calendar**:
   - Date picker strip showing integrated classes, exam countdowns, due tasks, and study sessions in one unified timeline.
7. **Subject Notes**:
   - Fast keyword search across lecture notes and summaries.
8. **Settings & Data Management**:
   - Dark, Light, and System Theme modes.
   - Student profile editor.
   - Complete JSON Export & Import (Backup & Restore).
   - Safe reset of all local data.

---

## 🛠️ Tech Stack & Architecture

- **Flutter & Dart** (Material Design 3)
- **Riverpod** (`flutter_riverpod`) for reactive state management
- **GoRouter** (`go_router`) for declarative navigation with responsive bottom bar
- **SharedPreferences / Local JSON Persistence** for instant, offline-first reliability
- **Automated Tests**: Unit tests for progress calculations and widget tests for progress bars & chips

---

## 🧪 Running Unit & Widget Tests

To verify all test cases locally:

```bash
cd academic_planner
flutter test
```

### What is tested:
- `test/unit/academic_models_test.dart`:
  - Assignment progress calculation logic (0% -> Pending, 50% -> In Progress, 100% -> Completed).
  - Value clamping (0 to 100%).
  - Overdue date detection logic.
  - Study session duration calculation based on completion percentage.
  - Model serialization and exam countdown logic.
- `test/widget/core_widgets_test.dart`:
  - `PillBadge` rendering.
  - `ProgressBar` animated width and percentage text.
  - `ProgressEditor` slider and preset click callbacks (25%, 50%, 75%, 100%).

---

## 🚀 How to Run the App

1. Ensure Flutter is installed on your computer:
   ```bash
   flutter doctor
   ```
2. Navigate into the project folder:
   ```bash
   cd academic_planner
   ```
3. Get packages:
   ```bash
   flutter pub get
   ```
4. Run on your connected device, Chrome, or Emulator:
   ```bash
   flutter run
   ```

---

## 📤 Pushing to GitHub

To push this codebase to your GitHub repository:

```bash
cd e:\RimasProject
git init
git add .
git commit -m "feat: complete academic planner flutter app from prototype2 with progress bars and tests"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```
