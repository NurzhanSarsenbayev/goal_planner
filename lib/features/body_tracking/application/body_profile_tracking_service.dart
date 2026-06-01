import '../domain/body_measurement_entry.dart';
import '../domain/body_metrics.dart';
import '../domain/body_metrics_calculator.dart';
import '../domain/body_profile.dart';
import '../domain/body_weight_entry.dart';
import 'body_measurement_repository.dart';
import 'body_profile_repository.dart';
import 'body_weight_repository.dart';

class BodyProfileTrackingService {
  BodyProfileTrackingService({
    required BodyProfileRepository profileRepository,
    required BodyWeightRepository weightRepository,
    required BodyMeasurementRepository measurementRepository,
    BodyMetricsCalculator metricsCalculator = const BodyMetricsCalculator(),
    DateTime Function()? now,
  }) : _profileRepository = profileRepository,
       _weightRepository = weightRepository,
       _measurementRepository = measurementRepository,
       _metricsCalculator = metricsCalculator,
       _now = now ?? DateTime.now;

  final BodyProfileRepository _profileRepository;
  final BodyWeightRepository _weightRepository;
  final BodyMeasurementRepository _measurementRepository;
  final BodyMetricsCalculator _metricsCalculator;
  final DateTime Function() _now;

  Future<BodyProfile?> loadProfile() {
    return _profileRepository.loadProfile();
  }

  Future<void> saveProfile({
    required double heightCm,
    required BodyFatFormula bodyFatFormula,
  }) async {
    if (heightCm <= 0) {
      throw ArgumentError.value(heightCm, 'heightCm', 'must be positive.');
    }

    final existingProfile = await _profileRepository.loadProfile();
    final now = _now();

    await _profileRepository.saveProfile(
      BodyProfile(
        id: existingProfile?.id ?? defaultBodyProfileId,
        heightCm: heightCm,
        bodyFatFormula: bodyFatFormula,
        createdAt: existingProfile?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  Future<void> deleteProfile() {
    return _profileRepository.deleteProfile();
  }

  Future<BodyMetrics> loadCurrentMetrics() async {
    final profile = await _profileRepository.loadProfile();

    if (profile == null) {
      return const BodyMetrics(bmi: null, estimatedBodyFatPercent: null);
    }

    final latestWeightEntry = await _loadLatestWeightEntry();
    final latestMeasurementEntry = await _loadLatestMeasurementEntry();

    return _metricsCalculator.calculate(
      profile: profile,
      weightKg: latestWeightEntry?.weightKg,
      neckCm: latestMeasurementEntry?.neckCm,
      waistCm: latestMeasurementEntry?.waistCm,
      hipsCm: latestMeasurementEntry?.hipsCm,
    );
  }

  Future<BodyWeightEntry?> _loadLatestWeightEntry() async {
    final entries = await _weightRepository.loadAllEntries();

    if (entries.isEmpty) {
      return null;
    }

    return _sortedWeightEntries(entries).last;
  }

  Future<BodyMeasurementEntry?> _loadLatestMeasurementEntry() async {
    final entries = await _measurementRepository.loadAllEntries();

    if (entries.isEmpty) {
      return null;
    }

    return _sortedMeasurementEntries(entries).last;
  }

  List<BodyWeightEntry> _sortedWeightEntries(List<BodyWeightEntry> entries) {
    return entries.toList(growable: false)..sort((firstEntry, secondEntry) {
      final dateComparison = firstEntry.date.compareTo(secondEntry.date);

      if (dateComparison != 0) {
        return dateComparison;
      }

      return firstEntry.updatedAt.compareTo(secondEntry.updatedAt);
    });
  }

  List<BodyMeasurementEntry> _sortedMeasurementEntries(
    List<BodyMeasurementEntry> entries,
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
