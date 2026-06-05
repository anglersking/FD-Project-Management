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
      body: SafeArea(child: SingleChildScrollView(
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
              _buildDeviceList(),
              const SizedBox(height: kSpacing * 2),
              _buildSectionTitle(Icons.eco, '我的植物'),
              const SizedBox(height: kSpacing),
              _buildPlantList(),
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
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
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
                    Text(controller.name.value,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(controller.email.value,
                        style: TextStyle(
                            fontSize: 13, color: kFontColorPallets[2])),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(EvaIcons.briefcaseOutline,
                          size: 13,
                          color: Color.fromRGBO(128, 109, 255, 1)),
                      const SizedBox(width: 4),
                      Text(controller.role.value,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(128, 109, 255, 1))),
                    ]),
                  ],
                )),
          ),
          IconButton(
            onPressed: () => _showEditProfileDialog(),
            icon: const Icon(EvaIcons.editOutline, size: 18),
            color: kFontColorPallets[2],
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

  Widget _buildDeviceList() {
    return Obx(() => Column(
          children: controller.devices.asMap().entries.map((entry) {
            final i = entry.key;
            final device = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: kSpacing / 2),
              padding: const EdgeInsets.all(kSpacing),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(38, 40, 55, 1),
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: device['online'] == true
                          ? const Color.fromRGBO(74, 177, 120, 0.15)
                          : Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      EvaIcons.wifi,
                      size: 20,
                      color: device['online'] == true
                          ? kNotifColor
                          : kFontColorPallets[2],
                    ),
                  ),
                  const SizedBox(width: kSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(device['name'],
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(
                          '绑定植物：${device['plant']}',
                          style: TextStyle(
                              fontSize: 12, color: kFontColorPallets[2]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: device['online'] == true
                          ? kNotifColor.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      device['online'] == true ? '在线' : '离线',
                      style: TextStyle(
                        fontSize: 11,
                        color: device['online'] == true
                            ? kNotifColor
                            : kFontColorPallets[2],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showUnbindDialog(i),
                    icon: const Icon(EvaIcons.unlockOutline, size: 16),
                    color: Colors.redAccent.withOpacity(0.7),
                    tooltip: '解绑设备',
                  ),
                ],
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildPlantList() {
    return Obx(() => Column(
          children: controller.plants.asMap().entries.map((entry) {
            final plant = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: kSpacing / 2),
              padding: const EdgeInsets.all(kSpacing),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(38, 40, 55, 1),
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(74, 177, 120, 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eco,
                        size: 20, color: kNotifColor),
                  ),
                  const SizedBox(width: kSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plant['name'],
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(
                          plant['species'],
                          style: TextStyle(
                              fontSize: 12, color: kFontColorPallets[2]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showBindDeviceDialog(entry.key),
                    icon: const Icon(EvaIcons.plusCircleOutline, size: 18),
                    color: const Color.fromRGBO(128, 109, 255, 1),
                    tooltip: '绑定设备',
                  ),
                ],
              ),
            );
          }).toList(),
        ));
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: controller.name.value);
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color.fromRGBO(38, 40, 55, 1),
        title: const Text('编辑资料',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: nameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: '用户名',
            labelStyle: TextStyle(color: kFontColorPallets[2]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kFontColorPallets[2].withOpacity(0.3)),
              borderRadius: BorderRadius.circular(kBorderRadius / 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color.fromRGBO(128, 109, 255, 1)),
              borderRadius: BorderRadius.circular(kBorderRadius / 2),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text('取消',
                  style: TextStyle(color: kFontColorPallets[2]))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(128, 109, 255, 1)),
            onPressed: () {
              controller.updateName(nameCtrl.text);
              Get.back();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showUnbindDialog(int deviceIndex) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color.fromRGBO(38, 40, 55, 1),
        title: const Text('解绑设备',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text('确定要解绑该设备吗？',
            style: TextStyle(color: kFontColorPallets[1])),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text('取消',
                  style: TextStyle(color: kFontColorPallets[2]))),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              controller.unbindDevice(deviceIndex);
              Get.back();
            },
            child: const Text('解绑'),
          ),
        ],
      ),
    );
  }

  void _showBindDeviceDialog(int plantIndex) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color.fromRGBO(38, 40, 55, 1),
        title: const Text('绑定设备',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: controller.availableDevices
                  .map((d) => ListTile(
                        title: Text(d,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13)),
                        leading: const Icon(EvaIcons.wifi,
                            color: Color.fromRGBO(128, 109, 255, 1), size: 18),
                        onTap: () {
                          controller.bindDevice(plantIndex, d);
                          Get.back();
                        },
                      ))
                  .toList(),
            )),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text('取消',
                  style: TextStyle(color: kFontColorPallets[2]))),
        ],
      ),
    );
  }
}
