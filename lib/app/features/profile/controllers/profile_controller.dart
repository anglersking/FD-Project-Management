import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/services/api_service.dart';
import 'package:project_management/app/services/auth_service.dart';
import 'package:project_management/app/constans/app_constants.dart';

class ProfileController extends GetxController {
  final name = ''.obs;
  final phone = ''.obs;
  final role = 'Plant Manager'.obs;
  final joinDate = ''.obs;

  // 绑定的设备列表，每项包含 { id, device_id, device_name, bound_at, latest_data? }
  final devices = <Map<String, dynamic>>[].obs;
  final isLoadingDevices = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    loadMyDevices();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getUser();
    if (user != null) {
      name.value = user['username'] ?? '';
      phone.value = user['phone'] ?? '';
      final created = user['created_at'] ?? '';
      if (created.isNotEmpty) {
        try {
          final dt = DateTime.parse(created);
          joinDate.value = '${dt.year}年${dt.month}月';
        } catch (_) {
          joinDate.value = created;
        }
      }
    }
  }

  Future<void> loadMyDevices() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    isLoadingDevices.value = true;
    final result = await ApiService.getMyDevices(token: token);
    isLoadingDevices.value = false;

    if (result.ok) {
      devices.value = List<Map<String, dynamic>>.from(result.data as List);
    } else {
      Get.snackbar('Error', result.error ?? 'Failed to load devices',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16));
    }
  }

  /// 绑定设备：输入 device_id 和可选名称
  Future<void> bindDevice(String deviceId, {String deviceName = ''}) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final result = await ApiService.bindDevice(
      token: token,
      deviceId: deviceId,
      deviceName: deviceName,
    );

    if (result.ok) {
      Get.snackbar('成功', '设备绑定成功',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kNotifColor.withOpacity(0.9),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16));
      await loadMyDevices(); // 刷新列表
    } else {
      Get.snackbar('Error', result.error ?? 'Bind failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16));
    }
  }

  /// 解绑设备
  Future<void> unbindDevice(String deviceId) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final result = await ApiService.unbindDevice(token: token, deviceId: deviceId);
    if (result.ok) {
      Get.snackbar('成功', '设备已解绑',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kNotifColor.withOpacity(0.9),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16));
      await loadMyDevices();
    } else {
      Get.snackbar('Error', result.error ?? 'Unbind failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16));
    }
  }
}
