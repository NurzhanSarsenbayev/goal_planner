import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/backup/application/planner_backup_file_storage.dart';
import 'package:goal_planner/features/backup/application/planner_backup_restore_repository.dart';
import 'package:goal_planner/features/backup/application/planner_backup_restore_service.dart';
import 'package:goal_planner/features/backup/application/planner_backup_validator.dart';
import 'package:goal_planner/features/backup/domain/planner_backup.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';
import 'package:goal_planner/models/goal.dart';
import 'package:goal_planner/models/milestone.dart';

void main() {
  group('PlannerBackupRestoreService', () {
    late Directory tempDirectory;
    late PlannerBackupFileStorage fileStorage;
    late _FakePlannerBackupRestoreRepository restoreRepository;
    late PlannerBackupRestoreService service;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'planner_backup_restore_service_test_',
      );
      fileStorage = PlannerBackupFileStorage(
        backupDirectoryProvider: () async => tempDirectory,
      );
      restoreRepository = _FakePlannerBackupRestoreRepository();
      service = PlannerBackupRestoreService(
        fileStorage: fileStorage,
        validator: const PlannerBackupValidator(),
        restoreRepository: restoreRepository,
      );
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('reads validates and restores backup file', () async {
      final exportedAt = DateTime.utc(2026, 5, 13, 10, 30);
      final backup = PlannerBackup.create(
        exportedAt: exportedAt,
        data: _validBackupData(),
      );
      final file = await fileStorage.saveBackup(backup);

      final result = await service.restoreFromFile(file);

      expect(result.schemaVersion, PlannerBackup.currentSchemaVersion);
      expect(result.exportedAt, exportedAt);
      expect(result.restoredAt, isA<DateTime>());
      expect(restoreRepository.replaceAllCallCount, 1);
      expect(restoreRepository.lastData?.goals.single.id, 'goal-1');
      expect(restoreRepository.lastData?.habits.single.id, 'habit-1');
    });

    test('does not restore invalid backup data', () async {
      final backup = PlannerBackup.create(
        exportedAt: DateTime.utc(2026, 5, 13, 10, 30),
        data: PlannerBackupData(
          goals: const [],
          milestones: [
            Milestone(
              id: 'milestone-1',
              goalId: 'missing-goal',
              title: 'Broken milestone',
              description: '',
              createdAt: DateTime.utc(2026, 5, 13),
            ),
          ],
          tasks: const [],
          recurringRules: const [],
          recurringExceptions: const [],
          habits: const [],
          habitEntries: const [],
        ),
      );
      final file = await fileStorage.saveBackup(backup);

      await expectLater(
        service.restoreFromFile(file),
        throwsA(isA<PlannerBackupValidationException>()),
      );

      expect(restoreRepository.replaceAllCallCount, 0);
      expect(restoreRepository.lastData, isNull);
    });

    test('does not restore unreadable backup file', () async {
      final file = File('${tempDirectory.path}/invalid.json');
      await file.writeAsString('[]');

      await expectLater(service.restoreFromFile(file), throwsFormatException);

      expect(restoreRepository.replaceAllCallCount, 0);
      expect(restoreRepository.lastData, isNull);
    });
  });
}

PlannerBackupData _validBackupData() {
  final now = DateTime.utc(2026, 5, 13);
  final entryDate = DateTime.utc(2026, 5, 14);

  return PlannerBackupData(
    goals: [
      Goal(
        id: 'goal-1',
        title: 'Goal',
        description: '',
        status: GoalStatus.active,
        createdAt: now,
      ),
    ],
    milestones: const [],
    tasks: const [],
    recurringRules: const [],
    recurringExceptions: const [],
    habits: [
      Habit(
        id: 'habit-1',
        title: 'Habit',
        description: '',
        trackingType: HabitTrackingType.count,
        targetCount: 3,
        sortOrder: 0,
        isArchived: false,
        createdAt: now,
        updatedAt: now,
      ),
    ],
    habitEntries: [
      HabitEntry(
        id: 'habit-entry-1',
        habitId: 'habit-1',
        date: entryDate,
        status: HabitEntryStatus.done,
        completedCount: 3,
        note: null,
        createdAt: now,
        updatedAt: now,
      ),
    ],
  );
}

class _FakePlannerBackupRestoreRepository
    implements PlannerBackupRestoreRepository {
  int replaceAllCallCount = 0;
  PlannerBackupData? lastData;

  @override
  Future<void> replaceAll(PlannerBackupData data) async {
    replaceAllCallCount += 1;
    lastData = data;
  }
}
