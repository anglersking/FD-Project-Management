import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_management/app/services/api_service.dart';
import 'package:project_management/app/services/auth_service.dart';
import 'package:project_management/app/constans/app_constants.dart';

class ProfileController extends GetxController {
  final name = ''.obs;
  final phone = ''.obs;
  final role = 'Plant Manager'.obs;
  final joinDate = ''.obs;

  // 绑定的设备列表，每项包含 { id, device_id, device_name, plant_image, bound_at, latest_data? }
  final devices = <Map<String, dynamic>>[].obs;
  final isLoadingDevices = false.obs;

  // 待绑定时选择的图片
  final selectedImageBytes = Rxn<Uint8List>();
  final selectedImageName = ''.obs;
  final isUploadingImage = false.obs;

  final _picker = ImagePicker();

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

  /// 选择植物图片（相册或相机）
  Future<void> pickImage({bool fromCamera = false}) async {
    final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    selectedImageBytes.value = bytes;
    selectedImageName.value = picked.name;
  }

  /// 清除已选图片
  void clearImage() {
    selectedImageBytes.value = null;
    selectedImageName.value = '';
  }

  /// 绑定设备（含可选图片上传）
  Future<void> bindDevice(String deviceId, {String deviceName = ''}) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    // 1. 先绑定设备
    final bindResult = await ApiService.bindDevice(
      token: token,
      deviceId: deviceId,
      deviceName: deviceName,
    );

    if (!bindResult.ok) {
      Get.snackbar('Error', bindResult.error ?? 'Bind failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16));
      return;
    }

    // 2. 如果选了图片，上传到 MinIO
    if (selectedImageBytes.value != null) {
      isUploadingImage.value = true;
      final uploadResult = await ApiService.uploadPlantImage(
        token: token,
        deviceId: deviceId,
        imageBytes: selectedImageBytes.value!,
        fileName: selectedImageName.value.isNotEmpty
            ? selectedImageName.value
            : 'plant.jpg',
      );
      isUploadingImage.value = false;

      if (!uploadResult.ok) {
        Get.snackbar('图片上传失败', uploadResult.error ?? '请稍后重试',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withOpacity(0.9),
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16));
      }
    }

    clearImage();
    Get.snackbar('成功', '设备绑定成功',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kNotifColor.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16));
    await loadMyDevices();
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

