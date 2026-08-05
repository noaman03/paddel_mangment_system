import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_management_system/Features/owner/data/owner_models.dart';
import 'package:padel_management_system/Features/owner/data/owner_providers.dart';
import 'package:padel_management_system/Features/owner/tournaments/tournament_editor_screen.dart';
import 'package:padel_management_system/Features/owner/widgets/owner_widgets.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';
import 'package:padel_management_system/core/widgets/player_screen_components.dart';

/// Opens the create / edit form. Used by the tournaments tab and by the
/// dashboard quick action, which both write to the same provider.
Future<void> openTournamentEditor(
  BuildContext context, {
  OwnerTournament? tournament,
}) async {
  await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => TournamentEditorScreen(tournament: tournament),
    ),
  );
}

/// The owner's tournament list.
///
/// It is normally embedded in [OwnerDashboard]'s Scaffold, so it deliberately
/// does not build one of its own (a nested Scaffold swallowed the app bar and
/// left pushed copies with no way back). Pass `embedded: false` to push it as a
/// standalone route.
class OwnerTournamentsScreen extends ConsumerStatefulWidget {
  const OwnerTournamentsScreen({super.key, this.embedded = true});

  final bool embedded;

  @override
  ConsumerState<OwnerTournamentsScreen> createState() =>
      _OwnerTournamentsScreenState();
}

class _OwnerTournamentsScreenState extends ConsumerState<OwnerTournamentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(ownerTournamentsProvider);
    final active = tournaments.where((t) => t.status.isLive).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final archive = tournaments.where((t) => !t.status.isLive).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ASizes.md,
            ASizes.md,
            ASizes.md,
            ASizes.sm,
          ),
          child: OwnerSectionHeader(
            title: 'Tournaments',
            subtitle: tournaments.isEmpty
                ? 'Nothing scheduled yet'
                : '${active.length} running or upcoming · '
                    '${archive.length} archived',
            // The title used to sit next to a hard-coded 150px button, which
            // overflowed on narrow screens and at large text scales.
            trailing: ElevatedButton.icon(
              onPressed: () => openTournamentEditor(context),
              icon: const Icon(Icons.add_rounded, size: 19),
              label: const Text('New'),
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ASizes.md),
          // Same segmented pill the player screens use, so the two halves of
          // the app read as one product.
          child: PlayerTabBar(
            controller: _tabController,
            tabs: <String>[
              'Active (${active.length})',
              'Archive (${archive.length})'
            ],
            icons: const <IconData>[
              Icons.local_fire_department_rounded,
              Icons.inventory_2_rounded,
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _TournamentList(
                tournaments: active,
                emptyIcon: Icons.event_available_outlined,
                emptyTitle: 'No tournaments scheduled',
                emptyMessage:
                    'Create one and it will appear here and in the player '
                    'app straight away.',
                emptyAction: ElevatedButton.icon(
                  onPressed: () => openTournamentEditor(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create tournament'),
                ),
              ),
              _TournamentList(
                tournaments: archive,
                emptyIcon: Icons.inventory_2_outlined,
                emptyTitle: 'Nothing archived yet',
                emptyMessage:
                    'Completed and cancelled tournaments are kept here with '
                    'their final entry lists.',
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: context.padel.background,
      appBar: AppBar(title: const Text('Tournaments')),
      body: body,
    );
  }
}

class _TournamentList extends StatelessWidget {
  const _TournamentList({
    required this.tournaments,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    this.emptyAction,
  });

  final List<OwnerTournament> tournaments;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final Widget? emptyAction;

  @override
  Widget build(BuildContext context) {
    if (tournaments.isEmpty) {
      return OwnerEmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        message: emptyMessage,
        action: emptyAction,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        ASizes.md,
        ASizes.md,
        ASizes.md,
        ASizes.xl,
      ),
      itemCount: tournaments.length,
      itemBuilder: (context, index) =>
          _TournamentCard(tournament: tournaments[index]),
    );
  }
}

class _TournamentCard extends ConsumerWidget {
  const _TournamentCard({required this.tournament});

  final OwnerTournament tournament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.padel;
    final t = tournament;
    final Color statusColor = t.status.color;
    final double fill =
        t.maxTeams == 0 ? 0 : (t.teamsRegistered / t.maxTeams).clamp(0.0, 1.0);

    return OwnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.fromLTRB(ASizes.md, 12, 6, 12),
            color: c.primarySoft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sports_tennis_rounded,
                    color: c.brandText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${t.type} · ${t.courtName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                OwnerStatusPill(
                  label: t.status.label,
                  color: statusColor,
                  icon: t.status.icon,
                ),
                PopupMenuButton<String>(
                  tooltip: 'Tournament actions',
                  icon: Icon(Icons.more_vert_rounded, color: c.textSecondary),
                  onSelected: (value) => _onMenu(context, ref, value),
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit details'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'duplicate',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.copy_all_outlined),
                        title: Text('Duplicate'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_outline_rounded),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(ASizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OwnerDetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Dates',
                        value: t.dateLabel,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OwnerDetailRow(
                        icon: Icons.schedule_rounded,
                        label: 'Duration',
                        value: t.durationLabel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OwnerDetailRow(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Entry fee',
                        value: t.entryFeeLabel,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OwnerDetailRow(
                        icon: Icons.groups_rounded,
                        label: 'Teams',
                        value: '${t.teamsRegistered} / ${t.maxTeams}',
                        valueColor: t.isFull
                            ? c.onSurfaceAccent(AColors.warning)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fill,
                    minHeight: 6,
                    backgroundColor: c.surfaceElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      t.isFull ? AColors.warning : AColors.primaryColor,
                    ),
                  ),
                ),
                if (t.pendingTeams.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.mark_email_unread_outlined,
                        size: 15,
                        color: c.onSurfaceAccent(AColors.warning),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${t.pendingTeams.length} entry '
                          '${t.pendingTeams.length == 1 ? 'request' : 'requests'}'
                          ' waiting for you',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: c.onSurfaceAccent(AColors.warning),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (t.prizePool != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: c.soft(AColors.warning),
                      borderRadius:
                          BorderRadius.circular(ASizes.borderRadiusMd),
                      border: Border.all(
                        color: AColors.warning.withValues(alpha: 0.35),
                      ),
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
                            'Prize pool · ${t.prizeLabel}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              // Plain `Colors.amber` on an amber wash was ~1.9:1
                              // in light mode; this keeps it legible in both.
                              color: c.onSurfaceAccent(AColors.warning),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  t.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: c.textSecondary, height: 1.4),
                ),
                const SizedBox(height: ASizes.md),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: OwnerActionButton(
                        icon: Icons.tune_rounded,
                        label: 'Manage',
                        filled: true,
                        onPressed: () =>
                            showTournamentManager(context, t.id, t.name),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: OwnerActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        onPressed: () =>
                            openTournamentEditor(context, tournament: t),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    final notifier = ref.read(ownerTournamentsProvider.notifier);

    switch (value) {
      case 'edit':
        await openTournamentEditor(context, tournament: tournament);
      case 'duplicate':
        final name = '${tournament.name} (copy)';
        notifier.add(
          OwnerTournament(
            id: 'tour-${DateTime.now().microsecondsSinceEpoch}',
            name: name,
            type: tournament.type,
            courtName: tournament.courtName,
            startDate: tournament.startDate,
            endDate: tournament.endDate,
            maxTeams: tournament.maxTeams,
            description: tournament.description,
            status: TournamentStatus.upcoming,
            prizePool: tournament.prizePool,
            entryFee: tournament.entryFee,
          ),
        );
        AppFeedback.success(
          'Duplicated',
          '"$name" was created with an empty entry list.',
        );
      case 'delete':
        // Deleting used to happen on a single tap, by list index, with no
        // confirmation — on a filtered list that removed the wrong row.
        final ok = await AppFeedback.confirm(
          context,
          title: 'Delete ${tournament.name}?',
          message: tournament.teamsRegistered == 0
              ? 'This removes the tournament from the player app.'
              : '${tournament.teamsRegistered} registered teams will be '
                  'notified and refunded.',
          confirmLabel: 'Delete',
          icon: Icons.delete_forever_rounded,
          destructive: true,
        );
        if (!ok) return;
        notifier.remove(tournament.id);
        AppFeedback.success(
          'Tournament deleted',
          '${tournament.name} was removed.',
        );
    }
  }
}

/// The real "Manage" experience: change the status, accept or decline entry
/// requests and withdraw teams. The button used to show a fake
/// "Managing tournament..." snackbar and do nothing.
Future<void> showTournamentManager(
  BuildContext context,
  String tournamentId,
  String tournamentName,
) {
  return showAppSheet<void>(
    context,
    title: tournamentName,
    subtitle: 'Entries, requests and status',
    icon: Icons.tune_rounded,
    heightFactor: 0.88,
    child: _TournamentManagerBody(tournamentId: tournamentId),
  );
}

class _TournamentManagerBody extends ConsumerWidget {
  const _TournamentManagerBody({required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.padel;
    final tournaments = ref.watch(ownerTournamentsProvider);
    final matches = tournaments.where((t) => t.id == tournamentId);

    if (matches.isEmpty) {
      return const OwnerEmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Tournament removed',
        message: 'This tournament is no longer in your list.',
      );
    }

    final t = matches.first;
    final notifier = ref.read(ownerTournamentsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ASizes.md,
        ASizes.md,
        ASizes.md,
        ASizes.lg,
      ),
      children: [
        // Capacity summary
        Container(
          padding: const EdgeInsets.all(ASizes.md),
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ManagerStat(
                  label: 'Registered',
                  value: '${t.teamsRegistered}/${t.maxTeams}',
                ),
              ),
              Expanded(
                child: _ManagerStat(
                  label: 'Requests',
                  value: '${t.pendingTeams.length}',
                ),
              ),
              Expanded(
                child: _ManagerStat(label: 'Prize', value: t.prizeLabel),
              ),
            ],
          ),
        ),
        const SizedBox(height: ASizes.lg),

        Text(
          'Status',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final status in TournamentStatus.values)
              // The selected chip is filled with the status colour, so its
              // foreground has to be picked against that fill — white is only
              // 2.04:1 on the warning amber.
              ChoiceChip(
                selected: t.status == status,
                avatar: Icon(
                  status.icon,
                  size: 16,
                  color: t.status == status
                      ? c.foregroundOn(status.color)
                      : c.onSurfaceAccent(status.color),
                ),
                label: Text(status.label),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: t.status == status
                      ? c.foregroundOn(status.color)
                      : c.textPrimary,
                ),
                selectedColor: status.color,
                backgroundColor: c.soft(status.color),
                side: BorderSide(color: status.color.withValues(alpha: 0.35)),
                showCheckmark: false,
                onSelected: (_) {
                  if (t.status == status) return;
                  notifier.setStatus(t.id, status);
                  AppFeedback.info(
                    'Status updated',
                    '${t.name} is now ${status.label.toLowerCase()}.',
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: ASizes.lg),

        Text(
          'Entry requests (${t.pendingTeams.length})',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (t.pendingTeams.isEmpty)
          const _EmptyLine(
            icon: Icons.inbox_outlined,
            text: 'No requests waiting. New entries appear here.',
          )
        else
          for (final team in t.pendingTeams)
            _PendingTeamTile(
              team: team,
              onAccept: () {
                final accepted = notifier.acceptTeam(t.id, team);
                if (accepted) {
                  AppFeedback.success('$team accepted', 'Their place is held.');
                } else {
                  AppFeedback.warning(
                    'Tournament is full',
                    'Raise the team limit before accepting more entries.',
                  );
                }
              },
              onDecline: () {
                notifier.declineTeam(t.id, team);
                AppFeedback.info('$team declined', 'They have been notified.');
              },
            ),
        const SizedBox(height: ASizes.lg),

        Text(
          'Registered teams (${t.teamsRegistered})',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (t.teams.isEmpty)
          const _EmptyLine(
            icon: Icons.groups_outlined,
            text: 'Nobody has entered yet.',
          )
        else
          for (var i = 0; i < t.teams.length; i++)
            _RegisteredTeamTile(
              seed: i + 1,
              team: t.teams[i],
              onRemove: () async {
                final team = t.teams[i];
                final ok = await AppFeedback.confirm(
                  context,
                  title: 'Withdraw $team?',
                  message: 'They lose their place and their entry fee is '
                      'refunded.',
                  confirmLabel: 'Withdraw',
                  icon: Icons.person_remove_alt_1_rounded,
                  destructive: true,
                );
                if (!ok) return;
                notifier.withdrawTeam(t.id, team);
                AppFeedback.info('$team withdrawn', 'A place has opened up.');
              },
            ),
      ],
    );
  }
}

class _ManagerStat extends StatelessWidget {
  const _ManagerStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: c.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingTeamTile extends StatelessWidget {
  const _PendingTeamTile({
    required this.team,
    required this.onAccept,
    required this.onDecline,
  });

  final String team;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: c.soft(AColors.warning),
        borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
        border: Border.all(color: AColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_add_alt_1_rounded,
            size: 19,
            color: c.onSurfaceAccent(AColors.warning),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              team,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: c.textPrimary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Decline',
            onPressed: onDecline,
            icon: Icon(Icons.close_rounded, color: c.error),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Accept',
            onPressed: onAccept,
            icon: Icon(Icons.check_rounded, color: c.success),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _RegisteredTeamTile extends StatelessWidget {
  const _RegisteredTeamTile({
    required this.seed,
    required this.team,
    required this.onRemove,
  });

  final int seed;
  final String team;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              '$seed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: c.brandText,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              team,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: c.textPrimary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Withdraw team',
            onPressed: onRemove,
            icon: Icon(Icons.person_remove_outlined, color: c.textMuted),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
