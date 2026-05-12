import '../../../l10n/app_localizations.dart';
import '../domain/report_period.dart';

extension ReportPeriodL10n on ReportPeriod {
  String localizedTitle(AppLocalizations l10n) {
    return switch (this) {
      ReportPeriod.today => l10n.reportPeriodToday,
      ReportPeriod.last7Days => l10n.reportPeriodLast7Days,
      ReportPeriod.last14Days => l10n.reportPeriodLast14Days,
    };
  }

  String localizedShortLabel(AppLocalizations l10n) {
    return switch (this) {
      ReportPeriod.today => l10n.reportPeriodToday,
      ReportPeriod.last7Days => l10n.reportPeriod7DaysShort,
      ReportPeriod.last14Days => l10n.reportPeriod14DaysShort,
    };
  }
}
