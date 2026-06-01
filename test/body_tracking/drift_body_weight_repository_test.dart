import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/data/local/app_database.dart' as local;
import 'package:goal_planner/data/repositories/drift_body_weight_repository.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weight_entry.dart';

void main() {
  group('DriftBodyWeightRepository', () {
    late local.AppDatabase database;
    late DriftBodyWeightRepository repository;

    setUp(() {
      database = local.AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftBodyWeightRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('persists and loads body weight entry', () async {
      final entry = _entry();

      await repository.saveEntry(entry);

      final entries = await repository.loadAllEntries();

      expect(entries, hasLength(1));
      expect(entries.single.id, 'weight-2026-05-25');
      expect(entries.single.date, DateTime(2026, 5, 25));
      expect(entries.single.weightKg, 80.5);
      expect(entries.single.isSkipped, isFalse);
      expect(entries.single.note, 'Morning weight');
      expect(entries.single.createdAt, entry.createdAt);
      expect(entries.single.updatedAt, entry.updatedAt);
    });

    test('persists skipped day without weight', () async {
      final entry = _entry(
        id: 'weight-2026-05-26',
        date: DateTime(2026, 5, 26),
        weightKg: null,
        isSkipped: true,
        note: 'Did not weigh',
      );

      await repository.saveEntry(entry);

      final entries = await repository.loadAllEntries();

      expect(entries, hasLength(1));
      expect(entries.single.weightKg, isNull);
      expect(entries.single.isSkipped, isTrue);
      expect(entries.single.note, 'Did not weigh');
    });

    test('loads entries for selected date range ordered by date', () async {
      await repository.saveEntry(
        _entry(id: 'before', date: DateTime(2026, 5, 24), weightKg: 90),
      );
      await repository.saveEntry(
        _entry(id: 'second', date: DateTime(2026, 5, 26), weightKg: 80),
      );
      await repository.saveEntry(
        _entry(id: 'first', date: DateTime(2026, 5, 25), weightKg: 81),
      );
      await repository.saveEntry(
        _entry(id: 'after', date: DateTime(2026, 6, 1), weightKg: 70),
      );

      final entries = await repository.loadEntriesForRange(
        startDate: DateTime(2026, 5, 25),
        endDate: DateTime(2026, 5, 31),
      );

      expect(entries.map((entry) => entry.id), ['first', 'second']);
    });

    test('updates existing body weight entry by id', () async {
      final entry = _entry();
      final updatedAt = DateTime(2026, 5, 25, 12);

      await repository.saveEntry(entry);
      await repository.saveEntry(
        entry.copyWith(weightKg: 79.8, note: 'Updated', updatedAt: updatedAt),
      );

      final entries = await repository.loadAllEntries();

      expect(entries, hasLength(1));
      expect(entries.single.weightKg, 79.8);
      expect(entries.single.note, 'Updated');
      expect(entries.single.updatedAt, updatedAt);
    });

    test('deletes body weight entry', () async {
      await repository.saveEntry(_entry());

      await repository.deleteEntry('weight-2026-05-25');

      final entries = await repository.loadAllEntries();

      expect(entries, isEmpty);
    });
  });
}

BodyWeightEntry _entry({
  String id = 'weight-2026-05-25',
  DateTime? date,
  double? weightKg = 80.5,
  bool isSkipped = false,
  String note = 'Morning weight',
}) {
  final now = DateTime(2026, 5, 25, 8);

  return BodyWeightEntry(
    id: id,
    date: date ?? DateTime(2026, 5, 25),
    weightKg: weightKg,
    isSkipped: isSkipped,
    note: note,
    createdAt: now,
    updatedAt: now,
  );
}
