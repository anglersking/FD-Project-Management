import 'package:flutter/material.dart';

/// 植物健康三态
enum PlantHealth { healthy, subhealthy, needCare }

extension PlantHealthX on PlantHealth {
  static PlantHealth fromString(String? v) {
    switch (v) {
      case 'healthy':
        return PlantHealth.healthy;
      case 'subhealthy':
        return PlantHealth.subhealthy;
      case 'need_care':
        return PlantHealth.needCare;
      default:
        return PlantHealth.needCare;
    }
  }

  String get label {
    switch (this) {
      case PlantHealth.healthy:
        return '健康';
      case PlantHealth.subhealthy:
        return '亚健康';
      case PlantHealth.needCare:
        return '需关照';
    }
  }

  Color get color {
    switch (this) {
      case PlantHealth.healthy:
        return const Color(0xFF4CAF50); // 绿
      case PlantHealth.subhealthy:
        return const Color(0xFFFFC107); // 黄
      case PlantHealth.needCare:
        return const Color(0xFFF44336); // 红
    }
  }
}

/// 最新一条传感器数据
class PlantLatest {
  final double? temperature; // T
  final double? soil; // S
  final double? salt; // A
  final double? light; // L
  final double? voltage; // V
  final String? receivedAt;

  const PlantLatest({
    this.temperature,
    this.soil,
    this.salt,
    this.light,
    this.voltage,
    this.receivedAt,
  });

  factory PlantLatest.fromJson(Map<String, dynamic> j) {
    double? d(dynamic v) => v == null ? null : (v as num).toDouble();
    return PlantLatest(
      temperature: d(j['T']),
      soil: d(j['S']),
      salt: d(j['A']),
      light: d(j['L']),
      voltage: d(j['V']),
      receivedAt: j['received_at'] as String?,
    );
  }
}

/// 单株植物
class PlantItem {
  final String deviceId;
  final String plantName;
  final String plantImage;
  final String plantImageNobg;
  final String plantImageSvg;
  final PlantHealth health;
  final int healthScore;
  final String advice;
  final PlantLatest? latest;

  const PlantItem({
    required this.deviceId,
    required this.plantName,
    required this.plantImage,
    required this.plantImageNobg,
    required this.plantImageSvg,
    required this.health,
    required this.healthScore,
    required this.advice,
    this.latest,
  });

  factory PlantItem.fromJson(Map<String, dynamic> j) {
    return PlantItem(
      deviceId: (j['device_id'] ?? '').toString(),
      plantName: (j['plant_name'] ?? '').toString(),
      plantImage: (j['plant_image'] ?? '').toString(),
      plantImageNobg: (j['plant_image_nobg'] ?? '').toString(),
      plantImageSvg: (j['plant_image_svg'] ?? '').toString(),
      health: PlantHealthX.fromString(j['health'] as String?),
      healthScore: (j['health_score'] ?? 0) is num
          ? (j['health_score'] as num).toInt()
          : 0,
      advice: (j['advice'] ?? '').toString(),
      latest: j['latest'] != null
          ? PlantLatest.fromJson(j['latest'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 花王榜条目
class RankingItem {
  final String deviceId;
  final String plantName;
  final String plantImage;
  final String plantImageNobg;
  final int healthScore;

  const RankingItem({
    required this.deviceId,
    required this.plantName,
    required this.plantImage,
    required this.plantImageNobg,
    required this.healthScore,
  });

  factory RankingItem.fromJson(Map<String, dynamic> j) {
    return RankingItem(
      deviceId: (j['device_id'] ?? '').toString(),
      plantName: (j['plant_name'] ?? '').toString(),
      plantImage: (j['plant_image'] ?? '').toString(),
      plantImageNobg: (j['plant_image_nobg'] ?? '').toString(),
      healthScore: (j['health_score'] ?? 0) is num
          ? (j['health_score'] as num).toInt()
          : 0,
    );
  }
}

/// 植物拟人发言
class PlantMessage {
  final String name;
  final String message;
  final String mood; // happy / normal / sad

  const PlantMessage({
    required this.name,
    required this.message,
    required this.mood,
  });

  factory PlantMessage.fromJson(Map<String, dynamic> j) {
    return PlantMessage(
      name: (j['name'] ?? '').toString(),
      message: (j['message'] ?? '').toString(),
      mood: (j['mood'] ?? 'normal').toString(),
    );
  }
}

/// 主页聚合数据
class DashboardData {
  final String username;
  final String phone;
  final String region;
  final int totalPlants;
  final int healthyCount;
  final int subhealthyCount;
  final int needCareCount;
  final double healthyPercent;
  final String? groupPhotoSvg;
  final List<RankingItem> ranking;
  final List<PlantItem> plants;
  final List<PlantMessage> messages;

  const DashboardData({
    required this.username,
    required this.phone,
    required this.region,
    required this.totalPlants,
    required this.healthyCount,
    required this.subhealthyCount,
    required this.needCareCount,
    required this.healthyPercent,
    required this.groupPhotoSvg,
    required this.ranking,
    required this.plants,
    required this.messages,
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) {
    final user = (j['user'] ?? {}) as Map<String, dynamic>;
    final summary = (j['status_summary'] ?? {}) as Map<String, dynamic>;
    return DashboardData(
      username: (user['username'] ?? '').toString(),
      phone: (user['phone'] ?? '').toString(),
      region: (user['region'] ?? '').toString(),
      totalPlants: (j['total_plants'] ?? 0) as int,
      healthyCount: (summary['healthy'] ?? 0) as int,
      subhealthyCount: (summary['subhealthy'] ?? 0) as int,
      needCareCount: (summary['need_care'] ?? 0) as int,
      healthyPercent: (j['healthy_percent'] ?? 0) is num
          ? (j['healthy_percent'] as num).toDouble()
          : 0.0,
      groupPhotoSvg: j['group_photo_svg'] as String?,
      ranking: ((j['ranking'] ?? []) as List)
          .map((e) => RankingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      plants: ((j['plants'] ?? []) as List)
          .map((e) => PlantItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: ((j['messages'] ?? []) as List)
          .map((e) => PlantMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
