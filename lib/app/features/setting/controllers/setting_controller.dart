import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/constans/app_constants.dart';
import 'package:project_management/app/services/api_service.dart';
import 'package:project_management/app/services/auth_service.dart';
import 'package:project_management/app/config/routes/app_pages.dart';

class SettingController extends GetxController {
  final selectedTheme = 0.obs;
  final notificationsEnabled = true.obs;
  final emailNotifications = true.obs;
  final pushNotifications = false.obs;

  // 修改密码
  final isChangingPassword = false.obs;

  void setTheme(int index) => selectedTheme.value = index;
  void toggleNotifications(bool val) => notificationsEnabled.value = val;
  void toggleEmailNotifications(bool val) => emailNotifications.value = val;
  void togglePushNotifications(bool val) => pushNotifications.value = val;

  /// 修改密码：通过手机号 + 新密码
  Future<void> changePassword({
    required String phone,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (phone.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _snackError('Please fill in all fields');
      return;
    }
    if (newPassword != confirmPassword) {
      _snackError('Passwords do not match');
      return;
    }
    if (newPassword.length < 6) {
      _snackError('Password must be at least 6 characters');
      return;
    }

    isChangingPassword.value = true;
    final result = await ApiService.resetPassword(
      phone: phone,
      newPassword: newPassword,
    );
    isChangingPassword.value = false;

    if (result.ok) {
      Get.snackbar('成功', 'Password changed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kNotifColor.withOpacity(0.9),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16));
    } else {
      _snackError(result.error ?? 'Failed to change password');
    }
  }

  /// 退出登录
  Future<void> logout() async {
    final token = await AuthService.getToken();
    if (token != null) {
      await ApiService.logout(token: token);
    }
    await AuthService.clearSession();
    Get.offAllNamed(Routes.login);
  }

  void _snackError(String msg) {
    Get.snackbar('Error', msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16));
  }
}
