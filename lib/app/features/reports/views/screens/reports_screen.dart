import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/constans/app_constants.dart';
import '../../controllers/reports_controller.dart';

class ReportsScreen extends GetView<ReportsController> {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(kSpacing * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: kSpacing * 1.5),
            _buildPeriodTabs(),
            const SizedBox(height: kSpacing * 1.5),
            _buildSectionTitle(EvaIcons.activityOutline, '植物状态总览'),
            const SizedBox(height: kSpacing),
            _buildPlantStatusCards(),
            const SizedBox(height: kSpacing * 1.5),
            _buildSectionTitle(EvaIcons.dropletOutline, '浇水记录'),
            const SizedBox(height: kSpacing),
            _buildWaterRecords(),
            const SizedBox(height: kSpacing * 1.5),
            _buildSectionTitle(EvaIcons.alertTriangleOutline, '告警记录'),
            const SizedBox(height: kSpacing),
            _buildAlertRecords(),
            const SizedBox(height: kSpacing * 3),
          ],
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
          'Reports',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPeriodTabs() {
    final periods = ['今天', '本周', '本月'];
    return Obx(() => Row(
          children: periods.asMap().entries.map((e) {
            final isSelected = controller.selectedPeriod.value == e.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.setPeriod(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromRGBO(128, 109, 255, 1)
                        : const Color.fromRGBO(38, 40, 55, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : kFontColorPallets[2],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(children: [
      Icon(icon, size: 16, color: const Color.fromRGBO(128, 109, 255, 1)),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(128, 109, 255, 1),
              letterSpacing: .8)),
    ]);
  }

  Widget _buildPlantStatusCards() {
    return Obx(() => Wrap(
          spacing: kSpacing / 2,
          runSpacing: kSpacing / 2,
          children: controller.plantStatuses.map((p) {
            final Color statusColor = _statusColor(p['status']);
            return Container(
              width: 180,
              padding: const EdgeInsets.all(kSpacing),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(38, 40, 55, 1),
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.eco,
                          size: 18, color: kNotifColor),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(p['status'],
                            style: TextStyle(
                                fontSize: 11, color: statusColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpacing / 2),
                  Text(p['name'],
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: kSpacing / 2),
                  _buildMiniStat(EvaIcons.dropletOutline, '湿度',
                      '${p['humidity']}%', Colors.blueAccent),
                  const SizedBox(height: 4),
                  _buildMiniStat(EvaIcons.thermometerOutline, '温度',
                      '${p['temp']}°C', Colors.orangeAccent),
                  const SizedBox(height: 4),
                  _buildMiniStat(EvaIcons.sunOutline, '光照',
                      '${p['light']} lux', Colors.yellowAccent),
                ],
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildMiniStat(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 12, color: kFontColorPallets[2])),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildWaterRecords() {
    return Obx(() => Column(
          children: controller.waterRecords.map((r) {
            return Container(
              margin: const EdgeInsets.only(bottom: kSpacing / 2),
              padding: const EdgeInsets.symmetric(
                  horizontal: kSpacing, vertical: kSpacing * 0.75),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(38, 40, 55, 1),
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(EvaIcons.dropletOutline,
                        size: 16, color: Colors.blueAccent),
                  ),
                  const SizedBox(width: kSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['plant'],
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('浇水量：${r['amount']} ml',
                            style: TextStyle(
                                fontSize: 12, color: kFontColorPallets[2])),
                      ],
                    ),
                  ),
                  Text(r['time'],
                      style: TextStyle(
                          fontSize: 12, color: kFontColorPallets[2])),
                ],
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildAlertRecords() {
    return Obx(() => Column(
          children: controller.alertRecords.map((r) {
            final Color alertColor = r['level'] == '严重'
                ? Colors.redAccent
                : Colors.orangeAccent;
            return Container(
              margin: const EdgeInsets.only(bottom: kSpacing / 2),
              padding: const EdgeInsets.symmetric(
                  horizontal: kSpacing, vertical: kSpacing * 0.75),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(38, 40, 55, 1),
                borderRadius: BorderRadius.circular(kBorderRadius),
                border: Border.all(color: alertColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(EvaIcons.alertTriangleOutline,
                      size: 18, color: alertColor),
                  const SizedBox(width: kSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['message'],
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(r['plant'],
                            style: TextStyle(
                                fontSize: 12, color: kFontColorPallets[2])),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: alertColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(r['level'],
                            style: TextStyle(
                                fontSize: 11, color: alertColor)),
                      ),
                      const SizedBox(height: 4),
                      Text(r['time'],
                          style: TextStyle(
                              fontSize: 11, color: kFontColorPallets[2])),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ));
  }

  Color _statusColor(String status) {
    switch (status) {
      case '健康':
        return kNotifColor;
      case '需浇水':
        return Colors.blueAccent;
      case '缺光':
        return Colors.yellowAccent;
      case '告警':
        return Colors.redAccent;
      default:
        return kFontColorPallets[2];
    }
  }
}
