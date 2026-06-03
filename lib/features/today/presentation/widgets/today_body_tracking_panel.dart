import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../body_tracking/application/body_measurement_tracking_service.dart';
import '../../../body_tracking/application/body_weight_tracking_service.dart';
import '../../../body_tracking/presentation/widgets/body_measurements_today_card.dart';
import '../../../body_tracking/presentation/widgets/body_weight_today_card.dart';

class TodayBodyTrackingPanel extends StatelessWidget {
  const TodayBodyTrackingPanel({
    super.key,
    required this.bodyWeightTrackingService,
    required this.bodyMeasurementTrackingService,
    required this.onOpenBodyWeightProgress,
  });

  final BodyWeightTrackingService bodyWeightTrackingService;
  final BodyMeasurementTrackingService bodyMeasurementTrackingService;
  final VoidCallback onOpenBodyWeightProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.monitor_weight_outlined),
        title: Text(
          l10n.todayBodyTrackingPanelTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(l10n.todayBodyTrackingPanelSubtitle),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          BodyWeightTodayCard(
            service: bodyWeightTrackingService,
            onOpenProgress: onOpenBodyWeightProgress,
          ),
          const SizedBox(height: 12),
          BodyMeasurementsTodayCard(service: bodyMeasurementTrackingService),
        ],
      ),
    );
  }
}
