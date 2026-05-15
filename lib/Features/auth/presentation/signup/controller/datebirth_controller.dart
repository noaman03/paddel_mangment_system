// Create a new file: lib/Features/auth/presentation/signup/controller/user_rest_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
  void onInit() {
    super.onInit();
    // Initialize with default values if needed
    selectedDate.value = null;
    birthdateText.value = '';
  }

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

  // Method to show date picker
  Future<void> showBirthdatePicker(BuildContext context) async {
    final DateTime? pickedDate = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: selectedDate.value ??
            DateTime.now().subtract(const Duration(days: 365 * 18)),
        firstDate: DateTime(1990),
        lastDate: DateTime.now(),
      ),
    );

    if (pickedDate != null && pickedDate != selectedDate.value) {
      updateSelectedDate(pickedDate);
    }
  }

  // Alternative method using showDatePicker directly
  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Replace with your primary color
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
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

  // Validation method
  bool validateForm() {
    if (selectedDate.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select your date of birth',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    return true;
  }
}
