import '../domain/body_measurement_entry.dart';

abstract class BodyMeasurementRepository {
  Future<List<BodyMeasurementEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<BodyMeasurementEntry>> loadAllEntries();

  Future<void> saveEntry(BodyMeasurementEntry entry);

  Future<void> deleteEntry(String entryId);
}
