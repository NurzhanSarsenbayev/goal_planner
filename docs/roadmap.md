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

Status: done.

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
  - if the selected day does not exist in a month, occurrence is created on the last day of that month;
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
- Add tests for recurring occurrence lifecycle:
  - delete occurrence;
  - reschedule occurrence;
  - unschedule occurrence.
- Add tests for recurring rule lifecycle:
  - activate rule;
  - deactivate rule;
  - delete rule;
  - update rule and rebuild future occurrences.

### Persistence

- Upgrade Drift schema to version 2.
- Add `recurring_task_rules` table.
- Add `recurring_task_exceptions` table.
- Add nullable `recurringRuleId` column to `tasks`.
- Add migration from schema v1 to v2.
- Add repository mapping for recurring rules.
- Add repository mapping for recurring exceptions.
- Persist generated recurring task occurrences as normal tasks.
- Persist recurring rule creation transactionally:
  - save rule;
  - save generated occurrences.
- Clean recurring data when deleting goals and milestones:
  - deleting a goal removes related recurring rules and exceptions;
  - deleting a milestone with tasks removes related recurring rules and exceptions;
  - deleting a milestone while moving tasks to direct goal detaches related recurring rules from the milestone.

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
- Refresh visible Calendar month after creating a recurring rule from Calendar.

### Store and lifecycle integration

- Load recurring rules into `PlannerStore`.
- Load recurring exceptions into `PlannerStore`.
- Add recurring rule creation to `PlannerStore`.
- Generate and persist upcoming occurrences when a rule is created.
- Generate and persist missing occurrences when Calendar opens a visible month.
- Extract recurring occurrence lifecycle:
  - delete occurrence;
  - reschedule occurrence;
  - unschedule occurrence.
- Extract recurring rule lifecycle:
  - activate rule;
  - deactivate rule;
  - delete rule;
  - update rule and rebuild future occurrences.
- Keep `PlannerStore` as state coordinator while recurring lifecycle decisions move into dedicated recurring lifecycle classes.

### UI

- Add `Recurring tasks` screen.
- Add entry point from More.
- Add recurring rule list.
- Add reusable recurring rule card.
- Add recurring rule creation dialog from Recurring Tasks screen.
- Add recurring rule editing flow.
- Add recurring rule activate/deactivate actions.
- Add recurring rule delete action.
- Support recurring rule placement:
  - standalone recurring task;
  - direct goal recurring task;
  - milestone recurring task.
- Support weekly rule creation.
- Support monthly rule creation.
- Disable Add button until recurring rule form is valid.
- Allow monthly day 1-31.
- Show helper text explaining monthly last-day fallback.
- Split recurring rule dialog into smaller sections:
  - placement section;
  - schedule section.
- Show recurring rules in All Tasks instead of flooding All Tasks with future generated occurrences.
- Hide future uncompleted recurring occurrences from default All Tasks view.
- Keep today / overdue / completed recurring occurrences visible in All Tasks.
- Add recurring task creation from Today.
- Add recurring task creation from Calendar.
- For Calendar recurring creation:
  - use selected date as recurring rule start date;
  - preselect weekday based on selected date;
  - preselect monthly day based on selected date;
  - show past-date warning when creating from a past date.

### Occurrence behavior

- Deleting one generated recurring occurrence:
  - creates a `RecurringTaskException`;
  - deletes only the selected occurrence;
  - prevents that occurrence from being regenerated after Calendar month regeneration or app restart.
- Rescheduling one generated recurring occurrence:
  - creates a `RecurringTaskException` for the old date;
  - detaches the moved task from the recurring rule;
  - keeps the moved task as a one-off scheduled task.
- Unscheduling one generated recurring occurrence:
  - creates a `RecurringTaskException` for the old date;
  - detaches the task from the recurring rule;
  - keeps the task as a one-off unscheduled task.
- Completing one occurrence affects only that occurrence.
- Editing a recurring rule:
  - updates the rule;
  - removes future unfinished generated occurrences from the old rule shape;
  - generates future occurrences from the updated rule;
  - keeps completed history.
- Deactivating a recurring rule:
  - marks the rule inactive;
  - removes unfinished generated occurrences;
  - keeps completed history.
- Activating a recurring rule:
  - marks the rule active;
  - regenerates upcoming occurrences;
  - still respects existing exceptions.
- Deleting a recurring rule:
  - deletes the rule;
  - removes unfinished generated occurrences;
  - keeps completed occurrences as detached history;
  - removes exceptions for the deleted rule.

Current result:

A user can create, edit, deactivate, activate, and delete recurring task rules.

Examples:

> Workout every Monday, Wednesday and Friday

> Pay taxes monthly on day 31

The app generates concrete scheduled task occurrences.

Generated occurrences appear in:

- Today, if occurrence is scheduled for today;
- Calendar, when the relevant month is opened;
- Reports, as planned/completed tasks;
- All Tasks only when actionable/history-relevant.

All Tasks shows recurring rules separately, instead of being flooded with future generated occurrences.

Expected result for Phase 6.5 done:

A user can:

- create weekly recurring tasks;
- create monthly recurring tasks;
- link recurring tasks to goals/milestones;
- create recurring tasks from More;
- create recurring tasks from Today;
- create recurring tasks from Calendar;
- see generated occurrences in Today and Calendar;
- complete one occurrence without completing the whole series;
- delete one occurrence without it being regenerated;
- reschedule one occurrence without changing the whole series;
- unschedule one occurrence without it being regenerated;
- edit a recurring rule and rebuild future unfinished occurrences;
- deactivate and reactivate a recurring rule;
- delete a recurring rule while keeping completed history;
- avoid All Tasks being flooded with future generated occurrences.

Not doing in recurring MVP:

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

## Phase 6.6: Architecture stabilization before Habits

Status: done.

Goal:

Prepare the codebase for larger feature growth before adding Habits.

The app had enough real product behavior that continuing with the previous MVP structure would have made future changes harder, riskier and slower.

This phase focused on reducing `PlannerStore` responsibilities, clarifying feature boundaries, and making the codebase safer to extend without a big-bang rewrite.

Reason:

Phase 6.5 added serious recurring task behavior:

- recurring rules;
- generated task occurrences;
- occurrence exceptions;
- rule editing;
- rule activation/deactivation;
- rule deletion;
- recurring creation from Today;
- recurring creation from Calendar;
- Calendar month generation;
- All Tasks filtering;
- Reports compatibility.

The feature worked, but it exposed architectural pressure.

Main architectural risks addressed:

- `PlannerStore` coordinated too many domains:
  - goals;
  - milestones;
  - tasks;
  - recurring rules;
  - recurring occurrence generation;
  - persistence orchestration.
- Persistence responsibilities were too broad.
- `AppShell` owned too many dialog flows and screen callbacks.
- Presentation files were becoming harder to extend safely.
- Adding Habits directly into the same store would have made the architecture worse.

Implemented:

### Store and application orchestration

- Extracted `TaskApplicationService`.
- Extracted `GoalApplicationService`.
- Extracted `MilestoneApplicationService`.
- Extracted `RecurringTaskApplicationService`.
- Extracted `PlannerInitializationService`.
- Extracted `PlannerPersistenceRunner`.
- Extracted `GoalStoreCoordinator`.
- Extracted `MilestoneStoreCoordinator`.
- Extracted `TaskStoreCoordinator`.
- Extracted `RecurringRuleStoreCoordinator`.
- Extracted `RecurringOccurrenceStoreCoordinator`.
- Moved recurring month occurrence generation into the occurrence coordinator.
- Removed direct repository/application-service orchestration from `PlannerStore`.

Current `PlannerStore` role:

- holds the main planning state;
- exposes read-only getters;
- acts as UI-facing facade for the existing planning loop;
- delegates goal/milestone/task/recurring operations to feature coordinators;
- applies returned state mutations;
- calls `notifyListeners`;
- runs persistence operations through `PlannerPersistenceRunner`.

Important result:

`PlannerStore` was reduced from a god object into a central state facade.

It is still intentionally kept as the central store for the existing goal/task planning loop, but it no longer owns most business orchestration or persistence details.

Further decomposition into multiple feature stores is deferred.

### Repository cleanup

- Split persistence responsibilities from the old broad planner repository.
- Extracted:
  - `DriftGoalRepository`;
  - `DriftMilestoneRepository`;
  - `DriftTaskRepository`;
  - `DriftRecurringTaskRepository`;
  - `DriftPlannerCleanupRepository`.
- Replaced broad planner cleanup usage with a dedicated cleanup boundary.
- Kept cross-aggregate cleanup operations explicit and named.

### Recurring architecture

- Moved recurring domain logic into `features/recurring/domain`.
- Kept recurring application orchestration in `features/recurring/application`.
- Kept recurring presentation in `features/recurring/presentation`.
- Extracted recurring lifecycle logic away from `PlannerStore`.
- Kept recurring occurrence generation outside the store.
- Kept recurring behavior covered by unit tests.

### Reports architecture

- Moved report calculation into `features/reports/application`.
- Moved report domain models into `features/reports/domain`.
- Moved Reports presentation into `features/reports/presentation`.
- Kept Reports screen focused on presentation orchestration.

### Presentation and app shell cleanup

- Extracted `GoalDialogActions`.
- Extracted `TaskDialogActions`.
- Extracted recurring task dialog helpers.
- Extracted goal/task/recurring/task-date dialog helpers from app layer.
- Deleted old `app_dialogs.dart`.
- Extracted `AppNavigationActions`.
- Extracted `MainTabBuilder`.
- Moved `MoreScreen` into `app/navigation/screens`.
- Moved Today presentation into `features/today/presentation`.
- Moved Calendar presentation into `features/calendar/presentation`.
- Moved Goals presentation into `features/goals/presentation`.
- Moved Goal Details presentation into feature folders.
- Moved All Tasks presentation into `features/tasks/presentation`.
- Moved Recurring Tasks presentation into `features/recurring/presentation`.
- Moved shared reusable widgets into `shared/presentation/widgets`.

### View builders and screen simplification

- Extracted `TodayTaskViewBuilder`.
- Extracted `CalendarTaskViewBuilder`.
- Extracted `GoalDetailsViewBuilder`.
- Extracted `AllTasksViewBuilder`.
- Removed shadow-state from `AllTasksController`.
- Removed shadow-state from `GoalDetailsController`.
- Kept screens closer to rendering state and emitting user intents.

### Composition cleanup

- Extracted `AppDependencies` as the app composition root.
- Moved store dependency composition out of `PlannerStore`.
- Kept concrete repository wiring in `AppDependencies`.
- Cleaned `AppDependencies` public API so external code only needs:
  - `store`;
  - `dispose()`.

### Old structure cleanup

- Removed old `lib/screens`.
- Removed old root widget files from `lib/widgets`.
- Removed old app action/dialog leftovers.

Current result:

The app architecture is now safer for the next feature phase.

The main planning loop still uses one central `PlannerStore`, but feature operations are routed through dedicated coordinators:

- `GoalStoreCoordinator`;
- `MilestoneStoreCoordinator`;
- `TaskStoreCoordinator`;
- `RecurringRuleStoreCoordinator`;
- `RecurringOccurrenceStoreCoordinator`.

This makes the current MVP easier to reason about and reduces the risk of adding new behavior directly into one giant store.

Manual architecture rule after this phase:

> New major features must not be added directly into `PlannerStore`.

Especially for Habits:

> Habits should use their own feature folder, application layer, repository and store/coordinator instead of becoming another section inside `PlannerStore`.

Definition of done:

- `PlannerStore` is significantly thinner and mostly acts as a state facade.
- Goal lifecycle orchestration is outside `PlannerStore`.
- Milestone lifecycle orchestration is outside `PlannerStore`.
- Task lifecycle orchestration is outside `PlannerStore`.
- Recurring rule and occurrence orchestration are outside `PlannerStore`.
- Direct repository dependencies are removed from `PlannerStore`.
- Direct application service dependencies are removed from `PlannerStore`.
- `AppShell` no longer owns most dialog workflows.
- Feature presentation folders are clearer.
- Existing recurring behavior still works after refactor.
- `flutter analyze` passes.
- `flutter test` passes.
- Manual run passes.

Known remaining technical debt:

- `PlannerStore` is still a central app facade for the current planning loop.
- `TaskStoreCoordinator` is large because task behavior is the most complex part of the app.
- Store coordinators should get focused unit tests before large future changes.
- Further state-management cleanup may be useful later.
- Riverpod migration is deferred until there is a clear need and better feature-store boundaries.

Not doing in this phase:

- Full rewrite to strict Clean Architecture.
- Riverpod migration.
- Dependency injection framework.
- Moving every model into feature folders in one big change.
- Splitting `PlannerStore` into multiple stores immediately.
- Backend/sync.
- New product features.


## Phase 7: Habits MVP

Status: Phase 7A done.

Goal:

Add recurring behavior tracking as a separate product loop without turning habits into recurring tasks and without adding habit state to `PlannerStore`.

Why this is separate from recurring tasks:

Recurring tasks are planned actions that appear as concrete tasks on specific dates.

Habits are routines tracked over time, where history and consistency matter more than a single task instance.

Implemented in Phase 7A:

- Add habit domain model.
- Add habit entry domain model.
- Add habit entry statuses:
  - none;
  - done;
  - incomplete;
  - failed;
  - skipped.
- Add habit tracking type model:
  - binary;
  - count-ready domain support.
- Add `HabitProgressCalculator`.
- Add Drift tables:
  - `habits`;
  - `habit_entries`.
- Increase local database schema version to 3.
- Add habit mappers.
- Add `HabitRepository`.
- Add `DriftHabitRepository`.
- Add `HabitApplicationService`.
- Add `HabitWeekViewBuilder`.
- Add `HabitStore`.
- Keep habits outside `PlannerStore`.
- Wire `HabitStore` through `AppDependencies`.
- Open Habits from More screen.
- Add Habits screen.
- Add habit creation UI.
- Add weekly journal-style habit layout.
- Add week navigation:
  - previous week;
  - next week;
  - current week.
- Add habit status picker:
  - Done;
  - No / Failed;
  - Skip;
  - Clear.
- Add edit habit action.
- Add archive habit action.
- Add delete habit action.
- Persist habit data locally.
- Cover core habit domain/application/store/repository behavior with tests.

Current result:

A user can track routines like:

- meditation;
- drink water;
- reading;
- stretching;
- walking;
- workouts.

The main habit loop is now:

> Create habit -> mark days in weekly journal -> review current week -> adjust previous days -> persist locally

Architecture result:

Habits are implemented as a separate feature boundary:

```text
lib/features/habits/
  domain/
  application/
  presentation/
```

Habits use their own store and repository:

```text
HabitStore
HabitApplicationService
HabitRepository
DriftHabitRepository
```

`PlannerStore` remains responsible for the goal/task planning loop only.

Not implemented in Phase 7A:

- reminders;
- habit notes;
- timed habits;
- optional weekdays;
- habit display in Today;
- count-based habit UI;
- advanced statistics;
- streak analytics;
- habit templates;
- habit categories;
- habit groups/journals;
- backend/sync.

Possible Phase 7B:

- add lightweight weekly summary;
- add empty-state guidance for first habit;
- improve habit status picker visuals;
- add unarchive flow;
- add basic habit notes;
- decide whether timed habits belong in Today.

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
- User understands the difference between standalone, direct goal and milestone tasks.
- User understands recurring tasks and uses them for repeated planned actions.

Failure signals:

- User only uses it as a simple todo list.
- Goals are ignored.
- Milestones are ignored.
- Reports are ignored.
- Recurring tasks are ignored or misunderstood.
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
- support repeated planned actions without turning the app into a full habit/productivity suite too early;
- avoid turning the app into a bloated “whole life” tracker too early.

## Current limitations

- No time-of-day scheduling yet.
- Recurring task planning MVP exists, but advanced recurrence rules are not supported yet.
- Habits Phase 7A exists, but there are no reminders, notes, timed habits or advanced habit analytics yet.
- Architecture stabilization before Habits is completed, but further feature-store decomposition remains a later improvement.
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