import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padelsystem/Features/auth/presentation/signup/user_rest.dart';

class ContinueDataController extends GetxController {
  var isLoading = false.obs;
  var isObscure = true.obs;
  var isConfirmObscure = true.obs;
  var currentPassword = ''.obs; // Observable for password strength
  var currentConfirmPassword =
      ''.obs; // Observable for confirm password matching

  void togglePasswordVisibility() => isObscure.value = !isObscure.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmObscure.value = !isConfirmObscure.value;

  // Update password and trigger reactive updates
  void updatePassword(String password) {
    currentPassword.value = password;
  }

  // Update confirm password and trigger reactive updates
  void updateConfirmPassword(String confirmPassword) {
    currentConfirmPassword.value = confirmPassword;
  }

  // Get password strength (0-3) - reactive method
  int get passwordStrength {
    final password = currentPassword.value;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    return score - 1 < 0 ? 0 : score - 1; // Convert to 0-3 range
  }

  // Check if passwords match - reactive getter
  bool get passwordsMatch {
    return currentPassword.value == currentConfirmPassword.value &&
        currentConfirmPassword.value.isNotEmpty;
  }

  void validateAndContinue(
    BuildContext context,
    TextEditingController firstNameController,
    TextEditingController lastNameController,
    TextEditingController phoneController,
    TextEditingController passwordController,
    TextEditingController confirmPasswordController,
    String email,
  ) async {
    isLoading.value = true;

    try {
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      final phone = phoneController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      // Validation checks
      if (!_validateFields(
          context, firstName, lastName, phone, password, confirmPassword)) {
        isLoading.value = false;
        return;
      }

      // Parse phone number
      int phoneNumber;
      try {
        phoneNumber = int.parse(phone.replaceAll(RegExp(r'[^\d]'), ''));
      } catch (e) {
        _showErrorSnackBar(context, 'Invalid phone number format');
        isLoading.value = false;
        return;
      }

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      isLoading.value = false;

      // Navigate to the next screen
      Get.to(() => UserRest(
            email: email,
            firstName: firstName,
            lastName: lastName,
            password: password,
            confirmPassword: confirmPassword,
            phonenumber: phoneNumber,
          ));
    } catch (e) {
      isLoading.value = false;
      _showErrorSnackBar(
          context, 'An unexpected error occurred: ${e.toString()}');
    }
  }

  bool _validateFields(
    BuildContext context,
    String firstName,
    String lastName,
    String phone,
    String password,
    String confirmPassword,
  ) {
    // Check for empty fields
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorSnackBar(context, 'Please fill in all fields');
      return false;
    }

    // Validate first name
    if (!_isValidName(firstName)) {
      _showErrorSnackBar(
          context, 'Please enter a valid first name (letters only)');
      return false;
    }

    // Validate last name
    if (!_isValidName(lastName)) {
      _showErrorSnackBar(
          context, 'Please enter a valid last name (letters only)');
      return false;
    }

    // Validate phone number (adjust for your requirements)
    if (!_isValidPhoneNumber(phone)) {
      _showErrorSnackBar(
          context, 'Please enter a valid phone number (11 digits)');
      return false;
    }

    // Validate password strength
    if (!_isValidPassword(password)) {
      _showErrorSnackBar(context,
          'Password must be at least 8 characters with uppercase, lowercase, and number');
      return false;
    }

    // Check password match
    if (password != confirmPassword) {
      _showErrorSnackBar(context, 'Passwords do not match');
      return false;
    }

    return true;
  }

  bool _isValidName(String name) {
    return RegExp(r'^[a-zA-Z\s]{2,}$').hasMatch(name);
  }

  bool _isValidPhoneNumber(String phone) {
    // Updated for Egyptian phone numbers (11 digits starting with 01)
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length == 11 && cleanPhone.startsWith('01');
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    Get.snackbar(
      'Validation Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  void clearFormData() {
    isLoading.value = false;
    isObscure.value = true;
    isConfirmObscure.value = true;
    currentPassword.value = '';
    currentConfirmPassword.value = '';
  }

  // Individual field validators
  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (!_isValidName(value)) {
      return 'Enter a valid first name';
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    if (!_isValidName(value)) {
      return 'Enter a valid last name';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!_isValidPhoneNumber(value)) {
      return 'Enter a valid 11-digit phone number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!_isValidPassword(value)) {
      return 'Password must be 8+ chars with upper, lower, number';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
