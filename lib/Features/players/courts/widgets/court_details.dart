import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padelsystem/Models/padel_court.dart';
import 'package:padelsystem/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/utils/helpers/helper_func.dart';

void showCourtDetails(PadelCourt court) {
  bool dark = AHelperFunction.isDarkMode(Get.context!);
  final controller = Get.find<CourtBrowseController>();

  Get.bottomSheet(
    Container(
      height: AHelperFunction.screenHeight() * 0.8,
      decoration: BoxDecoration(
        color: dark ? AColors.dark : AColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: dark ? AColors.grey : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    court.name,
                    style: Theme.of(Get.context!)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dark ? Colors.white : Colors.black,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close,
                    color: dark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Court Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                        ),
                      ),
                      child: court.photos.isNotEmpty
                          ? Image.network(
                              court.photos.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                child: Icon(
                                  Icons.sports_tennis,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.sports_tennis,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: ASizes.spaceBtwSections),

                  // Price and Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EGP ${court.pricePerHour.round()} / hour',
                        style: Theme.of(Get.context!)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                              color: AColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          controller.filterController
                              .getCourtTypeDisplayName(court.type),
                          style: const TextStyle(
                            color: AColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: ASizes.spaceBtwItems),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          court.location,
                          style: TextStyle(
                            fontSize: ASizes.fontSizeMd,
                            color: dark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (court.distanceFromUser != null) ...[
                        const Icon(
                          Icons.directions_walk,
                          color: AColors.darkGrey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.locationController
                              .getFormattedDistance(court.distanceFromUser!),
                          style: const TextStyle(
                            color: AColors.darkGrey,
                            fontSize: ASizes.fontSizeSm,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: ASizes.spaceBtwItems),

                  // Rating
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < court.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            size: 20,
                            color: Colors.amber,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${court.rating.toStringAsFixed(1)} (${court.totalBookings} bookings)',
                        style: TextStyle(
                          fontSize: ASizes.fontSizeMd,
                          color: dark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: ASizes.spaceBtwSections),

                  // Description
                  if (court.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style:
                          Theme.of(Get.context!).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: dark ? Colors.white : Colors.black,
                              ),
                    ),
                    const SizedBox(height: ASizes.spaceBtwItems),
                    Text(
                      court.description,
                      style: TextStyle(
                        fontSize: ASizes.fontSizeMd,
                        color: dark ? AColors.grey : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: ASizes.spaceBtwSections),
                  ],

                  // Facilities
                  if (court.facilities.isNotEmpty) ...[
                    Text(
                      'Facilities',
                      style:
                          Theme.of(Get.context!).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: dark ? Colors.white : Colors.black,
                              ),
                    ),
                    const SizedBox(height: ASizes.spaceBtwItems),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: court.facilities.map((facility) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: dark
                                ? AColors.containerDark
                                : AColors.containerLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AColors.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            facility,
                            style: TextStyle(
                              fontSize: ASizes.fontSizeSm,
                              color: dark ? Colors.white : Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Book Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: court.isActive
                    ? () {
                        Get.back();
                        controller.bookCourt(court.id, DateTime.now());
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AColors.primaryColor,
                  disabledBackgroundColor: AColors.darkGrey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  court.isActive ? 'Book Now' : 'Unavailable',
                  style: TextStyle(
                    fontSize: ASizes.fontSizeMd,
                    fontWeight: FontWeight.w600,
                    color: court.isActive ? Colors.white : AColors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}
