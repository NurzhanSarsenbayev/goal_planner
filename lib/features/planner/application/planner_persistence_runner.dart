import 'dart:async';

import 'package:flutter/foundation.dart';

class PlannerPersistenceRunner {
  const PlannerPersistenceRunner();

  void run(Future<void> Function() operation) {
    unawaited(
      operation().catchError((Object error, StackTrace stackTrace) {
        debugPrint('Failed to persist planner state: $error');
        debugPrintStack(stackTrace: stackTrace);
      }),
    );
  }
}
