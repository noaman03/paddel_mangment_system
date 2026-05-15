import 'package:flutter/material.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  late List<ReservationItem> _reservations;

  @override
  void initState() {
    super.initState();
    _reservations = _getDummyReservations();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AColors.dark : AColors.light,
      appBar: AppBar(
        backgroundColor: isDark ? AColors.dark : Colors.white,
        elevation: 0,
        title: Text(
          'My Reservations',
          style: TextStyle(
            color: isDark ? Colors.white : AColors.textprimary,
            fontWeight: FontWeight.bold,
            fontSize: ASizes.fontSizeLg,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : AColors.textprimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _reservations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: ASizes.iconLg * 2,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: ASizes.md),
                  Text(
                    'No reservations yet',
                    style: TextStyle(
                      fontSize: ASizes.fontSizeMd,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(ASizes.md),
              itemCount: _reservations.length,
              itemBuilder: (context, index) {
                final reservation = _reservations[index];
                return _buildReservationCard(context, reservation, isDark);
              },
            ),
    );
  }

  Widget _buildReservationCard(
      BuildContext context, ReservationItem reservation, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: ASizes.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ASizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reservation.courtName,
                    style: TextStyle(
                      fontSize: ASizes.fontSizeLg,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AColors.textprimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ASizes.sm,
                    vertical: ASizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reservation.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
                  ),
                  child: Text(
                    reservation.status,
                    style: TextStyle(
                      fontSize: ASizes.fontSizeSm - 2,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(reservation.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASizes.sm),

            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: ASizes.iconSm,
                  color: AColors.primaryColor,
                ),
                const SizedBox(width: ASizes.xs),
                Expanded(
                  child: Text(
                    reservation.location,
                    style: TextStyle(
                      fontSize: ASizes.fontSizeSm,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASizes.sm),

            // Date and time
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: ASizes.iconSm,
                  color: AColors.primaryColor,
                ),
                const SizedBox(width: ASizes.xs),
                Text(
                  reservation.date,
                  style: TextStyle(
                    fontSize: ASizes.fontSizeSm,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: ASizes.md),
                Icon(
                  Icons.schedule,
                  size: ASizes.iconSm,
                  color: AColors.primaryColor,
                ),
                const SizedBox(width: ASizes.xs),
                Text(
                  reservation.time,
                  style: TextStyle(
                    fontSize: ASizes.fontSizeSm,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASizes.md),

            // Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: ASizes.fontSizeSm,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  '\$${reservation.price}',
                  style: const TextStyle(
                    fontSize: ASizes.fontSizeLg,
                    fontWeight: FontWeight.bold,
                    color: AColors.primaryColor,
                  ),
                ),
              ],
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

  List<ReservationItem> _getDummyReservations() {
    return [
      ReservationItem(
        id: '1',
        courtName: 'Al Noor Club',
        location: 'Downtown Cairo',
        date: 'Jan 15, 2025',
        time: '5:00 PM - 6:00 PM',
        price: 250,
        status: 'Completed',
      ),
      ReservationItem(
        id: '2',
        courtName: 'Al Ahmar Club',
        location: 'New Cairo',
        date: 'Jan 20, 2025',
        time: '6:00 PM - 7:00 PM',
        price: 300,
        status: 'Upcoming',
      ),
      ReservationItem(
        id: '3',
        courtName: 'Athletes Club',
        location: 'Giza',
        date: 'Jan 10, 2025',
        time: '4:00 PM - 5:00 PM',
        price: 200,
        status: 'Completed',
      ),
      ReservationItem(
        id: '4',
        courtName: 'Alexandria Courts',
        location: 'Alexandria',
        date: 'Jan 5, 2025',
        time: '7:00 PM - 8:00 PM',
        price: 180,
        status: 'Completed',
      ),
      ReservationItem(
        id: '5',
        courtName: 'Al Noor Club',
        location: 'Downtown Cairo',
        date: '25 يناير 2025',
        time: '5:30 PM - 6:30 PM',
        price: 250,
        status: 'Upcoming',
      ),
    ];
  }
}

class ReservationItem {
  final String id;
  final String courtName;
  final String location;
  final String date;
  final String time;
  final double price;
  final String status;

  ReservationItem({
    required this.id,
    required this.courtName,
    required this.location,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
  });
}
