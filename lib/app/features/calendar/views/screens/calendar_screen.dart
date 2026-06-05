import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/constans/app_constants.dart';
import '../../controllers/calendar_controller.dart';

class CalendarScreen extends GetView<CalendarController> {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(),
        backgroundColor: const Color.fromRGBO(128, 109, 255, 1),
        child: const Icon(EvaIcons.plus, color: Colors.white),
      ),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(kSpacing * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: kSpacing * 1.5),
            _buildCalendar(),
            const SizedBox(height: kSpacing * 1.5),
            _buildSectionTitle(EvaIcons.bellOutline, '本月提醒'),
            const SizedBox(height: kSpacing),
            _buildEventList(),
            const SizedBox(height: kSpacing * 3),
          ],
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
          'Calendar',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
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

  Widget _buildCalendar() {
    const weekDays = ['一', '二', '三', '四', '五', '六', '日'];
    return Obx(() {
      final days = controller.getDaysInMonth();
      final currentMonth = controller.currentMonth.value;
      final selectedDate = controller.selectedDate.value;

      return Container(
        padding: const EdgeInsets.all(kSpacing),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(38, 40, 55, 1),
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: controller.prevMonth,
                  icon: const Icon(EvaIcons.arrowIosBack,
                      color: Colors.white, size: 20),
                ),
                Text(
                  '${currentMonth.year}年${currentMonth.month}月',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                IconButton(
                  onPressed: controller.nextMonth,
                  icon: const Icon(EvaIcons.arrowIosForward,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: kSpacing / 2),
            Row(
              children: weekDays
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: kFontColorPallets[2],
                                  fontWeight: FontWeight.w500)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: kSpacing / 2),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
              itemBuilder: (context, index) {
                final day = days[index];
                if (day == null) return const SizedBox();

                final key =
                    '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                final hasEvent = controller.events.containsKey(key);
                final isSelected = day.year == selectedDate.year &&
                    day.month == selectedDate.month &&
                    day.day == selectedDate.day;
                final isToday = day.year == DateTime.now().year &&
                    day.month == DateTime.now().month &&
                    day.day == DateTime.now().day;

                return GestureDetector(
                  onTap: () => controller.selectDate(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromRGBO(128, 109, 255, 1)
                          : isToday
                              ? const Color.fromRGBO(128, 109, 255, 0.2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : kFontColorPallets[0],
                          ),
                        ),
                        if (hasEvent)
                          Positioned(
                            bottom: 4,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : kNotifColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Show selected day event
            Obx(() {
              final sd = controller.selectedDate.value;
              final key =
                  '${sd.year}-${sd.month.toString().padLeft(2, '0')}-${sd.day.toString().padLeft(2, '0')}';
              final event = controller.events[key];
              if (event == null) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: kSpacing),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(kSpacing * 0.75),
                  decoration: BoxDecoration(
                    color: kNotifColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(kBorderRadius / 2),
                    border: Border.all(color: kNotifColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(EvaIcons.calendarOutline,
                          size: 16, color: kNotifColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(event,
                            style: const TextStyle(
                                fontSize: 13, color: kNotifColor)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildEventList() {
    return Obx(() {
      final entries = controller.events.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      return Column(
        children: entries.map((e) {
          final parts = e.key.split('-');
          final dateStr = '${parts[0]}年${parts[1]}月${parts[2]}日';
          final color = _eventColor(e.value);
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
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_eventIcon(e.value), size: 16, color: color),
                ),
                const SizedBox(width: kSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.value,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(dateStr,
                          style: TextStyle(
                              fontSize: 12, color: kFontColorPallets[2])),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => controller.removeEvent(e.key),
                  icon: const Icon(EvaIcons.trash2Outline, size: 16),
                  color: Colors.redAccent.withOpacity(0.7),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Color _eventColor(String event) {
    if (event.contains('浇水')) return Colors.blueAccent;
    if (event.contains('施肥')) return Colors.greenAccent;
    if (event.contains('换盆')) return Colors.orangeAccent;
    return const Color.fromRGBO(128, 109, 255, 1);
  }

  IconData _eventIcon(String event) {
    if (event.contains('浇水')) return EvaIcons.dropletOutline;
    if (event.contains('施肥')) return Icons.eco;
    if (event.contains('换盆')) return EvaIcons.archiveOutline;
    return EvaIcons.calendarOutline;
  }

  void _showAddReminderDialog() {
    final messageCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color.fromRGBO(38, 40, 55, 1),
        title: const Text('添加提醒',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '提醒内容（如：给绿萝浇水）',
                labelStyle: TextStyle(
                    color: kFontColorPallets[2], fontSize: 13),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: kFontColorPallets[2].withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(kBorderRadius / 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(128, 109, 255, 1)),
                  borderRadius: BorderRadius.circular(kBorderRadius / 2),
                ),
              ),
            ),
          ],
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
              if (messageCtrl.text.trim().isNotEmpty) {
                final d = controller.selectedDate.value;
                final key =
                    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                controller.addEvent(key, messageCtrl.text.trim());
                Get.back();
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}
