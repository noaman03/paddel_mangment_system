import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

/// The four password rules shown under the signup password field.
///
/// Pass [password] (e.g. from the form's `onChanged`) to get live ticks as
/// each rule is satisfied; leave it null for the static reference list.
class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({super.key, this.password});

  /// The password currently typed, or null when the caller has nothing to
  /// report yet.
  final String? password;

  static final List<_PasswordRule> _rules = <_PasswordRule>[
    _PasswordRule('At least 8 characters', (v) => v.length >= 8),
    _PasswordRule(
        'One uppercase letter (A-Z)', (v) => v.contains(RegExp('[A-Z]'))),
    _PasswordRule(
        'One lowercase letter (a-z)', (v) => v.contains(RegExp('[a-z]'))),
    _PasswordRule('One number (0-9)', (v) => v.contains(RegExp('[0-9]'))),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    final String? value = password;
    final bool live = value != null && value.isNotEmpty;
    final int met = live ? _rules.where((r) => r.isSatisfied(value)).length : 0;
    final bool allMet = live && met == _rules.length;

    final Color accent = allMet ? AColors.success : AColors.primaryColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allMet ? Icons.verified_rounded : Icons.info_outline,
                size: 16,
                // The accent is only ever used for the icon and the ticks —
                // #1DD681 on a near-white card is ~1.8:1 and was unreadable as
                // body text.
                color: c.onSurfaceAccent(accent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  allMet ? 'Password looks good' : 'Password requirements',
                  style: text.labelLarge?.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (live)
                Text(
                  '$met/${_rules.length}',
                  style: text.labelSmall?.copyWith(
                    color: c.onSurfaceAccent(accent),
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (final rule in _rules)
            _RequirementRow(
              label: rule.label,
              satisfied: live && rule.isSatisfied(value),
              live: live,
            ),
        ],
      ),
    );
  }
}

class _PasswordRule {
  const _PasswordRule(this.label, this.isSatisfied);

  final String label;
  final bool Function(String value) isSatisfied;
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.label,
    required this.satisfied,
    required this.live,
  });

  final String label;
  final bool satisfied;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    final Color markColor = satisfied
        ? c.onSurfaceAccent(AColors.success)
        : (live ? c.textMuted : c.onSurfaceAccent(AColors.primaryColor));

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                satisfied
                    ? Icons.check_circle_rounded
                    : (live ? Icons.radio_button_unchecked : Icons.circle),
                key: ValueKey<bool>(satisfied),
                size: satisfied || live ? 15 : 6,
                color: markColor,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: text.bodySmall?.copyWith(
                color: satisfied
                    ? c.onSurfaceAccent(AColors.success)
                    : c.textSecondary,
                fontWeight: satisfied ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
