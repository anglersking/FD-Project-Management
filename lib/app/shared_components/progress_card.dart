import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_management/app/constans/app_constants.dart';

/// 花王榜单条目（轻量，避免依赖 dashboard model）
class RankingEntry {
  final String deviceId;
  final String plantName;
  final String plantImage; // 网络图 URL，可空
  final int healthScore;

  const RankingEntry({
    required this.deviceId,
    required this.plantName,
    required this.plantImage,
    required this.healthScore,
  });
}

class ProgressCardData {
  final int totalUndone;
  final int totalTaskInProress;
  final List<RankingEntry> ranking;

  const ProgressCardData({
    required this.totalUndone,
    required this.totalTaskInProress,
    this.ranking = const [],
  });
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    required this.data,
    required this.onPressedCheck,
    this.onTapRanking,
    Key? key,
  }) : super(key: key);

  final ProgressCardData data;
  final Function() onPressedCheck;
  final Function(RankingEntry entry)? onTapRanking;

  @override
  Widget build(BuildContext context) {
    final top3 = data.ranking.take(3).toList();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(kBorderRadius),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Transform.translate(
                offset: const Offset(10, 30),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: SvgPicture.asset(
                    ImageVectorPath.hupilangif,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: kSpacing,
              top: kSpacing,
              bottom: kSpacing,
              right: kSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "你共养了 ${data.totalUndone} 种植物",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  "${data.totalTaskInProress} 株需要关照",
                  style: TextStyle(color: kFontColorPallets[1]),
                ),
                const SizedBox(height: kSpacing),
                // 花王排名
                Row(
                  children: [
                    const Text(
                      "花王排名",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: kSpacing / 2),
                if (top3.isEmpty)
                  Text(
                    "暂无排名数据",
                    style: TextStyle(
                        color: kFontColorPallets[2], fontSize: 12),
                  )
                else
                  ...List.generate(top3.length, (i) {
                    final e = top3[i];
                    return _RankRow(
                      rank: i + 1,
                      entry: e,
                      onTap: onTapRanking == null
                          ? null
                          : () => onTapRanking!(e),
                    );
                  }),
                const SizedBox(height: kSpacing / 2),
                ElevatedButton(
                  onPressed: onPressedCheck,
                  child: const Text("查看"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.entry,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final int rank;
  final RankingEntry entry;
  final Function()? onTap;

  Color get _medalColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // 金
      case 2:
        return const Color(0xFFC0C0C0); // 银
      case 3:
        return const Color(0xFFCD7F32); // 铜
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kBorderRadius / 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _medalColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                "$rank",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              backgroundImage: entry.plantImage.isNotEmpty
                  ? NetworkImage(entry.plantImage)
                  : const AssetImage(ImageRasterPath.hupilan) as ImageProvider,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.plantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Text(
              "${entry.healthScore}分",
              style: TextStyle(
                  fontSize: 12, color: kFontColorPallets[1]),
            ),
          ],
        ),
      ),
    );
  }
}
