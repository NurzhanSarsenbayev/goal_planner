import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/application/body_weight_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_weight_tracking_service.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weight_entry.dart';
import 'package:goal_planner/features/body_tracking/presentation/widgets/body_weight_today_card.dart';
import 'package:goal_planner/l10n/app_localizations.dart';

void main() {
  testWidgets('BodyWeightTodayCard saves weight for selected past date', (
    tester,
  ) async {
    final repository = _FakeBodyWeightRepository();
    final service = BodyWeightTrackingService(
      repository: repository,
      now: () => DateTime(2026, 6, 2, 8),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BodyWeightTodayCard(
            service: service,
            onOpenProgress: () {},
            now: () => DateTime(2026, 6, 2, 8),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Enter'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Date:'), findsOneWidget);

    await tester.tap(find.textContaining('Date:'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '60');
    await tester.tap(find.text('Save weight'));
    await tester.pumpAndSettle();

    final selectedDateEntry = await service.loadEntryForDate(
      DateTime(2026, 6, 1),
    );
    final todayEntry = await service.loadEntryForDate(DateTime(2026, 6, 2));

    expect(selectedDateEntry, isNotNull);
    expect(selectedDateEntry!.date, DateTime(2026, 6, 1));
    expect(selectedDateEntry.weightKg, 60);
    expect(todayEntry, isNull);
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
    return _entriesById.values
        .where((entry) {
          return !entry.date.isBefore(startDate) &&
              !entry.date.isAfter(endDate);
        })
        .toList(growable: false)
      ..sort((first, second) => first.date.compareTo(second.date));
  }

  @override
  Future<void> saveEntry(BodyWeightEntry entry) async {
    _entriesById[entry.id] = entry;
  }
}
