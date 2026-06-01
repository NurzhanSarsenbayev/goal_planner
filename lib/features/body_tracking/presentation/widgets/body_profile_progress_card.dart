import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/body_profile_tracking_service.dart';
import '../../domain/body_profile.dart';

class BodyProfileProgressCard extends StatefulWidget {
  const BodyProfileProgressCard({
    super.key,
    required this.service,
    this.onProfileChanged,
  });

  final BodyProfileTrackingService service;
  final Future<void> Function()? onProfileChanged;

  @override
  State<BodyProfileProgressCard> createState() =>
      _BodyProfileProgressCardState();
}

class _BodyProfileProgressCardState extends State<BodyProfileProgressCard> {
  late Future<BodyProfile?> _loadFuture;

  @override
  void initState() {
    super.initState();

    _loadFuture = widget.service.loadProfile();
  }

  Future<void> _reload() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loadFuture = widget.service.loadProfile();
    });
  }

  Future<bool> _saveProfile(
    BuildContext context, {
    required String heightText,
    required BodyFatFormula bodyFatFormula,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final invalidMessage = l10n.bodyProfileInvalidHeight;
    final saveErrorMessage = l10n.bodyProfileSaveError;

    final heightCm = _parseHeight(heightText);

    if (heightCm == null || heightCm <= 0) {
      messenger.showSnackBar(SnackBar(content: Text(invalidMessage)));

      return false;
    }

    try {
      await widget.service.saveProfile(
        heightCm: heightCm,
        bodyFatFormula: bodyFatFormula,
      );

      await _reload();

      final onProfileChanged = widget.onProfileChanged;
      if (onProfileChanged != null) {
        await onProfileChanged();
      }

      return true;
    } catch (_) {
      if (!mounted) {
        return false;
      }

      messenger.showSnackBar(SnackBar(content: Text(saveErrorMessage)));

      return false;
    }
  }

  Future<void> _openProfileSheet(
    BuildContext context,
    BodyProfile? profile,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _BodyProfileEntrySheet(
          initialHeightText: _formatInitialHeight(profile?.heightCm),
          initialFormula:
              profile?.bodyFatFormula ?? BodyFatFormula.usNavyFemale,
          onSave: ({required heightText, required bodyFatFormula}) {
            return _saveProfile(
              context,
              heightText: heightText,
              bodyFatFormula: bodyFatFormula,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<BodyProfile?>(
      future: _loadFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.accessibility_new_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.bodyProfileTitle,
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
                    _summaryText(l10n, profile),
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
                            _openProfileSheet(context, profile);
                          },
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(
                      profile == null
                          ? l10n.bodyProfileSetUpButton
                          : l10n.bodyProfileChangeButton,
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

  String _summaryText(AppLocalizations l10n, BodyProfile? profile) {
    if (profile == null) {
      return l10n.bodyProfileEmptyStatus;
    }

    return '${l10n.bodyProfileHeightLabel}: '
        '${_formatHeight(profile.heightCm)} ${l10n.bodyMeasurementsCmSuffix} · '
        '${l10n.bodyProfileFormulaLabel}: '
        '${_formulaLabel(l10n, profile.bodyFatFormula)}';
  }

  String _formulaLabel(AppLocalizations l10n, BodyFatFormula formula) {
    return switch (formula) {
      BodyFatFormula.usNavyFemale => l10n.bodyProfileFormulaUsNavyWithHips,
      BodyFatFormula.usNavyMale => l10n.bodyProfileFormulaUsNavyWaistOnly,
    };
  }

  double? _parseHeight(String rawValue) {
    final normalizedValue = rawValue.trim().replaceAll(',', '.');

    if (normalizedValue.isEmpty) {
      return null;
    }

    return double.tryParse(normalizedValue);
  }

  String _formatInitialHeight(double? value) {
    if (value == null) {
      return '';
    }

    return _formatHeight(value);
  }

  String _formatHeight(double value) {
    final fixed = value.toStringAsFixed(1);

    if (fixed.endsWith('.0')) {
      return value.toStringAsFixed(0);
    }

    return fixed;
  }
}

class _BodyProfileEntrySheet extends StatefulWidget {
  const _BodyProfileEntrySheet({
    required this.initialHeightText,
    required this.initialFormula,
    required this.onSave,
  });

  final String initialHeightText;
  final BodyFatFormula initialFormula;
  final Future<bool> Function({
    required String heightText,
    required BodyFatFormula bodyFatFormula,
  })
  onSave;

  @override
  State<_BodyProfileEntrySheet> createState() => _BodyProfileEntrySheetState();
}

class _BodyProfileEntrySheetState extends State<_BodyProfileEntrySheet> {
  late final TextEditingController _heightController;
  late BodyFatFormula _formula;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();

    _heightController = TextEditingController(text: widget.initialHeightText);
    _formula = widget.initialFormula;
  }

  @override
  void dispose() {
    _heightController.dispose();

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
      heightText: _heightController.text,
      bodyFatFormula: _formula,
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
              l10n.bodyProfileSheetTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.bodyProfileHeightLabel,
                suffixText: l10n.bodyMeasurementsCmSuffix,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BodyFatFormula>(
              initialValue: _formula,
              decoration: InputDecoration(
                labelText: l10n.bodyProfileFormulaLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: BodyFatFormula.usNavyFemale,
                  child: Text(l10n.bodyProfileFormulaUsNavyWithHips),
                ),
                DropdownMenuItem(
                  value: BodyFatFormula.usNavyMale,
                  child: Text(l10n.bodyProfileFormulaUsNavyWaistOnly),
                ),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) {
                      final selectedValue = value;

                      if (selectedValue == null) {
                        return;
                      }

                      setState(() {
                        _formula = selectedValue;
                      });
                    },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(l10n.bodyProfileSaveButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
