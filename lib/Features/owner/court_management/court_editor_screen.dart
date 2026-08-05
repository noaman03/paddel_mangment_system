import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_management_system/Features/owner/data/owner_models.dart';
import 'package:padel_management_system/Features/owner/data/owner_providers.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// Facilities offered by most clubs, so the owner taps instead of typing a
/// comma-separated string and hoping the parser agrees.
const List<String> kCourtFacilities = <String>[
  'Air Conditioning',
  'Professional Lighting',
  'Cafe',
  'Restaurant',
  'Parking',
  'Locker Rooms',
  'Changing Rooms',
  'Reception',
  'Pro Shop',
  'Seating Area',
  'Swimming Pool',
  'Free Wi-Fi',
];

/// Create / edit form for a court, matching the tournament editor.
class CourtEditorScreen extends ConsumerStatefulWidget {
  const CourtEditorScreen({super.key, this.court});

  /// `null` creates a new court.
  final OwnerCourt? court;

  @override
  ConsumerState<CourtEditorScreen> createState() => _CourtEditorScreenState();
}

class _CourtEditorScreenState extends ConsumerState<CourtEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _facilityController;

  late List<String> _facilities;
  late bool _isActive;
  bool _submitted = false;

  bool get _isEditing => widget.court != null;

  @override
  void initState() {
    super.initState();
    final court = widget.court;
    _nameController = TextEditingController(text: court?.name ?? '');
    _locationController = TextEditingController(text: court?.location ?? '');
    _priceController = TextEditingController(
      text: court == null ? '' : _plain(court.pricePerHour),
    );
    _descriptionController =
        TextEditingController(text: court?.description ?? '');
    _facilityController = TextEditingController();
    _facilities = List<String>.from(court?.facilities ?? const <String>[]);
    _isActive = court?.isActive ?? true;
  }

  static String _plain(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _facilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final options = <String>{...kCourtFacilities, ..._facilities}.toList();

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit court' : 'New court'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete court',
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
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: 'Court name',
                hintText: 'e.g. Al Noor Padel Club',
                prefixIcon: Icon(Icons.business_outlined),
                counterText: '',
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Give the court a name';
                if (text.length < 3) return 'Use at least 3 characters';
                return null;
              },
            ),
            const SizedBox(height: ASizes.md),
            TextFormField(
              controller: _locationController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'District or city',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'Players need to know where it is'
                  : null,
            ),
            const SizedBox(height: ASizes.md),
            TextFormField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Price per hour (EGP)',
                hintText: '250',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (value) {
                final parsed = double.tryParse(value?.trim() ?? '');
                if (parsed == null) return 'Enter an hourly price';
                if (parsed <= 0) return 'Price must be greater than zero';
                if (parsed > 20000) return 'That looks too high';
                return null;
              },
            ),
            const SizedBox(height: ASizes.md),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Surface, lighting, what makes it worth booking…',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Describe the court';
                if (text.length < 20) {
                  return 'Add a little more detail (at least 20 characters)';
                }
                return null;
              },
            ),
            const SizedBox(height: ASizes.sm),
            Text(
              'Facilities',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              'Tap what this court offers — these show as chips on the card.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: ASizes.sm + 2),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final facility in options)
                  FilterChip(
                    label: Text(facility),
                    selected: _facilities.contains(facility),
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _facilities.contains(facility)
                          ? AColors.foregroundOn(AColors.primaryDeep)
                          : c.textPrimary,
                    ),
                    // The accent green is too light to carry the label; the
                    // deep brand fill is the one that does.
                    selectedColor: AColors.primaryDeep,
                    backgroundColor: c.fill,
                    checkmarkColor: AColors.foregroundOn(AColors.primaryDeep),
                    side: BorderSide(color: c.border),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _facilities = <String>[..._facilities, facility];
                      } else {
                        _facilities =
                            _facilities.where((f) => f != facility).toList();
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: ASizes.sm + 4),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _facilityController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Add another facility',
                      hintText: 'e.g. Padel academy',
                      prefixIcon: Icon(Icons.add_circle_outline_rounded),
                    ),
                    onFieldSubmitted: (_) => _addFacility(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  tooltip: 'Add facility',
                  onPressed: _addFacility,
                  icon: const Icon(Icons.check_rounded),
                ),
              ],
            ),
            const SizedBox(height: ASizes.md),
            SwitchListTile.adaptive(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text(
                'Accepting bookings',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                _isActive
                    ? 'Players can find and book this court.'
                    : 'Hidden from players until you switch it back on.',
                style: TextStyle(color: c.textSecondary, fontSize: 12.5),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
                  onPressed: () => Navigator.of(context).maybePop(),
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
                  onPressed: _save,
                  icon: Icon(
                    _isEditing ? Icons.save_rounded : Icons.add_rounded,
                    size: 20,
                  ),
                  label: Text(_isEditing ? 'Save changes' : 'Add court'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addFacility() {
    final value = _facilityController.text.trim();
    if (value.isEmpty) {
      AppFeedback.info('Nothing to add', 'Type a facility name first.');
      return;
    }
    if (_facilities.any((f) => f.toLowerCase() == value.toLowerCase())) {
      AppFeedback.warning('Already listed', '$value is already on this court.');
      return;
    }
    setState(() {
      _facilities = <String>[..._facilities, value];
      _facilityController.clear();
    });
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

    final notifier = ref.read(ownerCourtsProvider.notifier);
    final name = _nameController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final existing = widget.court;

    if (existing == null) {
      notifier.add(
        OwnerCourt(
          id: 'court-${DateTime.now().microsecondsSinceEpoch}',
          name: name,
          location: _locationController.text.trim(),
          pricePerHour: price,
          description: _descriptionController.text.trim(),
          facilities: _facilities,
          images: const <String>[],
          isActive: _isActive,
        ),
      );
    } else {
      notifier.update(
        existing.copyWith(
          name: name,
          location: _locationController.text.trim(),
          pricePerHour: price,
          description: _descriptionController.text.trim(),
          facilities: _facilities,
          isActive: _isActive,
        ),
      );
    }

    Navigator.of(context).pop(true);
    AppFeedback.success(
      existing == null ? 'Court added' : 'Court updated',
      existing == null
          ? '$name is now listed. Add photos to finish the profile.'
          : '$name has been updated.',
    );
  }

  Future<void> _confirmDelete() async {
    final court = widget.court;
    if (court == null) return;

    final ok = await AppFeedback.confirm(
      context,
      title: 'Delete ${court.name}?',
      message: 'The court, its photos and its schedule are removed from the '
          'player app.',
      confirmLabel: 'Delete',
      icon: Icons.delete_forever_rounded,
      destructive: true,
    );
    if (!ok || !mounted) return;

    ref.read(ownerCourtsProvider.notifier).remove(court.id);
    Navigator.of(context).pop(true);
    AppFeedback.success('Court deleted', '${court.name} was removed.');
  }
}
