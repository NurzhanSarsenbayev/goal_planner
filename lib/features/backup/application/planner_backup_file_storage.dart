import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../domain/planner_backup.dart';

class PlannerBackupFileStorage {
  const PlannerBackupFileStorage({
    Future<Directory> Function()? backupDirectoryProvider,
  }) : _backupDirectoryProvider =
           backupDirectoryProvider ?? _defaultBackupDirectory;

  final Future<Directory> Function() _backupDirectoryProvider;

  Future<File> saveBackup(PlannerBackup backup) async {
    final directory = await _backupDirectoryProvider();
    await directory.create(recursive: true);

    final file = File(
      path.join(directory.path, _backupFileName(backup.exportedAt)),
    );

    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(backup.toJson()));

    return file;
  }

  Future<PlannerBackup> readBackup(File file) async {
    final content = await file.readAsString();
    final decoded = jsonDecode(content);

    if (decoded is Map<String, dynamic>) {
      return PlannerBackup.fromJson(decoded);
    }

    if (decoded is Map) {
      return PlannerBackup.fromJson(Map<String, dynamic>.from(decoded));
    }

    throw const FormatException('Backup file must contain a JSON object.');
  }

  static Future<Directory> _defaultBackupDirectory() async {
    final directory = await getApplicationDocumentsDirectory();

    return Directory(path.join(directory.path, 'backups'));
  }

  static String _backupFileName(DateTime exportedAt) {
    final timestamp = exportedAt
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');

    return 'planner_backup_$timestamp.json';
  }
}
