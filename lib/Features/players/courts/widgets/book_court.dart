import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Models/padel_court.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';

void bookCourt(PadelCourt court) {
  final controller = Get.find<CourtBrowseController>();

  // For now, book for next available slot (you can enhance this with date/time picker)
  final bookingTime = DateTime.now().add(const Duration(hours: 1));

  Get.dialog(
    AlertDialog(
      title: Text('Book ${court.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Court: ${court.name}'),
          const SizedBox(height: 8),
          Text('Location: ${court.location}'),
          const SizedBox(height: 8),
          Text('Price: EGP ${court.pricePerHour.round()} / hour'),
          const SizedBox(height: 8),
          Text(
              'Date: ${bookingTime.day}/${bookingTime.month}/${bookingTime.year}'),
          const SizedBox(height: 8),
          Text(
              'Time: ${bookingTime.hour}:${bookingTime.minute.toString().padLeft(2, '0')}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.bookCourt(court.id, bookingTime);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AColors.primaryColor,
          ),
          child: const Text(
            'Confirm Booking',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
