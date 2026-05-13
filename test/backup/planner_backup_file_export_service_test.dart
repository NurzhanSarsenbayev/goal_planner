import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/backup/application/planner_backup_export_service.dart';
import 'package:goal_planner/features/backup/application/planner_backup_file_export_service.dart';
import 'package:goal_planner/features/backup/application/planner_backup_file_storage.dart';
import 'package:goal_planner/features/backup/domain/planner_backup.dart';

void main() {
  group('PlannerBackupFileExportService', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'planner_backup_file_export_service_test_',
      );
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('creates backup file from exported planner backup', () async {
      final exportedAt = DateTime.utc(2026, 5, 13, 10, 30);
      final backup = PlannerBackup.create(
        exportedAt: exportedAt,
        data: const PlannerBackupData.empty(),
      );
      final exportService = _FakePlannerBackupExportService(backup);
      final fileStorage = PlannerBackupFileStorage(
        backupDirectoryProvider: () async => tempDirectory,
      );
      final service = PlannerBackupFileExportService(
        exportService: exportService,
        fileStorage: fileStorage,
      );

      final file = await service.createBackupFile();

      expect(exportService.createBackupCallCount, 1);
      expect(await file.exists(), isTrue);
      expect(
        file.uri.pathSegments.last,
        'planner_backup_2026-05-13T10-30-00-000Z.json',
      );

      final restored = await fileStorage.readBackup(file);

      expect(restored.schemaVersion, PlannerBackup.currentSchemaVersion);
      expect(restored.exportedAt, exportedAt);
      expect(restored.data.goals, isEmpty);
      expect(restored.data.milestones, isEmpty);
      expect(restored.data.tasks, isEmpty);
      expect(restored.data.recurringRules, isEmpty);
      expect(restored.data.recurringExceptions, isEmpty);
      expect(restored.data.habits, isEmpty);
      expect(restored.data.habitEntries, isEmpty);
    });
  });
}

class _FakePlannerBackupExportService implements PlannerBackupExportService {
  _FakePlannerBackupExportService(this.backup);

  final PlannerBackup backup;

  int createBackupCallCount = 0;

  @override
  Future<PlannerBackup> createBackup() async {
    createBackupCallCount += 1;

    return backup;
  }
}
