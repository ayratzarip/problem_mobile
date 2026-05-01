import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/bottom_primary_button.dart';
import '../domain/problem_entry.dart';
import 'entries_state_scope.dart';

class EditEntryScreen extends StatefulWidget {
  const EditEntryScreen({required this.entryId, super.key});

  final String entryId;

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final _situationController = TextEditingController();
  final _thoughtsController = TextEditingController();
  final _bodyFeelingsController = TextEditingController();
  final _consequencesController = TextEditingController();
  final _withoutProblemController = TextEditingController();

  ProblemEntry? _originalEntry;
  DateTime? _createdAt;
  bool _hasChanges = false;
  bool _isSaving = false;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final state = EntriesStateScope.of(context);
      _originalEntry = _findEntry(state.entries);
      final found = state.loadEntryForEditing(widget.entryId);
      if (found && _originalEntry != null) {
        _createdAt = _originalEntry!.createdAt;
        _syncControllersFromDraft();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _situationController.dispose();
    _thoughtsController.dispose();
    _bodyFeelingsController.dispose();
    _consequencesController.dispose();
    _withoutProblemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = EntriesStateScope.of(context);

    return PopScope(
      canPop: _isExiting || !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          state.resetDraft();
          return;
        }
        await _handleBack();
      },
      child: AppScaffold(
        title: 'Редактирование',
        leading: BackButton(onPressed: _handleBack),
        body: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            16,
            AppSpacing.screenPadding,
            AppSpacing.listBottomPaddingSingleCta,
          ),
          children: [
            if (state.editingEntryId == null)
              const _EntryNotFound()
            else
              _EditForm(
                createdAt: _createdAt,
                situationController: _situationController,
                thoughtsController: _thoughtsController,
                bodyFeelingsController: _bodyFeelingsController,
                consequencesController: _consequencesController,
                withoutProblemController: _withoutProblemController,
                bodyZones: state.draft.bodyZones,
                onPickDateTime: _pickDateTime,
                onChanged: _handleFieldChanged,
              ),
          ],
        ),
        bottomBar: BottomPrimaryButton(
          label: _isSaving ? 'Сохранение...' : 'Сохранить изменения',
          onPressed: state.editingEntryId == null || _isSaving
              ? null
              : _handleSave,
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      await EntriesStateScope.of(
        context,
      ).updateEditingEntry(createdAt: _createdAt);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Изменения сохранены')));
    Navigator.of(context).pop();
  }

  Future<void> _handleBack() async {
    HapticFeedback.lightImpact();
    if (_hasChanges) {
      final shouldExit = await _confirmExitWithoutSaving();
      if (!shouldExit || !mounted) {
        return;
      }
      setState(() => _isExiting = true);
      EntriesStateScope.of(context).resetDraft();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      return;
    }

    setState(() => _isExiting = true);
    EntriesStateScope.of(context).resetDraft();
    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  void _syncControllersFromDraft() {
    final draft = EntriesStateScope.of(context).draft;
    _situationController.text = draft.situation;
    _thoughtsController.text = draft.thoughts;
    _bodyFeelingsController.text = draft.bodyFeelings;
    _consequencesController.text = draft.consequences;
    _withoutProblemController.text = draft.withoutProblem;
    _hasChanges = false;
  }

  void _handleFieldChanged() {
    final state = EntriesStateScope.of(context);
    state.updateDraft(
      situation: _situationController.text,
      thoughts: _thoughtsController.text,
      bodyFeelings: _bodyFeelingsController.text,
      consequences: _consequencesController.text,
      withoutProblem: _withoutProblemController.text,
    );
    _updateHasChanges();
  }

  void _updateHasChanges() {
    final original = _originalEntry;
    if (original == null) {
      return;
    }

    final hasChanges =
        _situationController.text != original.situation ||
        _thoughtsController.text != original.thoughts ||
        _bodyFeelingsController.text != original.bodyFeelings ||
        _consequencesController.text != original.consequences ||
        _withoutProblemController.text != original.withoutProblem ||
        _createdAt != original.createdAt;

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  Future<void> _pickDateTime() async {
    final initialDate = _createdAt ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (pickedTime == null || !mounted) {
      return;
    }

    setState(() {
      _createdAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
    _updateHasChanges();
  }

  Future<bool> _confirmExitWithoutSaving() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти без сохранения изменений?'),
        content: const Text('Несохранённые правки будут потеряны.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Остаться'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  ProblemEntry? _findEntry(List<ProblemEntry> entries) {
    for (final entry in entries) {
      if (entry.id == widget.entryId) {
        return entry;
      }
    }
    return null;
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({
    required this.createdAt,
    required this.situationController,
    required this.thoughtsController,
    required this.bodyFeelingsController,
    required this.consequencesController,
    required this.withoutProblemController,
    required this.bodyZones,
    required this.onPickDateTime,
    required this.onChanged,
  });

  final DateTime? createdAt;
  final TextEditingController situationController;
  final TextEditingController thoughtsController;
  final TextEditingController bodyFeelingsController;
  final TextEditingController consequencesController;
  final TextEditingController withoutProblemController;
  final List<String> bodyZones;
  final VoidCallback onPickDateTime;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Column(
          children: [
            _DateTimeSection(value: createdAt, onTap: onPickDateTime),
            _EditTextSection(
              label: 'Ситуация',
              controller: situationController,
              hintText: 'Опишите факты. Что происходит?..',
              onChanged: onChanged,
            ),
            _EditTextSection(
              label: 'Мысли',
              controller: thoughtsController,
              hintText: 'О чем думаете...',
              onChanged: onChanged,
            ),
            _EditTextSection(
              label: 'Телесные ощущения',
              controller: bodyFeelingsController,
              hintText: 'Ощущения в теле, тонус мышц...',
              onChanged: onChanged,
            ),
            if (bodyZones.isNotEmpty)
              _ReadOnlySection(
                label: 'Части тела',
                value: bodyZones.join(', '),
              ),
            _EditTextSection(
              label: 'Последствия',
              controller: consequencesController,
              hintText: 'Потеря времени или препятствие к действию...',
              onChanged: onChanged,
            ),
            _EditTextSection(
              label: 'Без проблемы',
              controller: withoutProblemController,
              hintText: 'Что бы вы делали, если бы не эта проблема...',
              onChanged: onChanged,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeSection extends StatelessWidget {
  const _DateTimeSection({required this.value, required this.onTap});

  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(label: 'Дата и время'),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null
                        ? 'Выберите дату и время'
                        : _formatDateTime(value!),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_month_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        const _SectionDivider(),
      ],
    );
  }
}

class _EditTextSection extends StatelessWidget {
  const _EditTextSection({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.isLast = false,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: label),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 7,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => onChanged(),
          ),
        ),
        if (!isLast) const _SectionDivider(),
      ],
    );
  }
}

class _ReadOnlySection extends StatelessWidget {
  const _ReadOnlySection({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: label),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const _SectionDivider(),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _EntryNotFound extends StatelessWidget {
  const _EntryNotFound();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Запись не найдена', textAlign: TextAlign.center),
      ),
    );
  }
}

String _formatDateTime(DateTime date) {
  final day = date.day;
  final month = _shortMonths[date.month - 1];
  final year = date.year;
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day $month $year г., $hour:$minute';
}

const _shortMonths = [
  'янв.',
  'февр.',
  'марта',
  'апр.',
  'мая',
  'июня',
  'июля',
  'авг.',
  'сент.',
  'окт.',
  'нояб.',
  'дек.',
];
