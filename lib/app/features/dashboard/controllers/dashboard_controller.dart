part of dashboard;

class DashboardController extends GetxController {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    if (scaffoldKey.currentState != null) {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  // Data
  _Profile getProfil() {
    return const _Profile(
      photo: AssetImage(ImageRasterPath.avatar1),
      name: "Wanshan",
      email: "algersking5157@gmail.com",
    );
  }

  Future<List<TaskCardData>> getAllTask() async {
    try {
      final response = await http.get(
        Uri.parse("http://shanpetcare.vip.cpolar.cn/device/data"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('后端返回数据:');
        print(data);
        if (data.isEmpty) {
          return [];
        }
        final latest = data.first;
        // 解析字段
        final deviceId = latest["device_id"] ?? "Unknown Device";
        final temp = (latest["T"] ?? latest["temperature"] ?? 0).toDouble();
        final soil = (latest["S"] ?? 0).toDouble();
        final salt = (latest["A"] ?? 0).toDouble();
        final voltage = (latest["V"] ?? 0).toDouble();
        final receivedAt = latest["received_at"];
        // 加8小时
        String receivedAtStr = receivedAt;
        try {
          final dt = DateTime.parse(receivedAt).add(const Duration(hours: 8));
          receivedAtStr = dt.toString().replaceFirst(' ', 'T');
        } catch (_) {}
        final card = TaskCardData(
          title: deviceId,
          dueDay: 0, // today
          totalComments: temp.toInt(), // 温度
          type: TaskType.todo,
          totalContributors: 1,
          profilContributors: const [
            AssetImage(ImageRasterPath.hupilan),
          ],
          temperature: temp,
          soil: soil,
          salt: salt,
          voltage: voltage,
          receivedAt: receivedAtStr,
        );
        print('生成的TaskCardData:');
        print('id: ' + card.title + ', 温度: ' + card.temperature.toString() + ', 湿度: ' + card.soil.toString() + ', 盐分: ' + card.salt.toString() + ', 电压: ' + card.voltage.toString() + ', 上传: ' + (card.receivedAt ?? ''));
        return [card];
      } else {
        throw Exception("Failed to load device data");
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  ProjectCardData getSelectedProject() {
    return ProjectCardData(
      percent: .3,
      projectImage: const AssetImage(ImageRasterPath.logo1),
      projectName: "Marketplace Mobile",
      releaseTime: DateTime.now(),
    );
  }

  List<ProjectCardData> getActiveProject() {
    return [
      ProjectCardData(
        percent: .3,
        projectImage: const AssetImage(ImageRasterPath.logo2),
        projectName: "虎皮兰",
        releaseTime: DateTime.now().add(const Duration(days: 130)),
      ),
      ProjectCardData(
        percent: .5,
        projectImage: const AssetImage(ImageRasterPath.logo3),
        projectName: "多肉植物",
        releaseTime: DateTime.now().add(const Duration(days: 140)),
      ),
      ProjectCardData(
        percent: .8,
        projectImage: const AssetImage(ImageRasterPath.logo4),
        projectName: "绿箩🪴",
        releaseTime: DateTime.now().add(const Duration(days: 100)),
      ),
    ];
  }

  List<ImageProvider> getMember() {
    return const [
      AssetImage(ImageRasterPath.avatar1),
      AssetImage(ImageRasterPath.avatar2),
      AssetImage(ImageRasterPath.avatar3),
      AssetImage(ImageRasterPath.avatar4),
      AssetImage(ImageRasterPath.avatar5),
      AssetImage(ImageRasterPath.avatar6),
    ];
  }

  List<ChattingCardData> getChatting() {
    return const [
      ChattingCardData(
        image: AssetImage(ImageRasterPath.hupilan),
        isOnline: true,
        name: "虎皮兰",
        lastMessage: "我的状态健康,光照很开心,还能活100岁",
        isRead: false,
        totalUnread: 100,
      ),
      ChattingCardData(
        image: AssetImage(ImageRasterPath.avatar3),
        isOnline: false,
        name: "多肉植物",
        lastMessage: "和虎皮兰兄弟一样",
        isRead: true,
        totalUnread: 0,
      ),
      ChattingCardData(
        image: AssetImage(ImageRasterPath.avatar4),
        isOnline: true,
        name: "绿萝",
        lastMessage: "我要渴死了!太黑辣!给我施肥浇水!!不然死给你看",
        isRead: false,
        totalUnread: 1,
      ),
    ];
  }
}
