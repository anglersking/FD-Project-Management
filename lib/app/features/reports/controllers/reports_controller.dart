import 'package:get/get.dart';

class ReportsController extends GetxController {
  final selectedPeriod = 0.obs;
  void setPeriod(int index) => selectedPeriod.value = index;

  final plantStatuses = <Map<String, dynamic>>[
    {'name': '多肉小白', 'status': '健康', 'humidity': 45, 'temp': 22, 'light': 3200},
    {'name': '绿萝', 'status': '需浇水', 'humidity': 18, 'temp': 24, 'light': 1800},
    {'name': '仙人掌', 'status': '健康', 'humidity': 12, 'temp': 28, 'light': 5000},
    {'name': '薰衣草', 'status': '缺光', 'humidity': 38, 'temp': 20, 'light': 400},
  ].obs;

  final waterRecords = <Map<String, dynamic>>[
    {'plant': '多肉小白', 'amount': 120, 'time': '今天 08:30'},
    {'plant': '绿萝', 'amount': 200, 'time': '今天 07:15'},
    {'plant': '薰衣草', 'amount': 150, 'time': '昨天 19:00'},
    {'plant': '仙人掌', 'amount': 80, 'time': '3天前'},
  ].obs;

  final alertRecords = <Map<String, dynamic>>[
    {'plant': '绿萝', 'message': '土壤湿度过低，需要浇水', 'level': '警告', 'time': '1小时前'},
    {'plant': '薰衣草', 'message': '光照不足，请移至窗边', 'level': '警告', 'time': '3小时前'},
    {'plant': 'Sensor-002', 'message': '传感器离线，请检查设备', 'level': '严重', 'time': '昨天'},
  ].obs;
}
