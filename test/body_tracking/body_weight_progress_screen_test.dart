import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/application/body_measurement_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_measurement_tracking_service.dart';
import 'package:goal_planner/features/body_tracking/application/body_weight_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_weight_tracking_service.dart';
import 'package:goal_planner/features/body_tracking/domain/body_measurement_entry.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weight_entry.dart';
import 'package:goal_planner/features/body_tracking/presentation/screens/body_weight_progress_screen.dart';
import 'package:goal_planner/l10n/app_localizations.dart';
import 'package:goal_planner/shared/planner_dates.dart';

void main() {
  testWidgets(
    'BodyWeightProgressScreen shows weight and measurements reports',
    (tester) async {
      final weightRepository = _FakeBodyWeightRepository();
      final measurementRepository = _FakeBodyMeasurementRepository();
      final weightService = BodyWeightTrackingService(
        repository: weightRepository,
      );
      final measurementService = BodyMeasurementTrackingService(
        repository: measurementRepository,
      );
      final today = DateTime.now();

      await weightService.saveWeightForDate(date: today, weightKg: 60);
      await measurementService.saveMeasurementsForWeek(
        weekDate: today,
        waistCm: 74,
        hipsCm: 101,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BodyWeightProgressScreen(
            service: weightService,
            measurementService: measurementService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Weight progress'), findsOneWidget);
      expect(find.text('Week average'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Measurements'), 300);
      await tester.pumpAndSettle();

      expect(find.text('Measurements'), findsOneWidget);
      expect(find.text('Waist'), findsOneWidget);
      expect(find.text('74 cm'), findsOneWidget);
      expect(find.text('Hips'), findsOneWidget);
      expect(find.text('101 cm'), findsOneWidget);
    },
  );
}

class _FakeBodyWeightRepository implements BodyWeightRepository {
  final Map<String, BodyWeightEntry> _entriesById = {};

  @override
  Future<void> deleteEntry(String entryId) async {
    _entriesById.remove(entryId);
  }

  @override
  Future<List<BodyWeightEntry>> loadAllEntries() async {
    return _sortedEntries(_entriesById.values);
  }

  @override
  Future<List<BodyWeightEntry>> loadEntriesForRange({
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
  Future<void> saveEntry(BodyWeightEntry entry) async {
    _entriesById[entry.id] = entry;
  }

  List<BodyWeightEntry> _sortedEntries(Iterable<BodyWeightEntry> entries) {
    return entries.toList(growable: false)..sort((firstEntry, secondEntry) {
      final dateComparison = firstEntry.date.compareTo(secondEntry.date);

      if (dateComparison != 0) {
        return dateComparison;
      }

      return firstEntry.updatedAt.compareTo(secondEntry.updatedAt);
    });
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
