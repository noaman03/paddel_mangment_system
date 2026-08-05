import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/match_form_fields.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/text_strings.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// The "Create Match" form.
///
/// This used to be a stateless mock-up: no [Form], no controllers, no
/// validation, inert date/time icons and a submit button wired to a no-op.
class CreateMatchTab extends StatefulWidget {
  const CreateMatchTab({super.key, required this.onCreated});

  /// Called after a match is published so the screen can jump back to the
  /// "Open Matches" tab, where the new card is now at the top.
  final VoidCallback onCreated;

  @override
  State<CreateMatchTab> createState() => _CreateMatchTabState();
}

class _CreateMatchTabState extends State<CreateMatchTab> {
  final _formKey = GlobalKey<FormState>();
  final OpenMatchesController controller = Get.find<OpenMatchesController>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _priceController = TextEditingController(text: '40');

  late String _courtName = controller.courts.first['name']!;
  late String _duration = controller.durations[1];
  String _skillLevel = 'Intermediate';
  String _matchType = 'Doubles';
  int _playersNeeded = 2;

  DateTime? _date;
  TimeOfDay? _time;

  /// Singles is a 2-player format, so at most one slot can be open.
  int get _maxPlayersNeeded => _matchType == 'Singles' ? 1 : 3;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Match date',
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = DateFormat('EEE, MMM dd, yyyy').format(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
      helpText: 'Start time',
    );
    if (picked == null) return;
    setState(() {
      _time = picked;
      _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  void _submit() {
    ADeviceutils.hideKeyboard(context);

    if (!_formKey.currentState!.validate()) {
      AppFeedback.warning(
        'Check the form',
        'Some required details are still missing.',
      );
      return;
    }

    final court = controller.courts.firstWhere(
      (c) => c['name'] == _courtName,
      orElse: () => controller.courts.first,
    );

    final match = controller.createMatch(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      courtName: court['name']!,
      location: court['location']!,
      date: _date!,
      time: _timeController.text,
      duration: _duration,
      playersNeeded: _playersNeeded,
      skillLevel: _skillLevel,
      matchType: _matchType,
      price: int.parse(_priceController.text.trim()),
    );

    _resetForm();

    AppFeedback.success(
      'Match published',
      '"${match['title']}" is now live in Open Matches.',
    );

    widget.onCreated();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _dateController.clear();
    _timeController.clear();
    _priceController.text = '40';
    setState(() {
      _date = null;
      _time = null;
      _courtName = controller.courts.first['name']!;
      _duration = controller.durations[1];
      _skillLevel = 'Intermediate';
      _matchType = 'Doubles';
      _playersNeeded = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: ASizes.paddingSm,
          bottom: ASizes.paddingLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(ASizes.paddingMd),
              margin: const EdgeInsets.only(bottom: ASizes.spaceBtwItems),
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
                border: Border.all(
                  color: AColors.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: c.brandText,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create a new match',
                          style: text.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Other players will be able to find and join it.',
                          style:
                              text.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            MatchFormField(
              label: 'Match Title',
              hint: 'e.g. Evening Doubles Match',
              controller: _titleController,
              validator: (value) => (value == null || value.trim().length < 3)
                  ? 'Give your match a title of at least 3 characters'
                  : null,
            ),
            MatchFormField(
              label: 'Description',
              hint: 'Describe your match and who you are looking for',
              controller: _descriptionController,
              maxLines: 3,
              validator: (value) => (value == null || value.trim().length < 10)
                  ? 'Add a short description (at least 10 characters)'
                  : null,
            ),
            MatchDropdownField(
              label: 'Court',
              value: _courtName,
              icon: Icons.place_rounded,
              items: controller.courts.map((c) => c['name']!).toList(),
              onChanged: (value) => setState(() => _courtName = value),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MatchFormField(
                    label: 'Date',
                    hint: 'Select date',
                    controller: _dateController,
                    suffixIcon: Icons.calendar_today_rounded,
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (_) => _date == null ? 'Pick a date' : null,
                  ),
                ),
                const SizedBox(width: ASizes.paddingSm),
                Expanded(
                  child: MatchFormField(
                    label: 'Time',
                    hint: 'Select time',
                    controller: _timeController,
                    suffixIcon: Icons.access_time_rounded,
                    readOnly: true,
                    onTap: _pickTime,
                    validator: (_) => _time == null ? 'Pick a time' : null,
                  ),
                ),
              ],
            ),
            MatchDropdownField(
              label: 'Duration',
              value: _duration,
              icon: Icons.timelapse_rounded,
              items: controller.durations,
              onChanged: (value) => setState(() => _duration = value),
            ),
            MatchStepperField(
              label: 'Players Needed',
              helper: _playersNeeded == 1
                  ? 'slot open besides you'
                  : 'slots open besides you',
              value: _playersNeeded,
              min: 1,
              max: _maxPlayersNeeded,
              onChanged: (value) => setState(() => _playersNeeded = value),
            ),
            MatchDropdownField(
              label: 'Skill Level',
              value: _skillLevel,
              icon: Icons.bar_chart_rounded,
              items: controller.skillLevels.skip(1).toList(),
              onChanged: (value) => setState(() => _skillLevel = value),
            ),
            MatchDropdownField(
              label: 'Match Type',
              value: _matchType,
              icon: Icons.style_rounded,
              items: controller.matchTypes.skip(1).toList(),
              onChanged: (value) => setState(() {
                _matchType = value;
                // Switching to Singles shrinks the format to two players.
                if (_playersNeeded > _maxPlayersNeeded) {
                  _playersNeeded = _maxPlayersNeeded;
                }
              }),
            ),
            MatchFormField(
              label: 'Price per player',
              hint: 'e.g. 40',
              controller: _priceController,
              keyboardType: TextInputType.number,
              suffixIcon: Icons.payments_rounded,
              validator: (value) {
                final price = int.tryParse((value ?? '').trim());
                if (price == null) return 'Enter the price as a whole number';
                if (price <= 0 || price > 1000) {
                  return 'Enter a price between 1 and 1000';
                }
                return null;
              },
            ),
            const SizedBox(height: ASizes.paddingSm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _resetForm();
                      AppFeedback.info('Form cleared', 'Start over any time.');
                    },
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: c.border),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ASizes.borderRadiusLg),
                      ),
                    ),
                    label: Text(
                      'Reset',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ASizes.paddingSm),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    style: ElevatedButton.styleFrom(
                      // The vivid accent cannot carry white text (1.91:1).
                      backgroundColor: AColors.primaryDeep,
                      foregroundColor:
                          AColors.foregroundOn(AColors.primaryDeep),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ASizes.borderRadiusLg),
                      ),
                    ),
                    label: const Text(
                      'Create Match',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: ASizes.fontSizeMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
