import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/config/routes/app_pages.dart';
import 'package:project_management/app/services/api_service.dart';
import 'package:project_management/app/services/auth_service.dart';

class LoginController extends GetxController {
  /// 支持用户名或手机号登录
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final identifier = identifierController.text.trim();
    final password = passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _snackError('Please fill in all fields');
      return;
    }

    isLoading.value = true;
    final result = await ApiService.login(
      identifier: identifier,
      password: password,
    );
    isLoading.value = false;

    if (result.ok) {
      final token = result.data['token'] as String;
      final user = result.data['user'] as Map<String, dynamic>;
      await AuthService.saveSession(token: token, user: user);
      Get.offAllNamed(Routes.dashboard);
    } else {
      _snackError(result.error ?? 'Login failed');
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
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
