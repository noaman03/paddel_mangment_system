import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/Features/players/reservations/my_reservations_screen.dart';
import 'package:padelsystem/Features/players/court_details/court_details_screen.dart';
import 'package:padelsystem/Models/padel_court.dart';

class RecentReservationsWidget extends ConsumerStatefulWidget {
  const RecentReservationsWidget({super.key});

  @override
  ConsumerState<RecentReservationsWidget> createState() =>
      _RecentReservationsWidgetState();
}

class _RecentReservationsWidgetState
    extends ConsumerState<RecentReservationsWidget> {
  late List<RecentReservation> _reservations;

  @override
  void initState() {
    super.initState();
    _reservations = _getDummyReservations();
  }

  @override
  Widget build(BuildContext context) {
    bool dark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Reservations',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyReservationsScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: AColors.primaryColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Reservations List
        SizedBox(
          height: 320,
          child: _reservations.isEmpty
              ? Center(
                  child: Text(
                    'No recent reservations',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = _reservations[index];
                    return _buildReservationCard(context, reservation, dark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReservationCard(
      BuildContext context, RecentReservation reservation, bool dark) {
    return GestureDetector(
      onTap: () {
        // Create dummy court object and navigate to details screen
        final court = PadelCourt(
          id: reservation.id,
          name: reservation.courtName,
          location: reservation.location,
          description: 'Premium padel court with excellent facilities',
          pricePerHour: 250.0,
          photos: [reservation.courtImage],
          facilities: [
            'Air Conditioning',
            'Professional Lighting',
            'Cafe',
            'Parking'
          ],
          type: CourtType.indoor,
          rating: 4.8,
          totalBookings: 150,
          createdAt: DateTime.now(),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourtDetailsScreen(court: court),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: dark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
          border: Border.all(
            color: dark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court Image
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(ASizes.borderRadiusLg),
                ),
                color: Colors.grey[300],
                image: DecorationImage(
                  image: NetworkImage(reservation.courtImage),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
              ),
              child: reservation.courtImage.isEmpty
                  ? Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[600],
                      ),
                    )
                  : null,
            ),

            // Court Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(ASizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.courtName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ASizes.fontSizeSm,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : AColors.textprimary,
                      ),
                    ),
                    const SizedBox(height: ASizes.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: ASizes.xs),
                        Expanded(
                          child: Text(
                            reservation.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: dark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ASizes.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ASizes.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(reservation.status)
                            .withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(ASizes.borderRadiusSm),
                      ),
                      child: Text(
                        reservation.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(reservation.status),
                        ),
                      ),
                    ),
                    const SizedBox(height: ASizes.xs),
                    Text(
                      '${reservation.date} at ${reservation.time}',
                      style: TextStyle(
                        fontSize: 10,
                        color: dark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Rebook Button
            Padding(
              padding: const EdgeInsets.all(ASizes.sm),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Rebook court
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Rebooking court...'),
                        backgroundColor: AColors.primaryColor,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ASizes.borderRadiusMd),
                    ),
                  ),
                  child: const Text(
                    'Rebook',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'upcoming':
        return AColors.primaryColor;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<RecentReservation> _getDummyReservations() {
    return [
      RecentReservation(
        id: '1',
        courtName: 'Al Noor Club',
        location: 'Downtown Cairo',
        date: 'Jan 15, 2025',
        time: '5:00 PM',
        status: 'Completed',
        courtImage: 'https://via.placeholder.com/280x100?text=Al+Noor+Club',
      ),
      RecentReservation(
        id: '2',
        courtName: 'Al Ahmar Club',
        location: 'New Cairo',
        date: 'Jan 20, 2025',
        time: '6:00 PM',
        status: 'Upcoming',
        courtImage: 'https://via.placeholder.com/280x100?text=Al+Ahmar+Club',
      ),
      RecentReservation(
        id: '3',
        courtName: 'Athletes Club',
        location: 'Giza',
        date: 'Jan 10, 2025',
        time: '4:00 PM',
        status: 'Completed',
        courtImage: 'https://via.placeholder.com/280x100?text=Athletes+Club',
      ),
      RecentReservation(
        id: '4',
        courtName: 'Alexandria Courts',
        location: 'Alexandria',
        date: 'Jan 5, 2025',
        time: '7:00 PM',
        status: 'Completed',
        courtImage:
            'https://via.placeholder.com/280x100?text=Alexandria+Courts',
      ),
      RecentReservation(
        id: '5',
        courtName: 'Al Noor Club',
        location: 'وسط البلد - Downtown',
        date: '25 يناير 2025',
        time: '5:30 PM',
        status: 'Upcoming',
        courtImage: 'https://via.placeholder.com/280x100?text=Al+Noor+Club2',
      ),
    ];
  }
}

class RecentReservation {
  final String id;
  final String courtName;
  final String location;
  final String date;
  final String time;
  final String status;
  final String courtImage;

  RecentReservation({
    required this.id,
    required this.courtName,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    required this.courtImage,
  });
}
