import 'package:get/get.dart';

class EmailData {
  final String sender;
  final String subject;
  final String preview;
  final String time;
  bool isRead;

  EmailData({
    required this.sender,
    required this.subject,
    required this.preview,
    required this.time,
    required this.isRead,
  });
}

class EmailController extends GetxController {
  final selectedIndex = (-1).obs;

  final emails = <EmailData>[
    EmailData(
      sender: '植物监控系统',
      subject: '🪴 绿萝需要浇水了',
      preview: '您的绿萝土壤湿度已降至18%，低于安全阈值（30%），建议尽快浇水。当前温度24°C，适合浇水。',
      time: '刚刚',
      isRead: false,
    ),
    EmailData(
      sender: '植物监控系统',
      subject: '⚠️ Sensor-002 设备离线',
      preview: '传感器 Sensor-002（绑定植物：绿萝）已离线超过2小时，请检查设备电源和网络连接。',
      time: '1小时前',
      isRead: false,
    ),
    EmailData(
      sender: '植物监控系统',
      subject: '🌿 薰衣草光照不足提醒',
      preview: '您的薰衣草当前光照强度仅 400 lux，建议移至光线更充足的位置，薰衣草适宜光照为 2000-3000 lux。',
      time: '3小时前',
      isRead: false,
    ),
    EmailData(
      sender: '植物监控系统',
      subject: '✅ 多肉小白状态良好',
      preview: '您的多肉小白当前状态：湿度45%，温度22°C，光照3200 lux，一切正常！',
      time: '今天 08:30',
      isRead: true,
    ),
    EmailData(
      sender: '植物监控系统',
      subject: '📅 提醒：今日给薰衣草施肥',
      preview: '根据您设置的浇水计划，今天是给薰衣草施肥的日期，请不要忘记哦！',
      time: '昨天',
      isRead: true,
    ),
  ].obs;

  void selectEmail(int index) {
    if (selectedIndex.value == index) {
      selectedIndex.value = -1;
    } else {
      selectedIndex.value = index;
      if (!emails[index].isRead) markAsRead(index);
    }
  }

  void markAsRead(int index) {
    emails[index].isRead = true;
    emails.refresh();
  }

  void deleteEmail(int index) {
    emails.removeAt(index);
    selectedIndex.value = -1;
  }
}
