import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/core/const/colors.dart';

/// Holds the "Final step!" selections: avatar, gender and birth date.
class UserRestController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var selectedAvatarIndex = 0.obs;
  var selectedGender = 'Male'.obs;
  var selectedDate = Rxn<DateTime>(); // Nullable DateTime
  var birthdateText = ''.obs;

  // Text controller for birthdate field
  final birthdateController = TextEditingController();

  @override
  void onClose() {
    birthdateController.dispose();
    super.onClose();
  }

  // Method to update selected avatar
  void updateSelectedAvatar(int index) {
    selectedAvatarIndex.value = index;
  }

  // Method to update selected gender
  void updateSelectedGender(String gender) {
    selectedGender.value = gender;
  }

  // Method to update selected date
  void updateSelectedDate(DateTime? date) {
    selectedDate.value = date;
    if (date != null) {
      birthdateText.value = DateFormat('MMM dd, yyyy').format(date);
      birthdateController.text = birthdateText.value;
    } else {
      birthdateText.value = '';
      birthdateController.text = '';
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      helpText: 'Select your date of birth',
      builder: (pickerContext, child) {
        // The picker used to force a light blue scheme, which flashed a white
        // sheet in the middle of the dark signup flow and clashed with the
        // green brand. It now follows the app theme.
        return Theme(
          data: Theme.of(pickerContext).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AColors.primaryColor,
              brightness: Theme.of(pickerContext).brightness,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate.value) {
      updateSelectedDate(pickedDate);
    }
  }
}
