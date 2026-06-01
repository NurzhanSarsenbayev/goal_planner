import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/application/body_measurement_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_profile_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_profile_tracking_service.dart';
import 'package:goal_planner/features/body_tracking/application/body_weight_repository.dart';
import 'package:goal_planner/features/body_tracking/domain/body_measurement_entry.dart';
import 'package:goal_planner/features/body_tracking/domain/body_profile.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weight_entry.dart';
import 'package:goal_planner/features/body_tracking/presentation/widgets/body_profile_progress_card.dart';
import 'package:goal_planner/l10n/app_localizations.dart';

void main() {
  testWidgets('BodyProfileProgressCard saves body profile', (tester) async {
    final profileRepository = _FakeBodyProfileRepository();
    final service = BodyProfileTrackingService(
      profileRepository: profileRepository,
      weightRepository: _FakeBodyWeightRepository(),
      measurementRepository: _FakeBodyMeasurementRepository(),
      now: () => DateTime(2026, 6, 1, 8),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: BodyProfileProgressCard(service: service)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Body profile'), findsOneWidget);
    expect(find.text('Set up profile'), findsOneWidget);

    await tester.tap(find.text('Set up profile'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Height'), '168');
    await tester.tap(find.text('Save profile'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Height: 168 cm'), findsOneWidget);
    expect(find.textContaining('US Navy — waist + hips'), findsOneWidget);

    final profile = await profileRepository.loadProfile();

    expect(profile, isNotNull);
    expect(profile!.id, defaultBodyProfileId);
    expect(profile.heightCm, 168);
    expect(profile.bodyFatFormula, BodyFatFormula.usNavyFemale);
  });
}

class _FakeBodyProfileRepository implements BodyProfileRepository {
  BodyProfile? _profile;

  @override
  Future<void> deleteProfile() async {
    _profile = null;
  }

  @override
  Future<BodyProfile?> loadProfile() async {
    return _profile;
  }

  @override
  Future<void> saveProfile(BodyProfile profile) async {
    _profile = profile;
  }
}

class _FakeBodyWeightRepository implements BodyWeightRepository {
  @override
  Future<void> deleteEntry(String entryId) async {}

  @override
  Future<List<BodyWeightEntry>> loadAllEntries() async {
    return const [];
  }

  @override
  Future<List<BodyWeightEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return const [];
  }

  @override
  Future<void> saveEntry(BodyWeightEntry entry) async {}
}

class _FakeBodyMeasurementRepository implements BodyMeasurementRepository {
  @override
  Future<void> deleteEntry(String entryId) async {}

  @override
  Future<List<BodyMeasurementEntry>> loadAllEntries() async {
    return const [];
  }

  @override
  Future<List<BodyMeasurementEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return const [];
  }

  @override
  Future<void> saveEntry(BodyMeasurementEntry entry) async {}
}
