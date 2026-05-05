# Habits Phase 7 Design Contract

## Status

Phase 7A implemented.

The first habit tracking loop is now available locally:

- create habit;
- edit habit;
- archive/delete habit;
- show active habits in a weekly journal layout;
- mark a habit date as done, failed or skipped;
- clear an existing mark;
- navigate between weeks;
- persist habits and habit entries locally.

Phase 7B is not started.

This document defines the first Habits implementation scope before writing code.

The goal is to add habit tracking as a separate product loop without growing `PlannerStore` back into a god object.

## Product direction

Habits are not recurring tasks.

A recurring task represents planned work that appears in Today/Calendar and can be completed as a task.

A habit represents repeated behavior tracked over days, usually in a weekly grid, with history and progress.

The first Habits version should support a simple and fast daily tracking loop:

- create a habit;
- see it in a weekly grid;
- mark a date;
- change previous dates;
- persist everything locally;
- reopen the app and keep the data.

## Architecture rule

Habits must not be added directly into `PlannerStore`.

Do not add these to `PlannerStore`:

- `_habits`;
- `_habitEntries`;
- `addHabit`;
- `updateHabit`;
- `deleteHabit`;
- `markHabitDone`;
- habit persistence logic.

Habits should have their own feature area and state boundary.

Expected structure:

```text
lib/features/habits/
  domain/
  application/
  presentation/
```

Expected application objects:

```text
HabitStore
HabitApplicationService
HabitRepository
```

Expected data object:

```text
DriftHabitRepository
```

`PlannerStore` remains responsible for the existing goal/task planning loop only.

## Scope: Phase 7A

Phase 7A focuses on the habit tracking core.

Included:

- Habit domain model.
- Habit entry/progress domain model.
- Habit entry status model.
- Drift tables for habits and habit entries.
- Habit repository interface.
- Drift habit repository.
- Habit application service.
- Habit store.
- Basic Habits screen.
- Weekly habit grid.
- Create habit.
- Edit habit.
- Archive/delete habit.
- Mark habit date as:
    - done;
    - failed;
    - skipped.
- Change an existing mark.
- Navigate between weeks.
- Persist habit data locally.

Not included:

- reminders;
- graphs;
- daily diary;
- habit notes;
- multiple check-ins UI;
- advanced statistics;
- habit groups/journals;
- backend/sync;
- Riverpod migration.

## Journal decision

For now, "Journal" is not a separate domain entity.

It is treated as the Habits section / All Habits screen.

Do not create `HabitJournal` in Phase 7A.

If real grouping is needed later, it can be introduced after the first habit loop is validated.

## Habit model

A habit is a tracked repeated behavior.

Initial fields:

```text
Habit
  id
  title
  description?
  trackingType
  targetCount?
  sortOrder
  isArchived
  createdAt
  updatedAt
```

## Tracking type

The system should support future expansion beyond simple yes/no habits.

Tracking types:

```text
binary
count
```

Phase 7A UI may only expose binary habits.

However, the domain/database should be designed so count-based habits can be added later without rewriting the model.

Examples:

```text
Взвеситься
  trackingType = binary
  targetCount = null

Выпить воду 8 раз
  trackingType = count
  targetCount = 8

Сделать 3 подхода
  trackingType = count
  targetCount = 3
```

## Habit entry / daily progress

A habit entry represents habit progress for a specific date.

Initial fields:

```text
HabitEntry
  id
  habitId
  date
  status
  completedCount
  note?
  createdAt
  updatedAt
```

Phase 7A may use one effective entry per habit/date in the UI.

The model should still leave room for future multiple check-ins per day.

## Entry status

Supported statuses:

```text
none
done
incomplete
failed
skipped
```

Meaning:

```text
none
  No mark exists for the date.

done
  Habit target was completed.

incomplete
  Count-based habit was partially completed but did not reach target.

failed
  User explicitly marked the habit as not completed.

skipped
  User intentionally skipped the habit for a valid reason.
```

Statistics rule:

```text
failed counts as a failure.
skipped does not count as a failure.
```

For future completion rate:

```text
completion rate = done / (done + failed + incomplete)
```

`skipped` should usually be excluded from the denominator.

## Count-based habits

Count-based habits are designed now but may be exposed later.

Future behavior:

```text
targetCount = required count per day
completedCount = current progress for that date
```

Status calculation:

```text
completedCount >= targetCount
  status = done

completedCount > 0 and completedCount < targetCount
  status = incomplete

completedCount == 0
  status = none, unless user explicitly marks failed or skipped
```

Phase 7A UI can ignore this and create only binary habits.

Do not block future count-based behavior by using a boolean-only schema.

## Reminders

Reminders are not part of Phase 7A.

They should be a separate future feature, not a habit-only subsystem.

Future reminder model should support targets:

```text
none
habit
task
diary
```

Possible future fields:

```text
Reminder
  id
  title
  time
  recurrenceRule
  targetType?
  targetId?
  isEnabled
```

Examples:

```text
21:30 Внести расходы
  targetType = none

07:30 Взвеситься
  targetType = habit

10:00 Сделать задачу
  targetType = task

22:00 Заполнить дневник
  targetType = diary
```

Do not design reminders inside Habits in Phase 7A.

## Daily diary

Daily diary is not part of Phase 7A.

It should be a separate future feature.

Diary entry is not the same thing as a habit note.

Future model:

```text
DailyDiaryEntry
  id
  date
  text
  createdAt
  updatedAt
```

Purpose:

- daily reflection;
- emotional summary;
- free writing;
- retrospective of the day.

Do not mix diary text into habit entries.

## UI direction

The first habit UI should be inspired by the provided reference screenshots, but not copy everything at once.

Phase 7A screen should focus on:

- current week;
- list of habits;
- one row per habit;
- seven day cells per row;
- quick marking for selected habit/date.

Minimum weekly grid behavior:

```text
tap empty cell -> choose done / failed / skipped
tap marked cell -> change status or clear
week navigation -> previous / current / next week
```

Advanced UI postponed:

- graphs tab;
- reminders screen;
- reorder screen polish;
- notes screen;
- archive management screen;
- animations;
- custom colors/icons.

## Store boundary

`HabitStore` should own habit state.

Expected responsibilities:

- load habits and entries;
- expose active habits;
- expose entries for visible week;
- create/update/archive habits;
- mark habit entry;
- navigate selected week or accept selected week from UI;
- notify habit UI.

`HabitStore` should not know about:

- goals;
- tasks;
- milestones;
- recurring task rules;
- planner reports.

## Repository boundary

`HabitRepository` should hide Drift details.

Expected methods may include:

```text
loadHabits()
loadEntriesForRange(startDate, endDate)
saveHabit(habit)
saveEntry(entry)
archiveHabit(habitId)
deleteHabit(habitId)
```

Exact signatures can be refined during implementation.

## Testing direction

At minimum, Phase 7 should add tests for:

- habit status calculation;
- binary habit marking;
- skipped not counting as failure;
- count-based status calculation, even if UI is postponed;
- repository/store behavior for creating and marking habits.

## Definition of Done for Phase 7A

- Habits are implemented outside `PlannerStore`.
- User can create a habit.
- User can see habits in a weekly grid.
- User can mark a habit date as done/failed/skipped.
- User can change an existing mark.
- User can navigate weeks.
- Habit data persists locally.
- Existing planner task/goal flows still work.
- `flutter analyze` passes.
- `flutter test` passes.
- Manual run passes.

## Explicitly deferred

- habit reminders;
- task reminders;
- diary reminders;
- daily diary;
- habit graphs;
- advanced habit statistics;
- multiple check-ins UI;
- habit grouping/journals;
- Riverpod migration;
- backend/sync.