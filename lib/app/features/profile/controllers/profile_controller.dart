import 'package:get/get.dart';

class ProfileController extends GetxController {
  final name = 'Admin User'.obs;
  final email = 'admin@example.com'.obs;
  final role = 'Plant Manager'.obs;
  final joinDate = 'June 2026'.obs;

  final devices = <Map<String, dynamic>>[
    {'name': 'Sensor-001', 'plant': '多肉小白', 'online': true},
    {'name': 'Sensor-002', 'plant': '绿萝', 'online': false},
    {'name': 'Sensor-003', 'plant': '仙人掌', 'online': true},
  ].obs;

  final plants = <Map<String, dynamic>>[
    {'name': '多肉小白', 'species': '拟石莲花属'},
    {'name': '绿萝', 'species': '天南星科'},
    {'name': '仙人掌', 'species': '仙人掌科'},
    {'name': '薰衣草', 'species': '唇形科'},
  ].obs;

  List<String> get availableDevices {
    final bound = devices.map((d) => d['name'] as String).toSet();
    return ['Sensor-004', 'Sensor-005', 'Sensor-006']
        .where((d) => !bound.contains(d))
        .toList();
  }

  void updateName(String newName) {
    if (newName.trim().isNotEmpty) name.value = newName.trim();
  }

  void unbindDevice(int index) {
    if (index >= 0 && index < devices.length) {
      devices.removeAt(index);
    }
  }

  void bindDevice(int plantIndex, String deviceName) {
    if (plantIndex >= 0 && plantIndex < plants.length) {
      devices.add({
        'name': deviceName,
        'plant': plants[plantIndex]['name'],
        'online': true,
      });
    }
  }
}
