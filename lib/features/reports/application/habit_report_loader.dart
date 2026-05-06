import '../../../shared/planner_dates.dart';
import '../../habits/application/habit_store.dart';
import '../domain/habit_report_summary.dart';
import '../domain/report_period.dart';
import 'habit_report_builder.dart';

class HabitReportLoader {
  const HabitReportLoader({
    required HabitStore habitStore,
    DateTime Function() todayProvider = todayDate,
  }) : _habitStore = habitStore,
       _todayProvider = todayProvider;

  final HabitStore _habitStore;
  final DateTime Function() _todayProvider;

  Future<HabitReportSummary> load(ReportPeriod period) async {
    final today = dateOnly(_todayProvider());
    final startDate = period.startDate(today);

    final entries = await _habitStore.loadEntriesForRange(
      startDate: startDate,
      endDate: today,
    );

    return buildHabitReportSummary(
      habits: _habitStore.habits,
      entries: entries,
      period: period,
      today: today,
    );
  }
}
