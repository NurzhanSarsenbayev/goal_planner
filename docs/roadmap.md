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

Status: done.

Goal:

Build the first working version of the core loop without database or backend.

Implemented:

- Create Goal model.
- Create Milestone model.
- Create PlannerTask model.
- Add sample in-memory state.
- Build Goals screen.
- Build Goal Details screen.
- Add goal creation.
- Add task creation inside goal.
- Schedule task for today.
- Show scheduled tasks on Today screen.
- Complete task.
- Show simple goal progress.
- Add milestone tasks.
- Add direct goal tasks.
- Add standalone tasks from Today.

Result:

A user can manually test:

> create goal -> add milestone/direct task -> schedule for today -> complete task -> see progress

## Phase 3: Local-first persistence

Status: done.

Goal:

Make app data survive restarts.

Implemented:

- Add Drift.
- Create local SQLite database.
- Add goals table.
- Add milestones table.
- Add tasks table.
- Add PlannerRepository.
- Add database mappers.
- Replace in-memory-only storage with local persistence.
- Keep app state synchronized with local database.
- Persist:
    - goals;
    - milestones;
    - tasks;
    - completion state;
    - scheduled date;
    - task placement.

Result:

App data survives restart.

## Phase 4: Core MVP task/goal management

Status: mostly done.

Goal:

Make the app usable for personal testing of the goal-linked planning loop.

Implemented:

### Goals

- Create goal.
- Edit goal.
- Delete goal with strong confirmation.
- Show goal progress.

### Milestones

- Create milestone.
- Edit milestone.
- Delete milestone with choice:
    - move tasks to Direct tasks;
    - delete milestone and tasks.

### Tasks

- Create task from Goal Details.
- Create task from Today.
- Create standalone task.
- Create direct goal task.
- Create milestone task.
- Edit task.
- Delete task.
- Complete / uncomplete task.
- Plan task for Today.
- Remove task from Today.
- Attach standalone task to goal / milestone.
- Detach goal-linked task back to standalone.
- Move direct goal task to milestone.
- Move milestone task to Direct tasks.

### Screens

- Today screen.
- Goals screen.
- Goal Details screen.
- All Tasks screen.
- More screen.
- Calendar placeholder.

### Refactoring completed

- Extract GoalDetailsController.
- Extract AllTasksController.
- Extract app dialog helpers.
- Extract planner seed service.
- Add safer domain model update methods.
- Separate repository mappers.

Current result:

The app supports the main task placement lifecycle:

> Standalone task ↔ Direct goal task ↔ Milestone task

And the main execution loop:

> Goal -> Milestone / Direct task -> Today -> Complete -> Progress

## Phase 5: Date planning and calendar MVP

Status: not started.

Goal:

Move from “Today-only planning” to basic scheduled-date planning.

Tasks:

- Add date picker for task scheduling.
- Keep quick action: Plan today.
- Replace some “Plan today” flows with a more general Schedule action.
- Show scheduled date in TaskCard.
- Add simple Calendar screen.
- Start with list grouped by date, not a complex visual calendar grid.
- Support removing scheduled date while keeping task visible in All Tasks.

Expected result:

A user can schedule tasks not only for today, but for future dates.

## Phase 6: Reports MVP

Status: not started.

Goal:

Show useful progress feedback without overbuilding analytics.

Tasks:

- Add Done today section.
- Show completed tasks for selected day.
- Show completed tasks grouped by goal.
- Add simple daily report.
- Later: weekly report.

Expected result:

A user can see what was completed today and how it contributed to goals.

## Phase 7: Habits MVP

Status: not started.

Goal:

Add recurring daily behavior tracking only after task/date flow is stable.

Initial habit scope:

- Habit title.
- Daily checkbox.
- Optional time.
- Show timed habits in Today.
- Simple completion history.

Not doing initially:

- complex streak gamification;
- habit analytics;
- habit templates;
- weight tracker;
- expense tracker.

## Phase 8: Product validation

Status: not started.

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
- User understands the difference between standalone, direct goal, and milestone tasks.

Failure signals:

- User only uses it as a simple todo list.
- Goals are ignored.
- Milestones are ignored.
- Reports are ignored.
- User returns to previous planner.

## Phase 9: Backend and sync

Status: later.

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

## Product positioning

Current product direction:

A goal-linked daily planner, not a generic all-in-one life app.

Core loop:

> Goal -> Milestone / Direct task -> Today -> Complete -> Progress / Report

Main differentiator:

- connect long-term goals with daily execution;
- make task placement flexible;
- keep Today practical;
- avoid turning the app into a bloated “whole life” tracker too early.

## Current limitations

- Calendar screen is still a placeholder.
- No date picker yet.
- Tasks can only be planned quickly for Today.
- No recurring tasks.
- No habits.
- No reports.
- No search/filtering in All Tasks.
- No drag-and-drop planning.
- No cloud sync/backend.
- No auth.
- No design polish.
- Sample seed data still exists for development.
- State management is still custom ChangeNotifier-based; Riverpod is not introduced yet.

## Not doing now

- AI decomposition.
- Gamification.
- Weight tracker.
- Expense tracker.
- Complex calendar.
- Cloud backend.
- Subscriptions.
- iOS release.
- Heavy design polish.