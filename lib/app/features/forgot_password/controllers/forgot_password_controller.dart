import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/services/api_service.dart';

class ForgotPasswordController extends GetxController {
  final phoneController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isSuccess = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  Future<void> resetPassword() async {
    final phone = phoneController.text.trim();
    final newPwd = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (phone.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
      _snackError('Please fill in all fields');
      return;
    }

    if (newPwd != confirm) {
      _snackError('Passwords do not match');
      return;
    }

    if (newPwd.length < 6) {
      _snackError('Password must be at least 6 characters');
      return;
    }

    isLoading.value = true;
    final result = await ApiService.resetPassword(
      phone: phone,
      newPassword: newPwd,
    );
    isLoading.value = false;

    if (result.ok) {
      isSuccess.value = true;
    } else {
      _snackError(result.error ?? 'Reset failed');
    }
  }

  void _snackError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    phoneController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
