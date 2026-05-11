# Habits Phase 7 Design Contract

## Status

Phase 7C integration done.

The habit MVP is implemented as a separate product loop:

- create habit;
- edit habit;
- archive/unarchive habit;
- delete habit;
- show active habits in a weekly journal layout;
- mark a habit date as done, failed, skipped or clear;
- navigate between weeks;
- persist habits and habit entries locally;
- show Habits as a top-level tab;
- show lightweight habit summary on Today;
- show habit summary in Reports;
- track habit consistency;
- track skipped and missed marks separately;
- track current habit streak.

The goal of Phase 7 is to add habit tracking without turning habits into recurring tasks and without growing `PlannerStore` back into a god object.

## Product direction

Habits are not recurring tasks.

A recurring task represents planned work that appears in Today/Calendar as concrete task occurrences.

A habit represents repeated behavior tracked over time, usually in a weekly grid, where history, consistency and streaks matter more than one generated task instance.

The habit loop is:

> Create habit -> mark days in weekly journal -> review week -> review consistency / skipped / missed / streak in Reports

The task planning loop remains separate:

> Goal -> Milestone / Direct task -> Today / Calendar -> Complete -> Reports

## Architecture rule

Habits must not be added directly into `PlannerStore`.

Do not add these to `PlannerStore`:

- `_habits`;
- `_habitEntries`;
- `addHabit`;
- `updateHabit`;
- `deleteHabit`;
- `markHabitDone`;
- habit persistence logic;
- habit report calculation.

Habits have their own feature area and state boundary:

- `lib/features/habits/domain/`;
- `lib/features/habits/application/`;
- `lib/features/habits/presentation/`.

Main habit objects:

- `Habit`;
- `HabitEntry`;
- `HabitEntryStatus`;
- `HabitTrackingType`;
- `HabitStore`;
- `HabitApplicationService`;
- `HabitRepository`;
- `DriftHabitRepository`;
- `HabitWeekViewBuilder`;
- `HabitProgressCalculator`.

Reports use a separate habit reporting path:

- `HabitReportLoader`;
- `HabitReportSummary`;
- `HabitReportBuilder`;
- `HabitStreakCalculator`.

`PlannerStore` remains responsible for the goal/task planning loop only.

## Phase 7A: Habit tracking core

Implemented:

- Habit domain model.
- Habit entry domain model.
- Habit entry status model.
- Habit tracking type model.
- Count-ready domain support.
- Drift tables:
  - `habits`;
  - `habit_entries`.
- Local database schema version increased to 3.
- Habit mappers.
- Habit repository interface.
- Drift habit repository.
- Habit application service.
- Habit store.
- Basic Habits screen.
- Weekly journal-style habit layout.
- Create habit.
- Edit habit.
- Archive habit.
- Unarchive habit.
- Delete habit.
- Mark habit date as:
  - done;
  - failed;
  - skipped.
- Clear an existing mark.
- Navigate between weeks.
- Persist habit data locally.
- Cover core habit domain/application/store/repository behavior with tests.

## Phase 7B: Habit UX integration

Implemented:

- Promote Habits to a top-level bottom navigation tab.
- Initialize `HabitStore` at `AppShell` level, parallel to `PlannerStore`.
- Keep bottom navigation as:
  - Today;
  - Goals;
  - Calendar;
  - Habits;
  - More.
- Improve Today screen structure:
  - `TodaySummaryCard`;
  - `TodayHabitsSummaryCard`;
  - `TodayEmptyPanel`;
  - `TodayTaskSection`.
- Show lightweight habit summary on Today.
- Keep habit marking inside Habits screen for now.
- Do not turn Today into a full habit journal.

Current Today decision:

- Today may show whether habits need attention.
- Today does not mark habits directly.
- Full habit interaction stays in Habits.

## Phase 7C: Habit reports integration

Implemented:

- Add habit report loader.
- Add habit report summary builder.
- Add habit report domain summary.
- Connect habit report data to Reports screen.
- Show task summary separately from habit summary.
- Keep task metrics and habit metrics separate.
- Add habit consistency metric.
- Add skipped count.
- Add missed count.
- Add current habit streak.
- Replace misleading task current streak UI with active days.

Reports currently show:

Task summary:

- completed tasks;
- planned tasks;
- plan completion;
- active days.

Habit summary:

- consistency;
- habit streak;
- missed marks;
- skipped marks.

## Habit model

A habit is a tracked repeated behavior.

Fields:

- `id`;
- `title`;
- `description`;
- `trackingType`;
- `targetCount`;
- `sortOrder`;
- `isArchived`;
- `createdAt`;
- `updatedAt`.

## Tracking type

Supported domain tracking types:

- `binary`;
- `count`.

Current UI focuses on binary habits.

Count-based habits are intentionally supported in the domain/database shape so the model does not need to be rewritten later.

Examples:

- `Meditate`
  - `trackingType = binary`
  - `targetCount = null`

- `Drink water 8 times`
  - `trackingType = count`
  - `targetCount = 8`

- `Do 3 sets`
  - `trackingType = count`
  - `targetCount = 3`

## Habit entry / daily progress

A habit entry represents habit progress for a specific date.

Fields:

- `id`;
- `habitId`;
- `date`;
- `status`;
- `completedCount`;
- `createdAt`;
- `updatedAt`.

Current UI uses one effective entry per habit/date.

The model still leaves room for future count-based progress.

## Entry status

Supported statuses:

- `none`;
- `done`;
- `incomplete`;
- `failed`;
- `skipped`.

Meaning:

- `none`
  - No mark exists for the date.

- `done`
  - Habit target was completed.

- `incomplete`
  - Count-based habit was partially completed but did not reach target.

- `failed`
  - User explicitly marked the habit as not completed.

- `skipped`
  - User intentionally skipped the habit for a valid reason.

## Statistics rules

Current rules:

- `done` counts as completion.
- `failed` counts as failure.
- `incomplete` counts as failure.
- `skipped` is neutral.
- `skipped` is shown separately.
- `skipped` is excluded from consistency denominator.
- `skipped` does not break habit streak.
- Missed expected marks count against consistency.
- Consistency must not exceed 100%.

Consistency rule:

- denominator = expected marks - skipped marks;
- numerator = done marks;
- missed/failed/incomplete reduce consistency;
- skipped does not reduce consistency.

Habit streak rule:

- done extends streak;
- missed/failed/incomplete breaks streak;
- skipped is neutral;
- today without a mark is pending, not failed;
- days before habit creation are neutral;
- archived habits are not expected.

## Count-based habits

Count-based habits are designed but not exposed in full UI yet.

Future behavior:

- `targetCount` = required count per day;
- `completedCount` = current progress for that date.

Future status calculation:

- `completedCount >= targetCount`
  - status = `done`

- `completedCount > 0 && completedCount < targetCount`
  - status = `incomplete`

- `completedCount == 0`
  - status = `none`, unless user explicitly marks failed or skipped.

Do not collapse the model into a boolean-only schema.

## Today integration

Today shows a lightweight habit summary.

Current decision:

- Today should not become the full habit journal.
- Habit marking stays in Habits.
- Today should help the user notice habit state without mixing habits into task completion.

This preserves separation:

- tasks are executed in Today;
- habits are tracked in Habits;
- both can be reviewed in Reports.

## Reports integration

Reports show tasks and habits as separate sections.

Do not mix habit metrics into task metrics.

Do not use habits to extend task streaks.

Current task activity metric:

- active days.

Current habit metrics:

- consistency;
- habit streak;
- missed;
- skipped.

Future possible metric:

- separate activity streak across tasks + habits.

Do not add a combined streak until the product meaning is clear.

## Store boundary

`HabitStore` owns habit state.

Responsibilities:

- load habits and entries;
- expose active habits;
- expose archived habits when needed;
- expose entries for visible week;
- create/update/archive/unarchive/delete habits;
- mark habit entry;
- clear habit entry;
- navigate selected week;
- notify habit UI.

`HabitStore` must not know about:

- goals;
- tasks;
- milestones;
- recurring task rules;
- planner task reports.

## Repository boundary

`HabitRepository` hides Drift details.

Responsibilities:

- load habits;
- load entries for date ranges;
- save habit;
- save entry;
- delete/clear entry;
- archive habit;
- unarchive habit;
- delete habit.

## Journal decision

For now, "Journal" is not a separate domain entity.

It is treated as the Habits screen / weekly habit layout.

Do not create `HabitJournal` yet.

If real grouping is needed later, introduce it only after the first habit loop is validated.

## Reminders

Reminders are not part of Phase 7.

They should be a separate future feature, not a habit-only subsystem.

Future reminder model should support different targets:

- none;
- habit;
- task;
- diary.

Examples:

- `21:30 Add expenses`
  - target type = none

- `07:30 Weigh in`
  - target type = habit

- `10:00 Work on task`
  - target type = task

- `22:00 Fill diary`
  - target type = diary

Do not design reminders inside Habits.

## Daily diary

Daily diary is not part of Phase 7.

It should be a separate future feature.

Diary entry is not the same thing as a habit note.

Future diary model:

- `id`;
- `date`;
- `text`;
- `createdAt`;
- `updatedAt`.

Purpose:

- daily reflection;
- emotional summary;
- free writing;
- retrospective of the day.

Do not mix diary text into habit entries.

## Testing coverage

Phase 7 has tests for:

- habit entry status behavior;
- habit progress calculation;
- habit mappers;
- habit repository behavior;
- habit application service behavior;
- habit store behavior;
- habit today summary;
- habit week summary;
- habit week view builder;
- habit report builder;
- habit streak calculator.

## Definition of Done for Phase 7 MVP

Done:

- Habits are implemented outside `PlannerStore`.
- User can create a habit.
- User can edit a habit.
- User can archive/unarchive a habit.
- User can delete a habit.
- User can see habits in a weekly grid.
- User can mark a habit date as done/failed/skipped.
- User can clear an existing mark.
- User can navigate weeks.
- Habit data persists locally.
- Habits are available as a top-level tab.
- Today shows lightweight habit summary.
- Reports show habit summary separately from task summary.
- Reports show habit consistency.
- Reports show skipped/missed marks.
- Reports show habit streak.
- Existing planner task/goal flows still work.
- `flutter analyze` passes.
- `flutter test` passes.
- Manual run passes.

## Explicitly deferred

- habit reminders;
- task reminders;
- diary reminders;
- daily diary;
- habit notes;
- timed habits;
- optional weekdays;
- count-based habit UI;
- habit graphs;
- advanced habit statistics;
- custom habit report date ranges;
- multiple check-ins UI;
- habit grouping/journals;
- habit templates;
- habit categories;
- Riverpod migration;
- backend/sync.