import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/constans/app_constants.dart';

class SettingController extends GetxController {
  final selectedTheme = 0.obs;
  final notificationsEnabled = true.obs;
  final emailNotifications = true.obs;
  final pushNotifications = false.obs;

  void setTheme(int index) => selectedTheme.value = index;
  void toggleNotifications(bool val) => notificationsEnabled.value = val;
  void toggleEmailNotifications(bool val) => emailNotifications.value = val;
  void togglePushNotifications(bool val) => pushNotifications.value = val;
}
