# Local Database Plan

## Goal

Replace in-memory state with local persistent storage.

The app must keep user data after restart:

- goals;
- milestones;
- tasks;
- completion state;
- scheduled date.

## Tables

### goals

- id: text primary key
- title: text
- description: text
- status: text
- created_at: datetime

### milestones

- id: text primary key
- goal_id: text
- title: text
- description: text
- created_at: datetime

### tasks

- id: text primary key
- goal_id: text nullable
- milestone_id: text nullable
- title: text
- description: text
- scheduled_date: datetime nullable
- is_completed: boolean
- completed_at: datetime nullable
- created_at: datetime

## Task types

### Standalone task

- goal_id = null
- milestone_id = null

### Direct goal task

- goal_id != null
- milestone_id = null

### Milestone task

- goal_id != null
- milestone_id != null

## First persistence milestone

Do not rewrite the whole app at once.

First goal:

- add Drift dependencies;
- create database class;
- define tables;
- generate database code;
- keep current UI working.

## Later

- create repositories;
- load initial data from DB;
- replace PlannerStore lists with database-backed state;
- remove sample data from runtime flow.