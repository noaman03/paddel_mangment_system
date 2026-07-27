import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/Models/padel_court.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/Features/players/checkout/checkout_screen.dart';

class CourtDetailsScreen extends ConsumerStatefulWidget {
  final PadelCourt court;

  const CourtDetailsScreen({super.key, required this.court});

  @override
  ConsumerState<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends ConsumerState<CourtDetailsScreen> {
  late DateTime _selectedDate;
  TimeSlot? _selectedSlot;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    bool dark = Theme.of(context).brightness == Brightness.dark;
    final court = widget.court;

    return Scaffold(
      backgroundColor: dark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(court.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            Stack(
              children: [
                SizedBox(
                  height: 250,
                  child: court.photos.isNotEmpty
                      ? PageView.builder(
                          onPageChanged: (index) {
                            setState(() => _currentImageIndex = index);
                          },
                          itemCount: court.photos.length,
                          itemBuilder: (_, index) {
                            return Image.network(
                              court.photos[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child:
                              const Icon(Icons.image_not_supported, size: 50),
                        ),
                ),
                // Image indicator
                if (court.photos.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          court.photos.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? AColors.primaryColor
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Court Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              court.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: AColors.primaryColor),
                                const SizedBox(width: 5),
                                Text(
                                  court.location,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AColors.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                size: 18, color: AColors.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              court.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price per Hour',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '\$${court.pricePerHour.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    court.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),

                  // Facilities
                  Text(
                    'Facilities',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: court.facilities.map((facility) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AColors.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          facility,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AColors.primaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Weekly Schedule
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date & Time',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Week days selector
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (_, index) {
                        DateTime date =
                            DateTime.now().add(Duration(days: index));
                        bool isSelected =
                            DateFormat('yyyy-MM-dd').format(_selectedDate) ==
                                DateFormat('yyyy-MM-dd').format(date);

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedDate = date);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AColors.primaryColor
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AColors.primaryColor
                                    : Colors.grey[300]!,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('EEE').format(date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('d').format(date),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Time slots
                  Text(
                    'Available Time Slots',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _generateTimeSlots().length,
                    itemBuilder: (_, index) {
                      final slot = _generateTimeSlots()[index];
                      bool isSelected = _selectedSlot == slot;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedSlot = slot);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AColors.primaryColor
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AColors.primaryColor
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  slot.time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  '\$${slot.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? Colors.white
                                        : AColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Book button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedSlot != null
                      ? () {
                          // Navigate to checkout with booking details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(
                                courtName: widget.court.name,
                                courtLocation: widget.court.location,
                                selectedDate: _selectedDate,
                                timeSlot: _selectedSlot!.time,
                                pricePerHour: widget.court.pricePerHour,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AColors.primaryColor,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  List<TimeSlot> _generateTimeSlots() {
    List<TimeSlot> slots = [];
    for (int hour = 12; hour < 24; hour++) {
      slots.add(TimeSlot(
        time:
            '${hour % 12 == 0 ? 12 : hour % 12}:00 ${hour < 12 ? 'AM' : 'PM'}',
        price: widget.court.pricePerHour,
        isAvailable: true,
      ));
    }
    return slots;
  }
}

class TimeSlot {
  final String time;
  final double price;
  final bool isAvailable;

  TimeSlot({
    required this.time,
    required this.price,
    required this.isAvailable,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlot &&
          runtimeType == other.runtimeType &&
          time == other.time;

  @override
  int get hashCode => time.hashCode;
}
