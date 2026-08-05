import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/Features/owner/data/owner_models.dart';
import 'package:padel_management_system/Features/owner/data/owner_providers.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// Full-screen create / edit form for a tournament.
///
/// This replaces a cramped `AlertDialog` of eight bare `TextField`s that had no
/// validation, no date picker, leaked its controllers, and — worst of all —
/// whose edit branch was an empty `else { // Edit existing }`, so every edit an
/// owner made was silently discarded.
class TournamentEditorScreen extends ConsumerStatefulWidget {
  const TournamentEditorScreen({super.key, this.tournament});

  /// `null` creates a new tournament.
  final OwnerTournament? tournament;

  @override
  ConsumerState<TournamentEditorScreen> createState() =>
      _TournamentEditorScreenState();
}

class _TournamentEditorScreenState
    extends ConsumerState<TournamentEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _maxTeamsController;
  late final TextEditingController _entryFeeController;
  late final TextEditingController _prizeController;
  late final TextEditingController _dateController;

  String? _type;
  String? _courtName;
  late TournamentStatus _status;
  DateTimeRange? _range;
  bool _submitted = false;

  bool get _isEditing => widget.tournament != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tournament;

    _nameController = TextEditingController(text: t?.name ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _maxTeamsController =
        TextEditingController(text: (t?.maxTeams ?? 16).toString());
    _entryFeeController = TextEditingController(
      text: t == null ? '' : (t.entryFee == 0 ? '' : _plain(t.entryFee)),
    );
    _prizeController = TextEditingController(
      text: t?.prizePool == null ? '' : _plain(t!.prizePool!),
    );

    _type = t != null && kTournamentTypes.contains(t.type) ? t.type : null;
    _courtName = t?.courtName;
    _status = t?.status ?? TournamentStatus.upcoming;
    _range =
        t == null ? null : DateTimeRange(start: t.startDate, end: t.endDate);
    _dateController =
        TextEditingController(text: _range == null ? '' : t!.dateLabel);
  }

  static String _plain(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  @override
  void dispose() {
    // The old dialog built eight controllers inside `showDialog`'s builder and
    // never disposed any of them.
    _nameController.dispose();
    _descriptionController.dispose();
    _maxTeamsController.dispose();
    _entryFeeController.dispose();
    _prizeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final courts = ref.watch(ownerCourtsProvider);
    final courtNames = <String>{
      ...courts.map((court) => court.name),
      if (_courtName != null && _courtName!.isNotEmpty) _courtName!,
    }.toList()
      ..sort();

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit tournament' : 'New tournament'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete tournament',
              onPressed: _confirmDelete,
              icon: Icon(Icons.delete_outline_rounded, color: c.error),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            ASizes.md,
            ASizes.md,
            ASizes.md,
            ASizes.xl,
          ),
          children: [
            _Banner(isEditing: _isEditing),
            const SizedBox(height: ASizes.lg),
            const _SectionLabel(
              icon: Icons.emoji_events_outlined,
              title: 'Basics',
              subtitle: 'How the tournament is listed to players',
            ),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: 'Tournament name',
                hintText: 'e.g. Spring Championship',
                prefixIcon: Icon(Icons.title_rounded),
                counterText: '',
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Give the tournament a name';
                if (text.length < 4) return 'Use at least 4 characters';
                return null;
              },
            ),
            const SizedBox(height: ASizes.md),
            DropdownButtonFormField<String>(
              initialValue: _type,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Format',
                prefixIcon: Icon(Icons.groups_2_outlined),
              ),
              items: [
                for (final type in kTournamentTypes)
                  DropdownMenuItem<String>(value: type, child: Text(type)),
              ],
              onChanged: (value) => setState(() => _type = value),
              validator: (value) => value == null ? 'Pick a format' : null,
            ),
            const SizedBox(height: ASizes.md),
            if (courtNames.isEmpty)
              TextFormField(
                initialValue: _courtName,
                decoration: const InputDecoration(
                  labelText: 'Venue',
                  hintText: 'Where is it played?',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                onChanged: (value) => _courtName = value,
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'Add a venue' : null,
              )
            else
              DropdownButtonFormField<String>(
                initialValue:
                    courtNames.contains(_courtName) ? _courtName : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Venue',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                items: [
                  for (final name in courtNames)
                    DropdownMenuItem<String>(
                      value: name,
                      child: Text(name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) => setState(() => _courtName = value),
                validator: (value) =>
                    value == null ? 'Pick one of your courts' : null,
              ),
            const SizedBox(height: ASizes.lg),
            const _SectionLabel(
              icon: Icons.calendar_month_outlined,
              title: 'Schedule',
              subtitle: 'Duration is calculated from the dates you pick',
            ),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDates,
              decoration: InputDecoration(
                labelText: 'Dates',
                hintText: 'Tap to choose a date range',
                prefixIcon: const Icon(Icons.date_range_outlined),
                suffixIcon: const Icon(Icons.edit_calendar_outlined),
                helperText: _range == null
                    ? 'Start and end day of the tournament'
                    : 'Runs for ${_durationLabel(_range!)}',
              ),
              validator: (_) => _range == null ? 'Choose the dates' : null,
            ),
            if (_isEditing) ...[
              const SizedBox(height: ASizes.md),
              DropdownButtonFormField<TournamentStatus>(
                initialValue: _status,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: [
                  for (final status in TournamentStatus.values)
                    DropdownMenuItem<TournamentStatus>(
                      value: status,
                      child: Row(
                        children: [
                          Icon(status.icon, size: 17, color: status.color),
                          const SizedBox(width: 8),
                          Text(status.label),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _status = value ?? _status),
              ),
            ],
            const SizedBox(height: ASizes.lg),
            const _SectionLabel(
              icon: Icons.payments_outlined,
              title: 'Entries & money',
              subtitle: 'All amounts are in EGP',
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxTeamsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Max teams',
                      prefixIcon: Icon(Icons.groups_outlined),
                    ),
                    validator: _validateMaxTeams,
                  ),
                ),
                const SizedBox(width: ASizes.sm + 4),
                Expanded(
                  child: TextFormField(
                    controller: _entryFeeController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Entry fee',
                      hintText: '0',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                    validator: (value) =>
                        _validateAmount(value, 'entry fee', max: 100000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASizes.md),
            TextFormField(
              controller: _prizeController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Prize pool (optional)',
                hintText: 'Leave empty for a friendly tournament',
                prefixIcon: Icon(Icons.card_giftcard_outlined),
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) =>
                  _validateAmount(value, 'prize pool', max: 5000000),
            ),
            if (_prizePreview != null) ...[
              const SizedBox(height: ASizes.sm),
              _PrizePreview(amount: _prizePreview!),
            ],
            const SizedBox(height: ASizes.lg),
            const _SectionLabel(
              icon: Icons.notes_outlined,
              title: 'Details',
              subtitle: 'Shown to players on the tournament page',
            ),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 400,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText:
                    'Format, schedule, what players should bring, prizes…',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Describe the tournament';
                if (text.length < 20) {
                  return 'Add a little more detail (at least 20 characters)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _SaveBar(
        isEditing: _isEditing,
        onCancel: () => Navigator.of(context).maybePop(),
        onSave: _save,
      ),
    );
  }

  double? get _prizePreview {
    final value = double.tryParse(_prizeController.text.trim());
    if (value == null || value <= 0) return null;
    return value;
  }

  static String _durationLabel(DateTimeRange range) {
    final days = range.end.difference(range.start).inDays + 1;
    return days == 1 ? '1 day' : '$days days';
  }

  String? _validateMaxTeams(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) return 'Enter a number';
    if (parsed < 2 || parsed > 64) return 'Between 2 and 64 teams';
    final registered = widget.tournament?.teamsRegistered ?? 0;
    if (parsed < registered) {
      return '$registered teams are already registered';
    }
    return null;
  }

  String? _validateAmount(String? value, String field, {required double max}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null) return 'Enter a valid $field';
    if (parsed < 0) return 'Cannot be negative';
    if (parsed > max) return 'That looks too high';
    return null;
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _range,
      helpText: 'Tournament dates',
      saveText: 'Done',
    );
    if (!mounted || picked == null) return;
    setState(() {
      _range = picked;
      _dateController.text = _formatRange(picked);
    });
  }

  static String _formatRange(DateTimeRange range) {
    if (range.start.year == range.end.year &&
        range.start.month == range.end.month) {
      if (range.start.day == range.end.day) {
        return DateFormat('MMMM d, y').format(range.start);
      }
      return '${DateFormat('MMMM d').format(range.start)} – '
          '${range.end.day}, ${range.end.year}';
    }
    if (range.start.year == range.end.year) {
      return '${DateFormat('MMM d').format(range.start)} – '
          '${DateFormat('MMM d').format(range.end)}, ${range.end.year}';
    }
    return '${DateFormat('MMM d, y').format(range.start)} – '
        '${DateFormat('MMM d, y').format(range.end)}';
  }

  void _save() {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppFeedback.warning(
        'Almost there',
        'Fix the highlighted fields and try again.',
      );
      return;
    }

    final range = _range!;
    final notifier = ref.read(ownerTournamentsProvider.notifier);
    final prize = double.tryParse(_prizeController.text.trim());
    final entryFee = double.tryParse(_entryFeeController.text.trim()) ?? 0;
    final name = _nameController.text.trim();

    final existing = widget.tournament;
    if (existing == null) {
      notifier.add(
        OwnerTournament(
          id: 'tour-${DateTime.now().microsecondsSinceEpoch}',
          name: name,
          type: _type!,
          courtName: _courtName!.trim(),
          startDate: range.start,
          endDate: range.end,
          maxTeams: int.parse(_maxTeamsController.text.trim()),
          description: _descriptionController.text.trim(),
          status: TournamentStatus.upcoming,
          prizePool: (prize != null && prize > 0) ? prize : null,
          entryFee: entryFee,
        ),
      );
    } else {
      notifier.update(
        existing.copyWith(
          name: name,
          type: _type!,
          courtName: _courtName!.trim(),
          startDate: range.start,
          endDate: range.end,
          maxTeams: int.parse(_maxTeamsController.text.trim()),
          description: _descriptionController.text.trim(),
          status: _status,
          prizePool: (prize != null && prize > 0) ? prize : null,
          clearPrizePool: prize == null || prize <= 0,
          entryFee: entryFee,
        ),
      );
    }

    Navigator.of(context).pop(true);
    AppFeedback.success(
      existing == null ? 'Tournament created' : 'Changes saved',
      existing == null
          ? '$name is now listed for players.'
          : '$name has been updated.',
    );
  }

  Future<void> _confirmDelete() async {
    final tournament = widget.tournament;
    if (tournament == null) return;

    final ok = await AppFeedback.confirm(
      context,
      title: 'Delete ${tournament.name}?',
      message: tournament.teamsRegistered == 0
          ? 'This removes the tournament from the player app.'
          : '${tournament.teamsRegistered} registered teams will be notified '
              'and refunded.',
      confirmLabel: 'Delete',
      icon: Icons.delete_forever_rounded,
      destructive: true,
    );
    if (!ok || !mounted) return;

    ref.read(ownerTournamentsProvider.notifier).remove(tournament.id);
    Navigator.of(context).pop(true);
    AppFeedback.success(
        'Tournament deleted', '${tournament.name} was removed.');
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ASizes.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AColors.brandGradient,
        ),
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditing ? Icons.edit_note_rounded : Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: ASizes.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Update the details' : 'Set up a tournament',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isEditing
                      ? 'Registered teams keep their places when you save.'
                      : 'It appears in the player app as soon as you save.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Padding(
      padding: const EdgeInsets.only(bottom: ASizes.sm + 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: c.brandText),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrizePreview extends StatelessWidget {
  const _PrizePreview({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.soft(AColors.warning),
        borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
        border: Border.all(color: AColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 18,
            color: c.onSurfaceAccent(AColors.warning),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Players will see ${formatEgp(amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: c.onSurfaceAccent(AColors.warning),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.isEditing,
    required this.onCancel,
    required this.onSave,
  });

  final bool isEditing;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      padding: const EdgeInsets.fromLTRB(ASizes.md, 12, ASizes.md, 12),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                child: Text(
                  'Cancel',
                  style: TextStyle(color: c.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: Icon(
                  isEditing ? Icons.save_rounded : Icons.add_rounded,
                  size: 20,
                ),
                label: Text(isEditing ? 'Save changes' : 'Create tournament'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
