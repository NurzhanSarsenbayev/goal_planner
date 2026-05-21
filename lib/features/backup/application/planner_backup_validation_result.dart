class PlannerBackupValidationResult {
  const PlannerBackupValidationResult(this.errors);

  final List<PlannerBackupValidationError> errors;

  bool get isValid => errors.isEmpty;

  void throwIfInvalid() {
    if (isValid) {
      return;
    }

    throw PlannerBackupValidationException(errors);
  }
}

class PlannerBackupValidationError {
  const PlannerBackupValidationError({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}

class PlannerBackupValidationException implements Exception {
  const PlannerBackupValidationException(this.errors);

  final List<PlannerBackupValidationError> errors;

  @override
  String toString() {
    final details = errors.map((error) => error.message).join('\n');

    return 'PlannerBackupValidationException:\n$details';
  }
}
