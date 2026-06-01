import '../domain/body_weight_entry.dart';

abstract class BodyWeightRepository {
  Future<List<BodyWeightEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<BodyWeightEntry>> loadAllEntries();

  Future<void> saveEntry(BodyWeightEntry entry);

  Future<void> deleteEntry(String entryId);
}
