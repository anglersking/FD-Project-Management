part of dashboard;

class DashboardController extends GetxController {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Rxn<DashboardData> dashboard = Rxn<DashboardData>();
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        loadError.value = '未登录';
        isLoading.value = false;
        return;
      }
      final result = await ApiService.getDashboard(token: token);
      if (result.ok && result.data is Map) {
        dashboard.value =
            DashboardData.fromJson(result.data as Map<String, dynamic>);
      } else {
        loadError.value = result.error ?? '加载失败';
      }
    } catch (e) {
      loadError.value = '$e';
    } finally {
      isLoading.value = false;
    }
  }

  void openDrawer() {
    if (scaffoldKey.currentState != null) {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  // ----------------------------------------------------------------------
  // 顶部资料：用户名 + 手机号（后端无 email 字段）
  // ----------------------------------------------------------------------
  _Profile getProfil() {
    final d = dashboard.value;
    return _Profile(
      photo: const AssetImage(ImageRasterPath.avatar1),
      name: d?.username.isNotEmpty == true ? d!.username : "我的花园",
      email: d?.phone.isNotEmpty == true ? d!.phone : "—",
    );
  }

  // 当前选中的健康筛选
  final Rx<PlantHealth?> healthFilter = Rx<PlantHealth?>(null);

  List<PlantItem> get plants => dashboard.value?.plants ?? [];

  List<PlantItem> get filteredPlants {
    final f = healthFilter.value;
    if (f == null) return plants;
    return plants.where((p) => p.health == f).toList();
  }

  // 植物 → Task 卡片（应用健康筛选）
  List<TaskCardData> getTaskCards() {
    return filteredPlants.map((p) {
      final l = p.latest;
      return TaskCardData(
        title: p.plantName,
        dueDay: 0,
        totalComments: 0,
        totalContributors: 1,
        type: TaskType.todo,
        profilContributors: const [AssetImage(ImageRasterPath.hupilan)],
        temperature: l?.temperature,
        soil: l?.soil,
        salt: l?.salt,
        voltage: l?.voltage,
        receivedAt: l?.receivedAt,
        healthColor: p.health.color,
        healthLabel: p.health.label,
      );
    }).toList();
  }

  // 植物 → 存活植物详情卡片（环形进度=健康分）
  List<ProjectCardData> getActiveProject() {
    return plants.map((p) {
      return ProjectCardData(
        percent: (p.healthScore / 100).clamp(0.0, 1.0),
        projectImage: const AssetImage(ImageRasterPath.logo2),
        projectName: p.plantName,
        releaseTime: DateTime.now(),
      );
    }).toList();
  }

  // “已养绿植”卡片数字
  int get totalPlants => dashboard.value?.totalPlants ?? 0;
  int get needCareCount => dashboard.value?.needCareCount ?? 0;
  double get healthyPercent => dashboard.value?.healthyPercent ?? 0.0;

  // 花王榜（转成 ProgressCard 用的轻量结构）
  List<RankingEntry> getRankingEntries() {
    final r = dashboard.value?.ranking ?? [];
    return r
        .map((e) => RankingEntry(
              deviceId: e.deviceId,
              plantName: e.plantName,
              plantImage: e.plantImage,
              healthScore: e.healthScore,
            ))
        .toList();
  }

  // 根据 deviceId 查植物（点击花王榜弹详情用）
  PlantItem? findPlantById(String deviceId) {
    for (final p in plants) {
      if (p.deviceId == deviceId) return p;
    }
    return null;
  }

  // ----------------------------------------------------------------------
  // 植物拟人发言（最近消息区）
  // ----------------------------------------------------------------------
  List<ChattingCardData> getChatting() {
    final msgs = dashboard.value?.messages ?? [];
    if (msgs.isEmpty) return const [];
    return msgs.map((m) {
      return ChattingCardData(
        image: const AssetImage(ImageRasterPath.hupilan),
        isOnline: m.mood == 'happy',
        name: m.name,
        lastMessage: m.message,
        isRead: m.mood == 'happy',
        totalUnread: m.mood == 'sad' ? 1 : 0,
      );
    }).toList();
  }

  // ----------------------------------------------------------------------
  // 侧边栏选中项目（模板残留，保留默认）
  // ----------------------------------------------------------------------
  ProjectCardData getSelectedProject() {
    return ProjectCardData(
      percent: .3,
      projectImage: const AssetImage(ImageRasterPath.logo1),
      projectName: "我的花园",
      releaseTime: DateTime.now(),
    );
  }

  // 团队成员（模板残留，暂保留）
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
}
