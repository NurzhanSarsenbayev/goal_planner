import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/data/local/app_database.dart' as local;
import 'package:goal_planner/data/repositories/drift_body_measurement_repository.dart';
import 'package:goal_planner/features/body_tracking/domain/body_measurement_entry.dart';

void main() {
  group('DriftBodyMeasurementRepository', () {
    late local.AppDatabase database;
    late DriftBodyMeasurementRepository repository;

    setUp(() {
      database = local.AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftBodyMeasurementRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('persists and loads body measurement entry', () async {
      final entry = _entry();

      await repository.saveEntry(entry);

      final entries = await repository.loadAllEntries();

      expect(entries, hasLength(1));
      expect(entries.single.id, 'measurement-2026-05-25');
      expect(entries.single.date, DateTime(2026, 5, 25));
      expect(entries.single.neckCm, 34);
      expect(entries.single.waistCm, 74);
      expect(entries.single.hipsCm, 101);
      expect(entries.single.note, 'Weekly measurements');
      expect(entries.single.createdAt, entry.createdAt);
      expect(entries.single.updatedAt, entry.updatedAt);
    });

    test('persists partial measurement entry', () async {
      final entry = _entry(
        id: 'measurement-2026-05-26',
        date: DateTime(2026, 5, 26),
        neckCm: null,
        waistCm: 73.5,
        hipsCm: null,
        note: 'Only waist',
      );

      await repository.saveEntry(entry);

      final entries = await repository.loadAllEntries();

      expect(entries, hasLength(1));
      expect(entries.single.neckCm, isNull);
      expect(entries.single.waistCm, 73.5);
      expect(entries.single.hipsCm, isNull);
      expect(entries.single.note, 'Only waist');
    });

    test('loads entries for selected date range ordered by date', () async {
      await repository.saveEntry(
        _entry(id: 'before', date: DateTime(2026, 5, 24), waistCm: 90),
      );
      await repository.saveEntry(
        _entry(id: 'second', date: DateTime(2026, 5, 26), waistCm: 73),
      );
      await repository.saveEntry(
        _entry(id: 'first', date: DateTime(2026, 5, 25), waistCm: 74),
      );
      await repository.saveEntry(
        _entry(id: 'after', date: DateTime(2026, 6, 1), waistCm: 60),
      );

      final entries = await repository.loadEntriesForRange(
        startDate: DateTime(2026, 5, 25),
        endDate: DateTime(2026, 5, 31),
      );

      expect(entries.map((entry) => entry.id), ['first', 'second']);
    });

    test('updates existing body measurement entry by id', () async {
      final entry = _entry();
      final updatedAt = DateTime(2026, 5, 25, 12);

      await repository.saveEntry(entry);
      await repository.saveEntry(
        entry.copyWith(
          waistCm: 73,
          hipsCm: 100,
          note: 'Updated',
          updatedAt: updatedAt,
        ),
      );

      final entries = await repository.loadAllEntries();

      expect(entries, hasLength(1));
      expect(entries.single.neckCm, 34);
      expect(entries.single.waistCm, 73);
      expect(entries.single.hipsCm, 100);
      expect(entries.single.note, 'Updated');
      expect(entries.single.updatedAt, updatedAt);
    });

    test('deletes body measurement entry', () async {
      await repository.saveEntry(_entry());

      await repository.deleteEntry('measurement-2026-05-25');

      final entries = await repository.loadAllEntries();

      expect(entries, isEmpty);
    });
  });
}

BodyMeasurementEntry _entry({
  String id = 'measurement-2026-05-25',
  DateTime? date,
  double? neckCm = 34,
  double? waistCm = 74,
  double? hipsCm = 101,
  String note = 'Weekly measurements',
}) {
  final now = DateTime(2026, 5, 25, 8);

  return BodyMeasurementEntry(
    id: id,
    date: date ?? DateTime(2026, 5, 25),
    neckCm: neckCm,
    waistCm: waistCm,
    hipsCm: hipsCm,
    note: note,
    createdAt: now,
    updatedAt: now,
  );
}
