import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/constans/app_constants.dart';
import 'package:project_management/app/services/api_service.dart';
import 'package:project_management/app/services/auth_service.dart';
import 'package:project_management/app/config/routes/app_pages.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  Future<void> register() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (name.isEmpty || phone.isEmpty || password.isEmpty || confirm.isEmpty) {
      _snackError('Please fill in all fields');
      return;
    }

    if (password != confirm) {
      _snackError('Passwords do not match');
      return;
    }

    isLoading.value = true;
    final result = await ApiService.register(
      username: name,
      phone: phone,
      password: password,
    );
    isLoading.value = false;

    if (result.ok) {
      final token = result.data['token'] as String;
      final user = result.data['user'] as Map<String, dynamic>;
      await AuthService.saveSession(token: token, user: user);
      // 注册成功直接进入主页
      Get.offAllNamed(Routes.dashboard);
    } else {
      _snackError(result.error ?? 'Registration failed');
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
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
