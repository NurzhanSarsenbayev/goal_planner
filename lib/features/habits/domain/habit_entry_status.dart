enum HabitEntryStatus {
  none,
  done,
  incomplete,
  failed,
  skipped;

  bool get countsAsFailure {
    return switch (this) {
      HabitEntryStatus.failed || HabitEntryStatus.incomplete => true,
      HabitEntryStatus.none ||
      HabitEntryStatus.done ||
      HabitEntryStatus.skipped => false,
    };
  }

  bool get countsAsCompletion {
    return this == HabitEntryStatus.done;
  }

  bool get isExplicitMark {
    return switch (this) {
      HabitEntryStatus.done ||
      HabitEntryStatus.incomplete ||
      HabitEntryStatus.failed ||
      HabitEntryStatus.skipped => true,
      HabitEntryStatus.none => false,
    };
  }
}
