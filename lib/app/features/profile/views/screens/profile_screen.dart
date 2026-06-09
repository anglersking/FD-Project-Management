import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/constans/app_constants.dart';
import '../../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kSpacing * 1.5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: kSpacing * 2),
                _buildUserCard(),
                const SizedBox(height: kSpacing * 2),
                _buildSectionTitle(EvaIcons.hardDriveOutline, '我的设备'),
                const SizedBox(height: kSpacing),
                _buildBindButton(),
                const SizedBox(height: kSpacing),
                _buildDeviceList(),
                const SizedBox(height: kSpacing * 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          color: Colors.white,
        ),
        const SizedBox(width: kSpacing),
        const Text(
          'Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(kSpacing),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(38, 40, 55, 1),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color.fromRGBO(128, 109, 255, 0.2),
            child: const Icon(EvaIcons.person, size: 36,
                color: Color.fromRGBO(128, 109, 255, 1)),
          ),
          const SizedBox(width: kSpacing),
          Expanded(
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.name.value.isEmpty ? '---' : controller.name.value,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(controller.phone.value.isEmpty ? '---' : controller.phone.value,
                        style: TextStyle(fontSize: 13, color: kFontColorPallets[2])),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(EvaIcons.briefcaseOutline,
                          size: 13, color: Color.fromRGBO(128, 109, 255, 1)),
                      const SizedBox(width: 4),
                      Text(controller.role.value,
                          style: const TextStyle(
                              fontSize: 12, color: Color.fromRGBO(128, 109, 255, 1))),
                      if (controller.joinDate.value.isNotEmpty) ...[
                        Text('  ·  ${controller.joinDate.value}',
                            style: TextStyle(fontSize: 12, color: kFontColorPallets[2])),
                      ]
                    ]),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color.fromRGBO(128, 109, 255, 1)),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(128, 109, 255, 1),
              letterSpacing: .8,
            )),
      ],
    );
  }

  Widget _buildBindButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: _showBindDeviceDialog,
        icon: const Icon(EvaIcons.plusCircleOutline, size: 18,
            color: Color.fromRGBO(128, 109, 255, 1)),
        label: const Text('绑定新设备',
            style: TextStyle(color: Color.fromRGBO(128, 109, 255, 1), fontSize: 14)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color.fromRGBO(128, 109, 255, 0.5)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius / 2)),
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    return Obx(() {
      if (controller.isLoadingDevices.value) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
              color: Color.fromRGBO(128, 109, 255, 1), strokeWidth: 2),
        ));
      }

      if (controller.devices.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(kSpacing * 1.5),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(38, 40, 55, 1),
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: Center(
            child: Text('暂无绑定设备，点击上方按钮添加',
                style: TextStyle(fontSize: 13, color: kFontColorPallets[2])),
          ),
        );
      }

      return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: controller.devices.map((device) {
          final deviceId = device['device_id'] as String? ?? '';
          final deviceName = device['device_name'] as String? ?? '';
          final plantImage = device['plant_image'] as String? ?? '';
          final latestData = device['latest_data'] as Map<String, dynamic>?;
          final hasData = latestData != null;

          return Container(
            margin: const EdgeInsets.only(bottom: kSpacing / 2),
            padding: const EdgeInsets.all(kSpacing),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(38, 40, 55, 1),
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Row(
              children: [
                // 植物图片 or 默认图标
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: plantImage.isNotEmpty
                      ? Image.network(
                          plantImage,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _defaultDeviceIcon(hasData),
                        )
                      : _defaultDeviceIcon(hasData),
                ),
                const SizedBox(width: kSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceName.isNotEmpty ? deviceName : deviceId,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: $deviceId',
                        style: TextStyle(fontSize: 11, color: kFontColorPallets[2]),
                      ),
                      if (hasData) ...[
                        const SizedBox(height: 4),
                        Text(
                          '温度 ${latestData!['T'] ?? '--'}°  湿度 ${latestData['S'] ?? '--'}%  盐分 ${latestData['A'] ?? '--'}',
                          style: TextStyle(fontSize: 11, color: kFontColorPallets[2]),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasData
                        ? kNotifColor.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hasData ? '有数据' : '无数据',
                    style: TextStyle(
                        fontSize: 11,
                        color: hasData ? kNotifColor : kFontColorPallets[2]),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showUnbindDialog(deviceId),
                  icon: const Icon(EvaIcons.unlockOutline, size: 16),
                  color: Colors.redAccent.withOpacity(0.7),
                  tooltip: '解绑设备',
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _defaultDeviceIcon(bool hasData) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: hasData
            ? kNotifColor.withOpacity(0.15)
            : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        EvaIcons.wifi,
        size: 24,
        color: hasData ? kNotifColor : kFontColorPallets[2],
      ),
    );
  }

  void _showBindDeviceDialog() {
    final deviceIdCtrl = TextEditingController();
    final deviceNameCtrl = TextEditingController();
    // 清空上次选的图片
    controller.clearImage();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color.fromRGBO(38, 40, 55, 1),
        title: const Text('绑定设备',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: deviceIdCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('设备 ID（必填）', EvaIcons.hardDriveOutline),
              ),
              const SizedBox(height: kSpacing),
              TextField(
                controller: deviceNameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('植物名称（选填）', EvaIcons.editOutline),
              ),
              const SizedBox(height: kSpacing),
              // 图片选择区域
              Obx(() {
                final bytes = controller.selectedImageBytes.value;
                return Column(
                  children: [
                    if (bytes != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(kBorderRadius / 2),
                            child: Image.memory(bytes,
                                height: 140, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: controller.clearImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(28, 30, 42, 1),
                          borderRadius: BorderRadius.circular(kBorderRadius / 2),
                          border: Border.all(
                              color: kFontColorPallets[2].withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text('未选择植物照片',
                              style: TextStyle(
                                  fontSize: 12, color: kFontColorPallets[2])),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showImageSourceSheet(),
                        icon: const Icon(EvaIcons.imageOutline, size: 15,
                            color: Color.fromRGBO(128, 109, 255, 1)),
                        label: const Text('上传植物照片',
                            style: TextStyle(
                                color: Color.fromRGBO(128, 109, 255, 1),
                                fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(
                              color: Color.fromRGBO(128, 109, 255, 0.4)),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(kBorderRadius / 2)),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                controller.clearImage();
                Get.back();
              },
              child: Text('取消', style: TextStyle(color: kFontColorPallets[2]))),
          Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(128, 109, 255, 1)),
                onPressed: controller.isUploadingImage.value
                    ? null
                    : () {
                        final id = deviceIdCtrl.text.trim();
                        if (id.isEmpty) return;
                        Get.back();
                        controller.bindDevice(id,
                            deviceName: deviceNameCtrl.text.trim());
                      },
                child: controller.isUploadingImage.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('绑定'),
              )),
        ],
      ),
    );
  }

  void _showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(38, 40, 55, 1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('选择植物照片',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(EvaIcons.imageOutline,
                  color: Color.fromRGBO(128, 109, 255, 1)),
              title: const Text('从相册选择',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              onTap: () {
                Get.back();
                controller.pickImage(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(EvaIcons.cameraOutline,
                  color: Color.fromRGBO(128, 109, 255, 1)),
              title: const Text('拍照',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              onTap: () {
                Get.back();
                controller.pickImage(fromCamera: true);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showUnbindDialog(String deviceId) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color.fromRGBO(38, 40, 55, 1),
        title: const Text('解绑设备',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text('确定要解绑设备 $deviceId 吗？',
            style: TextStyle(color: kFontColorPallets[1])),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text('取消', style: TextStyle(color: kFontColorPallets[2]))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Get.back();
              controller.unbindDevice(deviceId);
            },
            child: const Text('解绑'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: kFontColorPallets[2], fontSize: 13),
      prefixIcon: Icon(icon, color: kFontColorPallets[2], size: 18),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kFontColorPallets[2].withOpacity(0.3)),
        borderRadius: BorderRadius.circular(kBorderRadius / 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color.fromRGBO(128, 109, 255, 1)),
        borderRadius: BorderRadius.circular(kBorderRadius / 2),
      ),
    );
  }
}

