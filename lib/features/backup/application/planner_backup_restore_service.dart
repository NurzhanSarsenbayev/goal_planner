import 'dart:io';


import 'planner_backup_file_storage.dart';
import 'planner_backup_restore_repository.dart';
import 'planner_backup_validator.dart';

class PlannerBackupRestoreService {
  const PlannerBackupRestoreService({
    required PlannerBackupFileStorage fileStorage,
    required PlannerBackupValidator validator,
    required PlannerBackupRestoreRepository restoreRepository,
  }) : _fileStorage = fileStorage,
       _validator = validator,
       _restoreRepository = restoreRepository;

  final PlannerBackupFileStorage _fileStorage;
  final PlannerBackupValidator _validator;
  final PlannerBackupRestoreRepository _restoreRepository;

  Future<PlannerBackupRestoreResult> restoreFromFile(File file) async {
    final backup = await _fileStorage.readBackup(file);

    _validator.validate(backup).throwIfInvalid();

    await _restoreRepository.replaceAll(backup.data);

    return PlannerBackupRestoreResult(
      schemaVersion: backup.schemaVersion,
      exportedAt: backup.exportedAt,
      restoredAt: DateTime.now(),
    );
  }
}

class PlannerBackupRestoreResult {
  const PlannerBackupRestoreResult({
    required this.schemaVersion,
    required this.exportedAt,
    required this.restoredAt,
  });

  final int schemaVersion;
  final DateTime exportedAt;
  final DateTime restoredAt;
}
