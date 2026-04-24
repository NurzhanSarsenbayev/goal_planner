# MVP Requirements

## MVP goal

Build a local-first mobile prototype that proves the main product loop:

> A user creates a goal, breaks it into tasks, schedules a task for today, completes it, and sees progress.

## Milestone 1: App shell

Status: done.

Requirements:

- Bottom navigation exists.
- Tabs:
    - Today
    - Goals
    - Calendar
    - More
- Switching tabs works.
- App runs on Android emulator.

## Milestone 2: In-memory goals and tasks

No database yet.

### Goal model

Fields:

- id
- title
- description
- status
- createdAt

### Task model

Fields:

- id
- goalId nullable
- title
- description
- scheduledDate nullable
- isCompleted
- createdAt
- completedAt nullable

### Goals screen

Requirements:

- Show list of goals.
- Show empty state if there are no goals.
- Add new goal.
- Open goal details.

### Goal details screen

Requirements:

- Show goal title.
- Show tasks linked to this goal.
- Add task to goal.
- Mark task as scheduled for today.
- Mark task as completed.
- Show simple progress:
    - completed tasks / total tasks

### Today screen

Requirements:

- Show tasks scheduled for today.
- Show empty state if there are no tasks for today.
- Mark task as completed.
- Show whether task is linked to a goal.

## Milestone 3: Local persistence

Add local database after the in-memory prototype works.

Likely choice:

- Drift

Requirements:

- Persist goals.
- Persist tasks.
- Persist task completion state.
- App data survives restart.

## Milestone 4: MVP expansion

Add only after core loop works.

Potential features:

- Basic habits
- Simple daily report
- Basic calendar view
- Simple recurring tasks
- Basic checklists

## Non-goals

The MVP must not include:

- backend;
- auth;
- AI;
- sync;
- payments;
- public release;
- advanced analytics;
- complex gamification;
- graph/node editor.