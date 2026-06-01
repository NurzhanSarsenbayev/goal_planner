import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/body_weight_tracking_service.dart';
import '../../domain/body_weekly_weight_report.dart';
import '../../domain/body_weight_entry.dart';

class BodyWeightTodayCard extends StatefulWidget {
  const BodyWeightTodayCard({super.key, required this.service});

  final BodyWeightTrackingService service;

  @override
  State<BodyWeightTodayCard> createState() => _BodyWeightTodayCardState();
}

class _BodyWeightTodayCardState extends State<BodyWeightTodayCard> {
  late Future<_BodyWeightTodayState> _loadFuture;
  final TextEditingController _weightController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadFuture = _loadState();
  }

  @override
  void dispose() {
    _weightController.dispose();

    super.dispose();
  }

  Future<_BodyWeightTodayState> _loadState() async {
    final today = DateTime.now();
    final entry = await widget.service.loadEntryForDate(today);
    final weeklyReport = await widget.service.loadWeeklyReport(today);

    if (entry?.weightKg == null) {
      _weightController.clear();
    } else {
      _weightController.text = _formatWeight(entry!.weightKg!);
    }

    return _BodyWeightTodayState(entry: entry, weeklyReport: weeklyReport);
  }

  Future<void> _reload() async {
    setState(() {
      _loadFuture = _loadState();
    });
  }

  Future<void> _saveWeight(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final weight = _parseWeight(_weightController.text);

    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bodyWeightTodayInvalidWeight)),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.service.saveWeightForDate(
        date: DateTime.now(),
        weightKg: weight,
      );

      if (!mounted) {
        return;
      }

      await _reload();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.bodyWeightTodaySaveError)));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _markSkipped(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.service.markSkippedForDate(date: DateTime.now());

      _weightController.clear();

      if (!mounted) {
        return;
      }

      await _reload();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.bodyWeightTodaySaveError)));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<_BodyWeightTodayState>(
      future: _loadFuture,
      builder: (context, snapshot) {
        final state = snapshot.data;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bodyWeightTodayTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.bodyWeightTodaySubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _statusText(l10n, state?.entry),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.bodyWeightTodayWeightLabel,
                    suffixText: l10n.bodyWeightKgSuffix,
                    border: const OutlineInputBorder(),
                  ),
                  enabled: !_isSaving,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                                _saveWeight(context);
                              },
                        child: Text(l10n.bodyWeightTodaySaveButton),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                                _markSkipped(context);
                              },
                        child: Text(l10n.bodyWeightTodaySkipButton),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting &&
                    state == null)
                  const Center(child: CircularProgressIndicator())
                else
                  _BodyWeightWeeklyStats(report: state?.weeklyReport),
              ],
            ),
          ),
        );
      },
    );
  }

  String _statusText(AppLocalizations l10n, BodyWeightEntry? entry) {
    if (entry?.weightKg != null) {
      return l10n.bodyWeightTodaySavedStatus(
        l10n.bodyWeightKgValue(_formatWeight(entry!.weightKg!)),
      );
    }

    if (entry?.isSkipped ?? false) {
      return l10n.bodyWeightTodaySkippedStatus;
    }

    return l10n.bodyWeightTodayEmptyStatus;
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

class _BodyWeightWeeklyStats extends StatelessWidget {
  const _BodyWeightWeeklyStats({required this.report});

  final BodyWeeklyWeightReport? report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentReport = report;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _BodyWeightStatChip(
          label: l10n.bodyWeightWeeklyAverage,
          value: _weightValue(l10n, currentReport?.averageWeightKg),
        ),
        _BodyWeightStatChip(
          label: l10n.bodyWeightWeeklyMinimum,
          value: _weightValue(l10n, currentReport?.minWeightKg),
        ),
        _BodyWeightStatChip(
          label: l10n.bodyWeightWeeklyDays,
          value: currentReport == null
              ? l10n.bodyWeightNoData
              : '${currentReport.weighedDaysCount}/'
                    '${BodyWeeklyWeightReport.totalDaysCount}',
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

class _BodyWeightStatChip extends StatelessWidget {
  const _BodyWeightStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
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
