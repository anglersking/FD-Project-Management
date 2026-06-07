import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/constans/app_constants.dart';
import '../../controllers/setting_controller.dart';

class SettingScreen extends GetView<SettingController> {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(kSpacing * 1.5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: kSpacing * 2),
              _buildSection(
                icon: EvaIcons.personOutline,
                title: 'Account',
                children: [
                  _buildInfoTile(label: 'Username', value: 'admin'),
                  _buildInfoTile(label: 'Email', value: 'admin@example.com'),
                  _buildActionTile(
                    icon: EvaIcons.lockOutline,
                    label: 'Change Password',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: kSpacing * 1.5),
              _buildSection(
                icon: EvaIcons.bellOutline,
                title: 'Notifications',
                children: [
                  _buildSwitchTile(
                    label: 'Enable Notifications',
                    subtitle: 'Turn all notifications on or off',
                    valueObs: controller.notificationsEnabled,
                    onChanged: controller.toggleNotifications,
                  ),
                  _buildSwitchTile(
                    label: 'Email Notifications',
                    subtitle: 'Receive updates via email',
                    valueObs: controller.emailNotifications,
                    onChanged: controller.toggleEmailNotifications,
                  ),
                  _buildSwitchTile(
                    label: 'Push Notifications',
                    subtitle: 'Receive push alerts on device',
                    valueObs: controller.pushNotifications,
                    onChanged: controller.togglePushNotifications,
                  ),
                ],
              ),
              const SizedBox(height: kSpacing * 1.5),
              _buildSection(
                icon: EvaIcons.colorPaletteOutline,
                title: 'Appearance',
                children: [
                  _buildThemeSelector(),
                ],
              ),
              const SizedBox(height: kSpacing * 1.5),
              _buildSection(
                icon: EvaIcons.infoOutline,
                title: 'About',
                children: [
                  _buildInfoTile(label: 'Version', value: '1.0.0'),
                  _buildInfoTile(label: 'Build', value: '2026.06'),
                  _buildActionTile(
                    icon: EvaIcons.externalLinkOutline,
                    label: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _buildActionTile(
                    icon: EvaIcons.externalLinkOutline,
                    label: 'Terms of Service',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: kSpacing * 3),
            ],
          ),
        ),
      )),
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
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color.fromRGBO(128, 109, 255, 1)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(128, 109, 255, 1),
                letterSpacing: .8,
              ),
            ),
          ],
        ),
        const SizedBox(height: kSpacing / 2),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(38, 40, 55, 1),
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing, vertical: kSpacing * 0.75),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, color: kFontColorPallets[1])),
          Text(value,
              style: TextStyle(fontSize: 14, color: kFontColorPallets[2])),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSpacing, vertical: kSpacing * 0.75),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 14, color: kFontColorPallets[1])),
            ),
            Icon(icon, size: 16, color: kFontColorPallets[2]),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required String subtitle,
    required RxBool valueObs,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing, vertical: kSpacing * 0.5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 14, color: kFontColorPallets[1])),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: kFontColorPallets[2])),
              ],
            ),
          ),
          Obx(() => Switch(
                value: valueObs.value,
                onChanged: onChanged,
                activeColor: const Color.fromRGBO(128, 109, 255, 1),
              )),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    final themes = ['Dark', 'Light', 'System'];
    return Padding(
      padding: const EdgeInsets.all(kSpacing),
      child: Obx(() => Row(
            children: themes.asMap().entries.map((e) {
              final index = e.key;
              final label = e.value;
              final isSelected = controller.selectedTheme.value == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < themes.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => controller.setTheme(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color.fromRGBO(128, 109, 255, 1)
                            : const Color.fromRGBO(31, 29, 44, 1),
                        borderRadius: BorderRadius.circular(kBorderRadius / 2),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: kFontColorPallets[2].withOpacity(0.2),
                                width: 1),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : kFontColorPallets[2],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }
}
