import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/body_measurement_tracking_service.dart';
import '../../domain/body_weekly_measurement_report.dart';

class BodyMeasurementsTodayCard extends StatefulWidget {
  const BodyMeasurementsTodayCard({super.key, required this.service});

  final BodyMeasurementTrackingService service;

  @override
  State<BodyMeasurementsTodayCard> createState() =>
      _BodyMeasurementsTodayCardState();
}

class _BodyMeasurementsTodayCardState extends State<BodyMeasurementsTodayCard> {
  late Future<BodyWeeklyMeasurementReport> _loadFuture;

  @override
  void initState() {
    super.initState();

    _loadFuture = _loadReport();
  }

  Future<BodyWeeklyMeasurementReport> _loadReport() {
    return widget.service.loadWeeklyReport(DateTime.now());
  }

  Future<void> _reload() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loadFuture = _loadReport();
    });
  }

  Future<bool> _saveMeasurements(
    BuildContext context, {
    required String neckText,
    required String waistText,
    required String hipsText,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final invalidMessage = l10n.bodyMeasurementsTodayInvalidMeasurements;
    final saveErrorMessage = l10n.bodyMeasurementsTodaySaveError;

    final neckCm = _parseMeasurement(neckText);
    final waistCm = _parseMeasurement(waistText);
    final hipsCm = _parseMeasurement(hipsText);

    if (_hasInvalidMeasurement(neckText, neckCm) ||
        _hasInvalidMeasurement(waistText, waistCm) ||
        _hasInvalidMeasurement(hipsText, hipsCm) ||
        _isNonPositive(neckCm) ||
        _isNonPositive(waistCm) ||
        _isNonPositive(hipsCm) ||
        (neckCm == null && waistCm == null && hipsCm == null)) {
      messenger.showSnackBar(SnackBar(content: Text(invalidMessage)));

      return false;
    }

    try {
      await widget.service.saveMeasurementsForWeek(
        weekDate: DateTime.now(),
        neckCm: neckCm,
        waistCm: waistCm,
        hipsCm: hipsCm,
      );

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
    BodyWeeklyMeasurementReport? report,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _BodyMeasurementsEntrySheet(
          initialNeckText: _formatInitialMeasurement(report?.neckCm),
          initialWaistText: _formatInitialMeasurement(report?.waistCm),
          initialHipsText: _formatInitialMeasurement(report?.hipsCm),
          onSave: ({required neckText, required waistText, required hipsText}) {
            return _saveMeasurements(
              context,
              neckText: neckText,
              waistText: waistText,
              hipsText: hipsText,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<BodyWeeklyMeasurementReport>(
      future: _loadFuture,
      builder: (context, snapshot) {
        final report = snapshot.data;
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting &&
            report == null;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.straighten_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.bodyMeasurementsTodayTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const LinearProgressIndicator()
                else
                  Text(
                    _summaryText(l10n, report),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            _openEntrySheet(context, report);
                          },
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(
                      report?.hasMeasurements ?? false
                          ? l10n.bodyMeasurementsTodayChangeButton
                          : l10n.bodyMeasurementsTodayEnterButton,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _summaryText(
    AppLocalizations l10n,
    BodyWeeklyMeasurementReport? report,
  ) {
    if (!(report?.hasMeasurements ?? false)) {
      return l10n.bodyMeasurementsTodayEmptyStatus;
    }

    final parts = <String>[];

    if (report?.neckCm != null) {
      parts.add(
        '${l10n.bodyMeasurementsNeckLabel} '
        '${_formatMeasurement(report!.neckCm!)} '
        '${l10n.bodyMeasurementsCmSuffix}',
      );
    }

    if (report?.waistCm != null) {
      parts.add(
        '${l10n.bodyMeasurementsWaistLabel} '
        '${_formatMeasurement(report!.waistCm!)} '
        '${l10n.bodyMeasurementsCmSuffix}',
      );
    }

    if (report?.hipsCm != null) {
      parts.add(
        '${l10n.bodyMeasurementsHipsLabel} '
        '${_formatMeasurement(report!.hipsCm!)} '
        '${l10n.bodyMeasurementsCmSuffix}',
      );
    }

    return parts.join(' · ');
  }

  double? _parseMeasurement(String rawValue) {
    final normalizedValue = rawValue.trim().replaceAll(',', '.');

    if (normalizedValue.isEmpty) {
      return null;
    }

    return double.tryParse(normalizedValue);
  }

  bool _hasInvalidMeasurement(String rawValue, double? parsedValue) {
    return rawValue.trim().isNotEmpty && parsedValue == null;
  }

  bool _isNonPositive(double? value) {
    return value != null && value <= 0;
  }

  String _formatInitialMeasurement(double? value) {
    if (value == null) {
      return '';
    }

    return _formatMeasurement(value);
  }

  String _formatMeasurement(double value) {
    final fixed = value.toStringAsFixed(1);

    if (fixed.endsWith('.0')) {
      return value.toStringAsFixed(0);
    }

    return fixed;
  }
}

class _BodyMeasurementsEntrySheet extends StatefulWidget {
  const _BodyMeasurementsEntrySheet({
    required this.initialNeckText,
    required this.initialWaistText,
    required this.initialHipsText,
    required this.onSave,
  });

  final String initialNeckText;
  final String initialWaistText;
  final String initialHipsText;
  final Future<bool> Function({
    required String neckText,
    required String waistText,
    required String hipsText,
  })
  onSave;

  @override
  State<_BodyMeasurementsEntrySheet> createState() =>
      _BodyMeasurementsEntrySheetState();
}

class _BodyMeasurementsEntrySheetState
    extends State<_BodyMeasurementsEntrySheet> {
  late final TextEditingController _neckController;
  late final TextEditingController _waistController;
  late final TextEditingController _hipsController;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();

    _neckController = TextEditingController(text: widget.initialNeckText);
    _waistController = TextEditingController(text: widget.initialWaistText);
    _hipsController = TextEditingController(text: widget.initialHipsText);
  }

  @override
  void dispose() {
    _neckController.dispose();
    _waistController.dispose();
    _hipsController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final saved = await widget.onSave(
      neckText: _neckController.text,
      waistText: _waistController.text,
      hipsText: _hipsController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (saved) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.bodyMeasurementsTodaySheetTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _BodyMeasurementTextField(
              controller: _neckController,
              label: l10n.bodyMeasurementsNeckLabel,
              suffix: l10n.bodyMeasurementsCmSuffix,
            ),
            const SizedBox(height: 12),
            _BodyMeasurementTextField(
              controller: _waistController,
              label: l10n.bodyMeasurementsWaistLabel,
              suffix: l10n.bodyMeasurementsCmSuffix,
            ),
            const SizedBox(height: 12),
            _BodyMeasurementTextField(
              controller: _hipsController,
              label: l10n.bodyMeasurementsHipsLabel,
              suffix: l10n.bodyMeasurementsCmSuffix,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(l10n.bodyMeasurementsTodaySaveButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyMeasurementTextField extends StatelessWidget {
  const _BodyMeasurementTextField({
    required this.controller,
    required this.label,
    required this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
