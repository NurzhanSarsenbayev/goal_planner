import 'dart:io';

import 'planner_backup_export_service.dart';
import 'planner_backup_file_storage.dart';

class PlannerBackupFileExportService {
  const PlannerBackupFileExportService({
    required PlannerBackupExportService exportService,
    required PlannerBackupFileStorage fileStorage,
  }) : _exportService = exportService,
       _fileStorage = fileStorage;

  final PlannerBackupExportService _exportService;
  final PlannerBackupFileStorage _fileStorage;

  Future<File> createBackupFile() async {
    final backup = await _exportService.createBackup();

    return _fileStorage.saveBackup(backup);
  }
}
