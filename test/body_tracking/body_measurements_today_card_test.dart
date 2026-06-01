import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/application/body_measurement_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_measurement_tracking_service.dart';
import 'package:goal_planner/features/body_tracking/domain/body_measurement_entry.dart';
import 'package:goal_planner/features/body_tracking/presentation/widgets/body_measurements_today_card.dart';
import 'package:goal_planner/l10n/app_localizations.dart';
import 'package:goal_planner/shared/planner_dates.dart';

void main() {
  testWidgets('BodyMeasurementsTodayCard saves weekly measurements', (
    tester,
  ) async {
    final repository = _FakeBodyMeasurementRepository();
    final service = BodyMeasurementTrackingService(
      repository: repository,
      now: () => DateTime(2026, 5, 25, 8),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: BodyMeasurementsTodayCard(service: service)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Measurements this week'), findsOneWidget);
    expect(find.text('No measurements entered this week.'), findsOneWidget);

    await tester.tap(find.text('Enter'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Waist'), '74');
    await tester.enterText(find.widgetWithText(TextField, 'Hips'), '101');

    await tester.tap(find.text('Save measurements'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Waist 74 cm'), findsOneWidget);
    expect(find.textContaining('Hips 101 cm'), findsOneWidget);
  });
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
