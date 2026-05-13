import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/backup/application/planner_backup_file_storage.dart';
import 'package:goal_planner/features/backup/domain/planner_backup.dart';

void main() {
  group('PlannerBackupFileStorage', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'planner_backup_file_storage_test_',
      );
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('saves backup as formatted json file', () async {
      final exportedAt = DateTime.utc(2026, 5, 13, 10, 30);
      final storage = PlannerBackupFileStorage(
        backupDirectoryProvider: () async => tempDirectory,
      );
      final backup = PlannerBackup.create(
        exportedAt: exportedAt,
        data: const PlannerBackupData.empty(),
      );

      final file = await storage.saveBackup(backup);

      expect(await file.exists(), isTrue);
      expect(file.path.endsWith('.json'), isTrue);
      expect(
        file.uri.pathSegments.last,
        'planner_backup_2026-05-13T10-30-00-000Z.json',
      );

      final content = await file.readAsString();

      expect(content, contains('"schemaVersion": 1'));
      expect(content, contains('"exportedAt": "2026-05-13T10:30:00.000Z"'));
      expect(content, contains('"goals": []'));
    });

    test('reads saved backup file', () async {
      final exportedAt = DateTime.utc(2026, 5, 13, 10, 30);
      final storage = PlannerBackupFileStorage(
        backupDirectoryProvider: () async => tempDirectory,
      );
      final backup = PlannerBackup.create(
        exportedAt: exportedAt,
        data: const PlannerBackupData.empty(),
      );

      final file = await storage.saveBackup(backup);
      final restored = await storage.readBackup(file);

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

    test('rejects invalid backup file content', () async {
      final storage = PlannerBackupFileStorage(
        backupDirectoryProvider: () async => tempDirectory,
      );
      final file = File('${tempDirectory.path}/invalid.json');

      await file.writeAsString('[]');

      expect(() => storage.readBackup(file), throwsFormatException);
    });
  });
}
