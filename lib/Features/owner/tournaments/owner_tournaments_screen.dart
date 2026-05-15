import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padelsystem/core/const/colors.dart';

class OwnerTournamentsScreen extends ConsumerStatefulWidget {
  const OwnerTournamentsScreen({super.key});

  @override
  ConsumerState<OwnerTournamentsScreen> createState() =>
      _OwnerTournamentsScreenState();
}

class _OwnerTournamentsScreenState
    extends ConsumerState<OwnerTournamentsScreen> {
  late List<OwnerTournament> _tournaments;

  @override
  void initState() {
    super.initState();
    _tournaments = _getDummyTournaments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with create button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tournaments',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                    onPressed: _showCreateTournamentDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tabs
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: AColors.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AColors.primaryColor,
                    tabs: const [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      children: [
                        // Upcoming tournaments
                        _tournaments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.event,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No tournaments yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _tournaments.length,
                                itemBuilder: (context, index) {
                                  return _buildTournamentCard(
                                    context,
                                    _tournaments[index],
                                    index,
                                  );
                                },
                              ),
                        // Completed tournaments
                        Center(
                          child: Text(
                            'No completed tournaments',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentCard(
    BuildContext context,
    OwnerTournament tournament,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Tournament Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AColors.primaryColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AColors.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.sports_tennis,
                    color: AColors.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        tournament.type,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(tournament.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tournament.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tournament Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic info
                _buildDetailRow(
                  Icons.calendar_today,
                  'Date',
                  tournament.date,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.access_time,
                  'Duration',
                  tournament.duration,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.people,
                  'Teams Registered',
                  '${tournament.teamsRegistered}/${tournament.maxTeams}',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.location_on,
                  'Court',
                  tournament.courtName,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Description',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  tournament.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Prize
                if (tournament.prizePool != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.card_giftcard,
                            color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Prize Pool: \$${tournament.prizePool}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Managing tournament...'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.manage_accounts),
                        label: const Text('Manage'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditTournamentDialog(tournament),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _tournaments.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void _showCreateTournamentDialog() {
    _showTournamentDialog(null);
  }

  void _showEditTournamentDialog(OwnerTournament tournament) {
    _showTournamentDialog(tournament);
  }

  void _showTournamentDialog(OwnerTournament? tournament) {
    final nameController = TextEditingController(text: tournament?.name ?? '');
    final typeController = TextEditingController(text: tournament?.type ?? '');
    final courtController =
        TextEditingController(text: tournament?.courtName ?? '');
    final dateController = TextEditingController(text: tournament?.date ?? '');
    final durationController =
        TextEditingController(text: tournament?.duration ?? '');
    final descriptionController =
        TextEditingController(text: tournament?.description ?? '');
    final maxTeamsController = TextEditingController(
      text: tournament?.maxTeams.toString() ?? '8',
    );
    final prizeController =
        TextEditingController(text: tournament?.prizePool?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              tournament == null ? 'Create Tournament' : 'Edit Tournament'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tournament Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Type (Singles/Doubles)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courtController,
                  decoration: const InputDecoration(
                    labelText: 'Court Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: maxTeamsController,
                  decoration: const InputDecoration(
                    labelText: 'Max Teams',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: prizeController,
                  decoration: const InputDecoration(
                    labelText: 'Prize Pool (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tournament == null) {
                  setState(() {
                    _tournaments.add(
                      OwnerTournament(
                        id: DateTime.now().toString(),
                        name: nameController.text,
                        type: typeController.text,
                        courtName: courtController.text,
                        date: dateController.text,
                        duration: durationController.text,
                        maxTeams: int.tryParse(maxTeamsController.text) ?? 8,
                        teamsRegistered: 0,
                        description: descriptionController.text,
                        prizePool: double.tryParse(prizeController.text),
                        status: 'Upcoming',
                      ),
                    );
                  });
                } else {
                  // Edit existing
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AColors.primaryColor,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Ongoing':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<OwnerTournament> _getDummyTournaments() {
    return [
      OwnerTournament(
        id: '1',
        name: 'Spring Championship 2025',
        type: 'Doubles',
        courtName: 'Al Noor Padel Club',
        date: 'March 15 - 22, 2025',
        duration: '8 days',
        maxTeams: 16,
        teamsRegistered: 14,
        description:
            'Grand spring tournament with exciting prizes and matches. Open for registration to all levels.',
        prizePool: 25000,
        status: 'Upcoming',
      ),
      OwnerTournament(
        id: '2',
        name: 'Weekend Warriors Cup',
        type: 'Mixed Doubles',
        courtName: 'Al Ahmar Padel Club',
        date: 'January 25 - 26, 2025',
        duration: '2 days',
        maxTeams: 12,
        teamsRegistered: 10,
        description:
            'Casual and fun weekend tournament for all skill levels. Great atmosphere and celebration.',
        prizePool: 8000,
        status: 'Upcoming',
      ),
      OwnerTournament(
        id: '3',
        name: 'Summer Grand Tournament',
        type: 'Singles',
        courtName: 'Athletes Club',
        date: 'July 1 - 15, 2025',
        duration: '15 days',
        maxTeams: 24,
        teamsRegistered: 20,
        description:
            'Largest singles tournament of the season with valuable prizes and media coverage.',
        prizePool: 50000,
        status: 'Upcoming',
      ),
      OwnerTournament(
        id: '4',
        name: 'Winter Championship',
        type: 'Doubles',
        courtName: 'Alexandria Courts',
        date: 'December 1 - 10, 2024',
        duration: '10 days',
        maxTeams: 16,
        teamsRegistered: 16,
        description: 'بطولة شتوية بأجواء ممتازة على ساحل البحر المتوسط.',
        prizePool: 35000,
        status: 'Completed',
      ),
    ];
  }
}

class OwnerTournament {
  final String id;
  final String name;
  final String type;
  final String courtName;
  final String date;
  final String duration;
  final int maxTeams;
  final int teamsRegistered;
  final String description;
  final double? prizePool;
  final String status;

  OwnerTournament({
    required this.id,
    required this.name,
    required this.type,
    required this.courtName,
    required this.date,
    required this.duration,
    required this.maxTeams,
    required this.teamsRegistered,
    required this.description,
    this.prizePool,
    required this.status,
  });
}
