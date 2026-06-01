import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/body_weight_tracking_service.dart';
import '../../domain/body_weekly_weight_report.dart';
import '../../domain/body_weight_entry.dart';
import '../../../../shared/planner_dates.dart';

class BodyWeightTodayCard extends StatefulWidget {
  const BodyWeightTodayCard({
    super.key,
    required this.service,
    required this.onOpenProgress,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final BodyWeightTrackingService service;
  final VoidCallback onOpenProgress;
  final DateTime Function() now;

  @override
  State<BodyWeightTodayCard> createState() => _BodyWeightTodayCardState();
}

class _BodyWeightTodayCardState extends State<BodyWeightTodayCard> {
  late Future<_BodyWeightTodayState> _loadFuture;

  @override
  void initState() {
    super.initState();

    _loadFuture = _loadState();
  }

  Future<_BodyWeightTodayState> _loadState() async {
    final today = widget.now();
    final entry = await widget.service.loadEntryForDate(today);
    final weeklyReport = await widget.service.loadWeeklyReport(today);

    return _BodyWeightTodayState(entry: entry, weeklyReport: weeklyReport);
  }

  Future<void> _reload() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loadFuture = _loadState();
    });
  }

  Future<bool> _saveWeight(
    BuildContext context, {
    required DateTime date,
    required String rawValue,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final saveErrorMessage = l10n.bodyWeightTodaySaveError;
    final weight = _parseWeight(rawValue);

    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bodyWeightTodayInvalidWeight)),
      );
      return false;
    }

    try {
      await widget.service.saveWeightForDate(date: date, weightKg: weight);

      await _reload();

      return true;
    } catch (_) {
      if (!mounted) {
        return false;
      }

      messenger.showSnackBar(SnackBar(content: Text(saveErrorMessage)));

      return false;
    }
  }

  Future<bool> _markSkipped(
    BuildContext context, {
    required DateTime date,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final saveErrorMessage = AppLocalizations.of(
      context,
    ).bodyWeightTodaySaveError;

    try {
      await widget.service.markSkippedForDate(date: date);

      await _reload();

      return true;
    } catch (_) {
      if (!mounted) {
        return false;
      }

      messenger.showSnackBar(SnackBar(content: Text(saveErrorMessage)));

      return false;
    }
  }

  Future<void> _openEntrySheet(
    BuildContext context,
    BodyWeightEntry? entry,
  ) async {
    final today = dateOnly(widget.now());

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _BodyWeightEntrySheet(
          initialDate: today,
          initialWeightText: entry?.weightKg == null
              ? ''
              : _formatWeight(entry!.weightKg!),
          onLoadEntryForDate: widget.service.loadEntryForDate,
          onSave: ({required date, required rawValue}) {
            return _saveWeight(context, date: date, rawValue: rawValue);
          },
          onSkip: (date) {
            return _markSkipped(context, date: date);
          },
          now: widget.now,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<_BodyWeightTodayState>(
      future: _loadFuture,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final entry = state?.entry;
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting &&
            state == null;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monitor_weight_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.bodyWeightTodayTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      _todayValue(l10n, entry),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const LinearProgressIndicator()
                else
                  _BodyWeightWeeklyStats(report: state?.weeklyReport),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () {
                                _openEntrySheet(context, entry);
                              },
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(
                          entry == null
                              ? l10n.bodyWeightTodayEnterButton
                              : l10n.bodyWeightTodayChangeButton,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: widget.onOpenProgress,
                        icon: const Icon(Icons.insights_outlined),
                        label: Text(l10n.bodyWeightTodayOpenProgressButton),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _todayValue(AppLocalizations l10n, BodyWeightEntry? entry) {
    if (entry?.weightKg != null) {
      return l10n.bodyWeightKgValue(_formatWeight(entry!.weightKg!));
    }

    if (entry?.isSkipped ?? false) {
      return l10n.bodyWeightTodaySkipButton;
    }

    return l10n.bodyWeightNoData;
  }

  double? _parseWeight(String rawValue) {
    final normalizedValue = rawValue.trim().replaceAll(',', '.');

    if (normalizedValue.isEmpty) {
      return null;
    }

    return double.tryParse(normalizedValue);
  }

  String _formatWeight(double weight) {
    final fixed = weight.toStringAsFixed(2);

    if (fixed.endsWith('00')) {
      return weight.toStringAsFixed(0);
    }

    if (fixed.endsWith('0')) {
      return weight.toStringAsFixed(1);
    }

    return fixed;
  }
}

class _BodyWeightEntrySheet extends StatefulWidget {
  const _BodyWeightEntrySheet({
    required this.initialDate,
    required this.initialWeightText,
    required this.onLoadEntryForDate,
    required this.onSave,
    required this.onSkip,
    required this.now,
  });

  final DateTime initialDate;
  final String initialWeightText;
  final Future<BodyWeightEntry?> Function(DateTime date) onLoadEntryForDate;
  final Future<bool> Function({
    required DateTime date,
    required String rawValue,
  })
  onSave;
  final Future<bool> Function(DateTime date) onSkip;
  final DateTime Function() now;

  @override
  State<_BodyWeightEntrySheet> createState() => _BodyWeightEntrySheetState();
}

class _BodyWeightEntrySheetState extends State<_BodyWeightEntrySheet> {
  late final TextEditingController _weightController;
  late DateTime _selectedDate;
  bool _isSaving = false;
  bool _isLoadingDate = false;

  @override
  void initState() {
    super.initState();

    _selectedDate = dateOnly(widget.initialDate);
    _weightController = TextEditingController(text: widget.initialWeightText);
  }

  @override
  void dispose() {
    _weightController.dispose();

    super.dispose();
  }

  String _formatWeight(double weight) {
    final fixed = weight.toStringAsFixed(2);

    if (fixed.endsWith('00')) {
      return weight.toStringAsFixed(0);
    }

    if (fixed.endsWith('0')) {
      return weight.toStringAsFixed(1);
    }

    return fixed;
  }

  Future<void> _pickDate() async {
    final today = dateOnly(widget.now());
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(today.year - 2, today.month, today.day),
      lastDate: today,
      helpText: AppLocalizations.of(context).bodyWeightTodayDatePickerTitle,
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    setState(() {
      _isLoadingDate = true;
    });

    final entry = await widget.onLoadEntryForDate(selectedDate);

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedDate = dateOnly(selectedDate);
      _weightController.text = entry?.weightKg == null
          ? ''
          : _formatWeight(entry!.weightKg!);
      _isLoadingDate = false;
    });
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    final shouldClose = await widget.onSave(
      date: _selectedDate,
      rawValue: _weightController.text,
    );

    if (!mounted) {
      return;
    }

    if (shouldClose) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSaving = false;
    });
  }

  Future<void> _skip() async {
    setState(() {
      _isSaving = true;
    });

    final shouldClose = await widget.onSkip(_selectedDate);

    if (!mounted) {
      return;
    }

    if (shouldClose) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final materialL10n = MaterialLocalizations.of(context);
    final isBusy = _isSaving || _isLoadingDate;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.bodyWeightTodaySheetTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : _pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  '${l10n.bodyWeightTodayDateLabel}: '
                  '${materialL10n.formatMediumDate(_selectedDate)}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weightController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.bodyWeightTodayWeightLabel,
                suffixText: l10n.bodyWeightKgSuffix,
                border: const OutlineInputBorder(),
              ),
              enabled: !isBusy,
              onSubmitted: (_) {
                if (!isBusy) {
                  _save();
                }
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isBusy ? null : _save,
                child: Text(l10n.bodyWeightTodaySaveButton),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isBusy ? null : _skip,
                child: Text(l10n.bodyWeightTodaySkipButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyWeightWeeklyStats extends StatelessWidget {
  const _BodyWeightWeeklyStats({required this.report});

  final BodyWeeklyWeightReport? report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentReport = report;

    return Row(
      children: [
        Expanded(
          child: _BodyWeightStat(
            label: l10n.bodyWeightWeeklyAverage,
            value: _weightValue(l10n, currentReport?.averageWeightKg),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _BodyWeightStat(
            label: l10n.bodyWeightWeeklyMinimum,
            value: _weightValue(l10n, currentReport?.minWeightKg),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _BodyWeightStat(
            label: l10n.bodyWeightWeeklyDays,
            value: currentReport == null
                ? l10n.bodyWeightNoData
                : '${currentReport.weighedDaysCount}/'
                      '${BodyWeeklyWeightReport.totalDaysCount}',
          ),
        ),
      ],
    );
  }

  String _weightValue(AppLocalizations l10n, double? weight) {
    if (weight == null) {
      return l10n.bodyWeightNoData;
    }

    return l10n.bodyWeightKgValue(_formatWeight(weight));
  }

  String _formatWeight(double weight) {
    final fixed = weight.toStringAsFixed(2);

    if (fixed.endsWith('00')) {
      return weight.toStringAsFixed(0);
    }

    if (fixed.endsWith('0')) {
      return weight.toStringAsFixed(1);
    }

    return fixed;
  }
}

class _BodyWeightStat extends StatelessWidget {
  const _BodyWeightStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyWeightTodayState {
  const _BodyWeightTodayState({
    required this.entry,
    required this.weeklyReport,
  });

  final BodyWeightEntry? entry;
  final BodyWeeklyWeightReport weeklyReport;
}
