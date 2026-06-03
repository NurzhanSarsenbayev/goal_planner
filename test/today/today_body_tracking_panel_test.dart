import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/application/body_measurement_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_measurement_tracking_service.dart';
import 'package:goal_planner/features/body_tracking/application/body_weight_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_weight_tracking_service.dart';
import 'package:goal_planner/features/body_tracking/domain/body_measurement_entry.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weight_entry.dart';
import 'package:goal_planner/features/today/presentation/widgets/today_body_tracking_panel.dart';
import 'package:goal_planner/l10n/app_localizations.dart';
import 'package:goal_planner/shared/planner_dates.dart';

void main() {
  testWidgets('TodayBodyTrackingPanel is collapsed by default and expands', (
    tester,
  ) async {
    final weightService = BodyWeightTrackingService(
      repository: _FakeBodyWeightRepository(),
      now: () => DateTime(2026, 6, 2, 8),
    );
    final measurementService = BodyMeasurementTrackingService(
      repository: _FakeBodyMeasurementRepository(),
      now: () => DateTime(2026, 6, 2, 8),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TodayBodyTrackingPanel(
            bodyWeightTrackingService: weightService,
            bodyMeasurementTrackingService: measurementService,
            onOpenBodyWeightProgress: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Body tracking'), findsOneWidget);
    expect(find.text('Weight and measurements'), findsOneWidget);
    expect(find.text('Weight today'), findsNothing);
    expect(find.text('Measurements this week'), findsNothing);

    await tester.tap(find.text('Body tracking'));
    await tester.pumpAndSettle();

    expect(find.text('Weight today'), findsOneWidget);
    expect(find.text('Measurements this week'), findsOneWidget);
  });
}

class _FakeBodyWeightRepository implements BodyWeightRepository {
  final Map<String, BodyWeightEntry> _entriesById = {};

  @override
  Future<void> deleteEntry(String entryId) async {
    _entriesById.remove(entryId);
  }

  @override
  Future<List<BodyWeightEntry>> loadAllEntries() async {
    return _entriesById.values.toList(growable: false)
      ..sort((first, second) => first.date.compareTo(second.date));
  }

  @override
  Future<List<BodyWeightEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = dateOnly(startDate);
    final end = dateOnly(endDate);

    return _entriesById.values
        .where((entry) {
          final entryDate = dateOnly(entry.date);

          return !entryDate.isBefore(start) && !entryDate.isAfter(end);
        })
        .toList(growable: false)
      ..sort((first, second) => first.date.compareTo(second.date));
  }

  @override
  Future<void> saveEntry(BodyWeightEntry entry) async {
    _entriesById[entry.id] = entry;
  }
}

class _FakeBodyMeasurementRepository implements BodyMeasurementRepository {
  final Map<String, BodyMeasurementEntry> _entriesById = {};

  @override
  Future<void> deleteEntry(String entryId) async {
    _entriesById.remove(entryId);
  }

  @override
  Future<List<BodyMeasurementEntry>> loadAllEntries() async {
    return _sortedEntries(_entriesById.values);
  }

  @override
  Future<List<BodyMeasurementEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = dateOnly(startDate);
    final end = dateOnly(endDate);
    final entries = _entriesById.values.where((entry) {
      final entryDate = dateOnly(entry.date);

      return !entryDate.isBefore(start) && !entryDate.isAfter(end);
    });

    return _sortedEntries(entries);
  }

  @override
  Future<void> saveEntry(BodyMeasurementEntry entry) async {
    _entriesById[entry.id] = entry;
  }

  List<BodyMeasurementEntry> _sortedEntries(
    Iterable<BodyMeasurementEntry> entries,
  ) {
    return entries.toList(growable: false)..sort((firstEntry, secondEntry) {
      final dateComparison = firstEntry.date.compareTo(secondEntry.date);

      if (dateComparison != 0) {
        return dateComparison;
      }

      return firstEntry.updatedAt.compareTo(secondEntry.updatedAt);
    });
  }
}
