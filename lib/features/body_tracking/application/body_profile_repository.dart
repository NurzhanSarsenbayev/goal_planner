import '../domain/body_profile.dart';

abstract interface class BodyProfileRepository {
  Future<BodyProfile?> loadProfile();

  Future<void> saveProfile(BodyProfile profile);

  Future<void> deleteProfile();
}
