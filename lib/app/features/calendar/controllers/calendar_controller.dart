import 'package:get/get.dart';

class CalendarController extends GetxController {
  final currentMonth = DateTime.now().obs;
  final selectedDate = DateTime.now().obs;

  void prevMonth() {
    final d = currentMonth.value;
    currentMonth.value = DateTime(d.year, d.month - 1);
  }

  void nextMonth() {
    final d = currentMonth.value;
    currentMonth.value = DateTime(d.year, d.month + 1);
  }

  void selectDate(DateTime date) => selectedDate.value = date;

  List<DateTime?> getDaysInMonth() {
    final d = currentMonth.value;
    final firstDay = DateTime(d.year, d.month, 1);
    final daysInMonth = DateTime(d.year, d.month + 1, 0).day;
    final startOffset = (firstDay.weekday - 1) % 7;
    final List<DateTime?> days = List.filled(startOffset, null, growable: true);
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(d.year, d.month, i));
    }
    return days;
  }

  final events = <String, String>{
    '2026-06-05': '给绿萝浇水',
    '2026-06-10': '给薰衣草施肥',
    '2026-06-15': '检查仙人掌土壤',
    '2026-06-18': '多肉小白换盆',
    '2026-06-22': '给绿萝浇水',
    '2026-06-28': '全部植物施肥',
  }.obs;

  void addEvent(String dateKey, String message) {
    events[dateKey] = message;
  }

  void removeEvent(String dateKey) {
    events.remove(dateKey);
  }
}
