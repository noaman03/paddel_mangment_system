import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padelsystem/Models/padel_court.dart';
import 'package:padelsystem/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padelsystem/Features/players/courts/widgets/court_details.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/utils/helpers/helper_func.dart';

Widget buildCourtCard(PadelCourt court) {
  final bool dark = AHelperFunction.isDarkMode(Get.context!);
  final controller = Get.find<CourtBrowseController>();

  return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: dark ? AColors.containerDark : AColors.containerLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? AColors.grey.withOpacity(0.3) : AColors.borderPrimary,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showCourtDetails(court),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Court Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Court Image/Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                        ),
                      ),
                      child: court.photos.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                court.photos.first,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.sports_tennis,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.sports_tennis,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                    const SizedBox(width: 12),

                    // Court Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            court.name,
                            style: TextStyle(
                              fontSize: ASizes.fontSizeLg,
                              fontWeight: FontWeight.bold,
                              color: dark ? AColors.white : AColors.textprimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: dark
                                    ? AColors.grey
                                    : AColors.textsecondarry,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  court.location,
                                  style: TextStyle(
                                    fontSize: ASizes.fontSizeSm,
                                    color: dark
                                        ? AColors.grey
                                        : AColors.textsecondarry,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (court.distanceFromUser != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  controller.locationController
                                      .getFormattedDistance(
                                          court.distanceFromUser!),
                                  style: const TextStyle(
                                    fontSize: ASizes.fontSizeSm,
                                    color: AColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EGP ${court.pricePerHour.round()}',
                          style: const TextStyle(
                            fontSize: ASizes.fontSizeLg,
                            fontWeight: FontWeight.bold,
                            color: AColors.primaryColor,
                          ),
                        ),
                        const Text(
                          'per hour',
                          style: TextStyle(
                            fontSize: ASizes.fontSizeSm,
                            color: AColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Rating and Type
                Row(
                  children: [
                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          court.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: ASizes.fontSizeSm,
                            fontWeight: FontWeight.w600,
                            color: dark ? AColors.white : AColors.textprimary,
                          ),
                        ),
                        Text(
                          ' (${court.totalBookings})',
                          style: TextStyle(
                            fontSize: ASizes.fontSizeSm,
                            color: dark ? AColors.grey : AColors.textsecondarry,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // Court Type
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        controller.filterController
                            .getCourtTypeDisplayName(court.type),
                        style: const TextStyle(
                          fontSize: ASizes.fontSizeSm,
                          color: AColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: court.isActive
                            ? AColors.success.withOpacity(0.1)
                            : AColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        court.isActive ? 'Available' : 'Closed',
                        style: TextStyle(
                          fontSize: ASizes.fontSizeSm,
                          color:
                              court.isActive ? AColors.success : AColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Facilities (if any)
                if (court.facilities.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: court.facilities.take(3).map((facility) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: dark
                              ? AColors.grey.withOpacity(0.2)
                              : AColors.borderPrimary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          facility,
                          style: TextStyle(
                            fontSize: ASizes.fontSizeSm,
                            color: dark ? AColors.grey : AColors.textsecondarry,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (court.facilities.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${court.facilities.length - 3} more',
                        style: const TextStyle(
                          fontSize: ASizes.fontSizeSm,
                          color: AColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ));
}
