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
- Calendar placeholder before Phase 5.

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

Status: done.

Goal:

Move from “Today-only planning” to basic scheduled-date planning.

Implemented:

- Add date picker for task scheduling.
- Keep quick action: Plan today.
- Add Schedule date action for tasks.
- Show scheduled date in TaskCard.
- Support scheduling tasks from:
  - All Tasks;
  - Goal Details;
  - Today;
  - Calendar.
- Support rescheduling tasks to another date.
- Support removing scheduled date while keeping task visible in All Tasks.
- Add Calendar screen.
- Add visual month grid.
- Highlight selected day.
- Highlight today.
- Mark days that have scheduled tasks.
- Show tasks for selected day.
- Allow task actions from Calendar:
  - complete / uncomplete;
  - edit;
  - reschedule;
  - remove scheduled date;
  - delete.
- Add task creation from Calendar for selected date.
- Support task placement when creating from Calendar:
  - standalone task;
  - direct goal task;
  - milestone task.
- Persist scheduled date after restart.

Refactoring completed during this phase:

- Extract shared planner date helpers.
- Extract calendar month grid widget.
- Show only selected day tasks in Calendar.
- Rename task creation placement dialog.
- Organize widgets by feature:
  - common;
  - calendar;
  - goals;
  - milestones;
  - tasks.

Current result:

A user can schedule tasks not only for today, but for future dates.

A user can manually test:

> create goal -> add milestone/direct task -> schedule task for future date -> open Calendar -> select date -> see task -> complete task -> see goal progress

Calendar is now useful as a basic planning surface, not a full calendar product.

Not implemented yet:

- time-of-day scheduling;
- recurring tasks;
- drag-and-drop planning;
- week/day calendar views;
- year calendar view;
- meetings / birthdays as separate event types;
- reminders / notifications.

## Phase 6: Reports and validation analytics MVP

Status: mostly done.

Goal:

Show useful progress feedback without overbuilding analytics.

The main question this phase should answer:

> Did daily actions actually move long-term goals, or did the app become a generic todo list?

Implemented:

### Today execution feedback

- Add Done today section to Today screen.
- Show tasks completed today based on `completedAt`.
- Keep pending today tasks separate from completed today tasks.
- Add Overdue section to Today screen.
- Show overdue tasks separately from today's planned tasks.
- Support removing scheduled date from overdue tasks.
- Support moving overdue tasks back to Today.
- Support date-aware completion flow:
  - today / unscheduled task -> complete today;
  - past scheduled task -> choose completion date;
  - future scheduled task -> confirm early completion;
  - completed task -> uncomplete without dialog.
- Apply date-aware completion flow across:
  - Today;
  - Calendar;
  - All Tasks;
  - Goal Details.

### Reports screen

- Add Reports screen accessible from More.
- Support quick report periods:
  - Today;
  - Last 7 days;
  - Last 14 days.
- Show completed tasks for selected period.
- Show summary card:
  - completed task count;
  - planned task count;
  - plan completion percent;
  - current completion streak.
- Show goal contribution:
  - completed tasks per goal;
  - standalone completed tasks.
- Show completed tasks grouped by day.
- Show completed count in each day section.
- Refresh Reports screen when store data changes.
- Support complete / uncomplete from Reports.

### Report logic and tests

- Extract report calculation from UI.
- Add report builder.
- Add report period model.
- Add report summary model.
- Add unit tests for:
  - Today period;
  - Last 7 days period;
  - Last 14 days period;
  - goal-linked vs standalone counts;
  - active days;
  - day grouping;
  - planned task count;
  - plan completion percent;
  - current streak.

### Refactoring completed during this phase

- Extract report widgets:
  - report period selector;
  - report summary card;
  - goal report section;
  - day report section;
  - empty report card.
- Fix completed task title decoration.
- Keep Reports screen focused on screen orchestration.

Current result:

A user can see:

- what is planned for today;
- what is overdue;
- what was completed today;
- what was completed over the last 7 / 14 days;
- how many planned tasks were actually completed;
- which goals received completed actions;
- how many days in a row they completed at least one task.

A user can manually test:

> create goal -> add milestone/direct task -> schedule tasks -> complete tasks across days -> open Reports -> switch Today / 7 days / 14 days -> see completed work, plan completion, streak, goal contribution and by-day history

Validation value:

This phase helps evaluate whether the app is used as a goal-linked planner or just as a simple todo list.

The most important validation signals are:

- user completes tasks linked to goals;
- user checks Reports;
- user understands plan completion;
- user notices overdue tasks and reschedules or completes them;
- user can review the last 7 / 14 days and see meaningful goal progress.

Not implemented yet:

- custom selected-day report;
- custom date ranges;
- weekly comparison;
- monthly / yearly analytics;
- charts;
- productivity score;
- AI-generated reviews;
- export;
- habit analytics.

## Phase 6.5: Recurring task planning MVP

Status: in progress.

Goal:

Make repeated tasks easy to plan without manually scheduling each date.

Problem:

Some tasks repeat on predictable patterns, for example:

- workout on Monday / Wednesday / Friday;
- take out trash every Friday;
- pay something every 15th;
- weigh in once a month;
- weekly planning every Sunday.

Current architecture decision:

Recurring tasks are implemented as:

> RecurringTaskRule -> generated PlannerTask occurrences

A recurring rule defines the repeated task.

Generated occurrences are normal `PlannerTask` items with:

- concrete `scheduledDate`;
- optional `goalId`;
- optional `milestoneId`;
- `recurringRuleId` linking them back to the rule.

This lets Today, Calendar and Reports work with recurring occurrences mostly like normal scheduled tasks.

Implemented:

### Domain model

- Add `RecurringTaskRule`.
- Add recurrence types:
  - weekly;
  - monthly.
- Support weekly weekdays:
  - Monday;
  - Tuesday;
  - Wednesday;
  - Thursday;
  - Friday;
  - Saturday;
  - Sunday.
- Support monthly day selection.
- Support monthly day fallback:
  - if the selected day does not exist in a month, occurrence is created on the last day of that month.
  - example: day 31 -> February 28/29, April 30.
- Add `RecurringTaskException`.
- Add `recurringRuleId` to `PlannerTask`.

### Tests

- Add tests for weekly rule matching.
- Add tests for monthly rule matching.
- Add tests for inactive rules.
- Add tests for start/end date boundaries.
- Add tests for monthly last-day fallback.
- Add tests for recurring exceptions.
- Add tests for recurring occurrence generation.
- Add tests preventing duplicate generated occurrences.

### Persistence

- Upgrade Drift schema to version 2.
- Add `recurring_task_rules` table.
- Add `recurring_task_exceptions` table.
- Add nullable `recurringRuleId` column to `tasks`.
- Add migration from schema v1 to v2.
- Add repository mapping for recurring rules.
- Add repository mapping for recurring exceptions.
- Persist generated recurring task occurrences as normal tasks.

### Recurring occurrence generation

- Add recurring task occurrence generator.
- Generate concrete `PlannerTask` occurrences from active rules.
- Respect recurring exceptions.
- Avoid duplicate occurrences.
- Use deterministic generated task IDs.
- Generate upcoming occurrences on app start.
- Refactor generator to support arbitrary date ranges:
  - `startDate`;
  - `endDate`.
- Keep upcoming generation for near-term Today usage.
- Generate recurring occurrences for visible Calendar month.

### Store integration

- Load recurring rules into `PlannerStore`.
- Load recurring exceptions into `PlannerStore`.
- Add recurring rule creation to `PlannerStore`.
- Generate and persist upcoming occurrences when a rule is created.
- Generate and persist missing occurrences when Calendar opens a visible month.

### UI

- Add `Recurring tasks` screen.
- Add entry point from More.
- Add recurring rule list.
- Add reusable recurring rule card.
- Add recurring rule creation dialog from Recurring Tasks screen.
- Support recurring rule placement:
  - standalone recurring task;
  - direct goal recurring task;
  - milestone recurring task.
- Support weekly rule creation.
- Support monthly rule creation.
- Disable Add button until recurring rule form is valid.
- Allow monthly day 1-31.
- Show helper text explaining monthly last-day fallback.
- Show recurring rules in All Tasks instead of flooding All Tasks with future generated occurrences.
- Hide future uncompleted recurring occurrences from default All Tasks view.
- Keep today / overdue / completed recurring occurrences visible in All Tasks.

Current result:

A user can create a recurring task rule from More -> Recurring tasks.

Examples:

> Workout every Monday, Wednesday and Friday

> Pay taxes monthly on day 31

The app generates concrete scheduled task occurrences.

Generated occurrences appear in:

- Today, if occurrence is scheduled for today;
- Calendar, when the relevant month is opened;
- Reports, as planned/completed tasks;
- All Tasks only when actionable/history-relevant.

All Tasks now shows recurring rules separately, instead of being flooded with future generated occurrences.

Still to do:

### Recurring occurrence deletion

- When deleting a generated recurring occurrence, create a `RecurringTaskException`.
- Delete only the selected occurrence.
- Ensure the occurrence does not reappear after:
  - Calendar month regeneration;
  - app restart;
  - rule sync.

### Recurring rule deletion / deactivation

- Add ability to deactivate a recurring rule.
- Decide deletion behavior:
  - deactivate rule;
  - delete future uncompleted occurrences;
  - keep completed history.
- Add UI action from Recurring Tasks screen.

### Creation entry points

- Add recurring task creation from Today.
- Add recurring task creation from Calendar.
- For Calendar creation:
  - preselect weekday based on selected date for weekly recurrence.
  - optionally preselect month day for monthly recurrence.

### Rule editing

- Add edit recurring rule flow.
- Sync future occurrences when rule changes.
- Example:
  - old: Monday / Wednesday / Friday
  - new: Tuesday / Wednesday / Friday
  - delete future uncompleted Monday occurrences;
  - generate future Tuesday occurrences;
  - keep completed history.

### Occurrence behavior polish

- Decide how rescheduling a generated occurrence should behave.
- For MVP:
  - editing/rescheduling an occurrence should affect only that occurrence.
  - editing the rule should affect future generated occurrences.

Expected result for Phase 6.5 done:

A user can:

- create weekly recurring tasks;
- create monthly recurring tasks;
- link recurring tasks to goals/milestones;
- see generated occurrences in Today and Calendar;
- complete one occurrence without completing the whole series;
- delete one occurrence without it being regenerated;
- deactivate a recurring rule;
- avoid All Tasks being flooded with future generated occurrences.

Not doing initially:

- complex RRULE support;
- yearly recurrence;
- every N days recurrence;
- time-of-day scheduling;
- reminders;
- drag-and-drop recurring occurrences;
- edit this and following;
- advanced recurrence exceptions;
- habit streaks;
- full habit system.

## Phase 7: Habits MVP

Status: not started.

Goal:

Add recurring daily behavior tracking only after reports and recurring task planning are stable.

Why this is separate from recurring tasks:

Recurring tasks are planned actions that appear as tasks on specific dates.

Habits are routines tracked over time, where the history and consistency matter more than a single task instance.

Initial habit scope:

- Create habit.
- Edit habit.
- Delete habit.
- Habit title.
- Optional description.
- Daily checkbox.
- Optional weekdays.
- Optional time.
- Show timed habits in Today.
- Show untimed habits in a simple habit list.
- Mark habit complete for a day.
- Store habit completion history.
- Show simple habit completion history.

Expected result:

A user can track routines like:

- 10,000 steps;
- meditation;
- drink water;
- reading;
- stretching.

Not doing initially:

- complex streak gamification;
- habit analytics;
- habit templates;
- habit categories;
- penalties;
- social features;
- reminders;
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
- User reviews the last 7 / 14 days.
- User understands planned vs completed tasks.
- User uses overdue tasks instead of losing old planned tasks.
- User can see which goals received real completed actions.
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

- No time-of-day scheduling yet.
- No recurring task planning yet.
- No habits.
- No habit completion history.
- Reports support only Today / Last 7 days / Last 14 days.
- No custom selected-day report yet.
- No custom report date ranges.
- No weekly comparison.
- No monthly / yearly analytics.
- No search/filtering in All Tasks.
- No drag-and-drop planning.
- No week/day/year calendar views.
- No separate meeting / birthday event model.
- No reminders / notifications.
- No cloud sync/backend.
- No auth.
- No serious design polish yet.
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
