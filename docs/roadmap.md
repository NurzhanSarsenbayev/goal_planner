# Roadmap

## Phase 0: Setup

Status: done.

- Install Flutter.
- Install Android Studio.
- Configure Android emulator.
- Create Flutter project.
- Run app on emulator.
- Commit initial project.

## Phase 1: App shell

Status: done.

- Replace counter app.
- Add Material 3 theme.
- Add bottom navigation.
- Add Today, Goals, Calendar, More placeholder screens.

## Phase 2: In-memory prototype

Goal:

Build the first working version of the core loop without database or backend.

Tasks:

- Create Goal model.
- Create Task model.
- Add sample in-memory state.
- Build Goals screen.
- Build Goal Details screen.
- Add goal creation.
- Add task creation inside goal.
- Schedule task for today.
- Show scheduled tasks on Today screen.
- Complete task.
- Show simple goal progress.

Expected result:

A user can manually test:

> create goal -> add task -> schedule for today -> complete task -> see progress

## Phase 3: Local-first persistence

Goal:

Make app data survive restarts.

Tasks:

- Add Drift.
- Create local database.
- Add goals table.
- Add tasks table.
- Add repositories.
- Replace in-memory storage with local storage.

## Phase 4: Real MVP features

Goal:

Make app useful for 7-14 day personal testing.

Tasks:

- Add basic habits.
- Add simple daily report.
- Add simple calendar view.
- Add simple recurring tasks.
- Improve empty states.
- Improve UX for task completion and rescheduling.

## Phase 5: Product validation

Goal:

Test whether the product idea is actually useful.

Validation plan:

- Give app to first real user for 7-14 days.
- Track what is used daily.
- Track what is ignored.
- Track what creates friction.
- Do not add large new features during validation.

Success signals:

- User opens Today daily.
- User creates goals.
- User links tasks to goals.
- User completes tasks.
- User checks progress/report.

Failure signals:

- User only uses it as a simple todo list.
- Goals are ignored.
- Reports are ignored.
- User returns to previous planner.

## Phase 6: Backend and sync

Only after local MVP is validated.

Potential backend stack:

- FastAPI
- PostgreSQL
- Redis
- Docker
- Alembic
- JWT

Backend responsibilities:

- accounts;
- backup;
- sync;
- AI endpoint later;
- subscription later.

## Current checkpoint

Implemented:

- app shell with bottom navigation;
- in-memory goals and tasks;
- goal details screen;
- task completion;
- goal progress;
- task creation inside goal;
- task scheduling for today;
- goal creation;
- milestones inside goals;
- direct goal tasks;
- standalone task creation from Today.

Current limitation:

- data is in-memory only and is lost after app restart.