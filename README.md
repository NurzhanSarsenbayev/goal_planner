# Goal Planner

A local-first personal planning and progress-tracking application built with Flutter.

Goal Planner turns long-term goals into actionable tasks and brings daily planning, habits, reminders, reports, and body tracking into one application. The project is designed to work without an account or external backend: user data is stored locally with Drift and SQLite.

> **Status:** MVP in active development. Android is the primary tested platform.

## Highlights

- Create goals and break them down into tasks
- Plan tasks by date and optional time
- Work from Today, Calendar, All Tasks, and Goal Details views
- Create and manage recurring tasks
- Track habits separately from one-time tasks
- Schedule task, habit, standalone, and daily review reminders
- Review progress through reports
- Export local backups and restore data from JSON
- Track daily weight, weekly averages, body measurements, BMI, and estimated body fat
- Switch between English and Russian

## Engineering Focus

This project is not only a UI prototype. It includes application logic, persistence, scheduling, data recovery, and automated tests.

Key implementation areas:

- Local-first persistence with Drift and SQLite
- Feature-oriented project structure
- Repository and application-service layers
- Scheduled local notifications with timezone support
- Transactional backup and restore flows
- Recurring task generation and occurrence management
- Validation and recovery for reminder scheduling
- Unit and widget test coverage for core features
- Real-device Android testing

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Database:** Drift, SQLite
- **Notifications:** `flutter_local_notifications`
- **Localization:** Flutter localization tools, `intl`
- **File handling:** `file_selector`, `path_provider`, `share_plus`
- **Testing:** `flutter_test`
- **Code generation:** `build_runner`, `drift_dev`

## Project Structure

```text
lib/
├── app/        # Application shell and top-level composition
├── data/       # Drift database, repositories, and persistence
├── features/   # Feature-specific UI and application logic
├── l10n/       # English and Russian localization
├── models/     # Domain models
├── shared/     # Shared services, widgets, and helpers
├── state/      # Application state and coordinators
└── main.dart

test/
├── backup/
├── body_tracking/
├── calendar/
├── goals/
├── habits/
├── recurring/
├── reminders/
├── reports/
├── tasks/
└── today/
```

## Main Features

### Planning

Goals, one-time tasks, optional scheduling time, calendar views, and a focused Today screen form the core planning workflow.

### Recurring Tasks

Recurring rules generate task occurrences that can be completed, skipped, rescheduled, or cancelled independently.

### Habits and Reminders

Habits have their own tracking flow and optional reminder time. The application also supports task reminders, standalone one-time or daily reminders, and a configurable daily review reminder.

### Backup and Restore

Application data can be exported as a versioned JSON backup. Restore operations validate the selected file and use a transactional flow to avoid leaving the local database in a partially restored state.

### Progress and Body Tracking

The progress area combines planning reports with daily weight entries, skipped weigh-ins, weekly averages, body measurements, BMI, and estimated body-fat calculations.

## Getting Started

### Requirements

- Flutter SDK with Dart 3.11.5 or newer
- Android Studio or another Flutter-compatible IDE
- An Android emulator or physical Android device

### Run locally

```bash
git clone https://github.com/NurzhanSarsenbayev/goal_planner.git
cd goal_planner
flutter pub get
flutter run
```

If generated Drift files need to be refreshed:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Checks

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## Android Notes

Scheduled notifications require notification permissions. On some Android devices, reliable background delivery can also depend on battery optimization and background activity settings.

## Current Focus

- Continued real-device testing
- UI and UX refinement
- Progress analytics
- Reliability improvements around scheduling and local data

## Author

**Nurzhan Sarsenbayev**

- [GitHub](https://github.com/NurzhanSarsenbayev)
- [LinkedIn](https://www.linkedin.com/in/nurzhan-sarsenbayev/)
- 