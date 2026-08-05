import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/user_rest.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

class ContinueDataController extends GetxController {
  var isLoading = false.obs;
  var isObscure = true.obs;
  var isConfirmObscure = true.obs;
  var currentPassword = ''.obs; // Observable for password strength
  var currentConfirmPassword =
      ''.obs; // Observable for confirm password matching

  /// Owned by the controller so the Continue button (a sibling widget) can
  /// trigger the inline field errors the form declares.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  Future<void> validateAndContinue(
    TextEditingController firstNameController,
    TextEditingController lastNameController,
    TextEditingController phoneController,
    TextEditingController passwordController,
    TextEditingController confirmPasswordController,
    String email,
  ) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      final phone = phoneController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      // Paints the inline errors on every field, not just the touched ones.
      formKey.currentState?.validate();

      if (!_validateFields(
          firstName, lastName, phone, password, confirmPassword)) {
        return;
      }

      // Parse phone number
      final int phoneNumber;
      try {
        phoneNumber = int.parse(phone.replaceAll(RegExp(r'[^\d]'), ''));
      } catch (_) {
        _showError('Invalid phone number format');
        return;
      }

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      Get.to(() => UserRest(
            email: email,
            firstName: firstName,
            lastName: lastName,
            password: password,
            confirmPassword: confirmPassword,
            phonenumber: phoneNumber,
          ));
    } catch (e) {
      _showError('An unexpected error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateFields(
    String firstName,
    String lastName,
    String phone,
    String password,
    String confirmPassword,
  ) {
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError('Please fill in all fields');
      return false;
    }

    if (!_isValidName(firstName)) {
      _showError('Please enter a valid first name (letters only)');
      return false;
    }

    if (!_isValidName(lastName)) {
      _showError('Please enter a valid last name (letters only)');
      return false;
    }

    if (!_isValidPhoneNumber(phone)) {
      _showError(
          'Please enter a valid phone number (11 digits, starts with 01)');
      return false;
    }

    if (!_isValidPassword(password)) {
      _showError(
          'Password must be at least 8 characters with uppercase, lowercase, and number');
      return false;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return false;
    }

    return true;
  }

  bool _isValidName(String name) {
    return RegExp(r'^[a-zA-Z\s]{2,}$').hasMatch(name);
  }

  bool _isValidPhoneNumber(String phone) {
    // Egyptian mobile numbers: 11 digits starting with 01.
    final String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length == 11 && cleanPhone.startsWith('01');
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  /// `Get.snackbar` throws "No Overlay found" on this Flutter version, which is
  /// why every step-2 validation error used to vanish silently.
  void _showError(String message) =>
      AppFeedback.error('Check your details', message);

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
