import '../domain/planner_backup.dart';

abstract interface class PlannerBackupRestoreRepository {
  Future<void> replaceAll(PlannerBackupData data);
}
