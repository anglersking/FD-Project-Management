import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_management/app/constans/app_constants.dart';
import 'package:project_management/app/services/api_service.dart';

/// 植物近 N 天传感器历史折线图。
/// 进场调用 /device/data/?device_id=xxx 拉全部历史，
/// 取最近 [days] 天的数据，支持温度/土壤湿度/盐分/光照/电压切换。
class PlantHistoryChart extends StatefulWidget {
  const PlantHistoryChart({
    required this.deviceId,
    this.days = 7,
    Key? key,
  }) : super(key: key);

  final String deviceId;
  final int days;

  @override
  State<PlantHistoryChart> createState() => _PlantHistoryChartState();
}

/// 指标定义
class _Metric {
  final String key; // 后端字段
  final String label; // 显示名
  final String unit;
  final Color color;
  const _Metric(this.key, this.label, this.unit, this.color);
}

class _Point {
  final DateTime time; // 已 +8h
  final double value;
  const _Point(this.time, this.value);
}

class _PlantHistoryChartState extends State<PlantHistoryChart> {
  static const _metrics = <_Metric>[
    _Metric('T', '温度', '°C', Color(0xFFE57373)),
    _Metric('S', '土壤湿度', '%', Color(0xFF64B5F6)),
    _Metric('A', '盐分', '', Color(0xFFFFB74D)),
    _Metric('L', '光照', '', Color(0xFFFFD54F)),
    _Metric('V', '电压', 'V', Color(0xFF81C784)),
  ];

  int _selected = 0;
  bool _loading = true;
  String? _error;
  // device_id 的全部原始数据（按时间升序）
  List<Map<String, dynamic>> _raw = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await ApiService.getDeviceData(deviceId: widget.deviceId);
    if (!mounted) return;
    if (res.ok && res.data is List) {
      final list = (res.data as List)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
      // 后端按 received_at 倒序返回，这里转升序方便画图
      list.sort((a, b) {
        final ta = DateTime.tryParse('${a['received_at']}') ?? DateTime(1970);
        final tb = DateTime.tryParse('${b['received_at']}') ?? DateTime(1970);
        return ta.compareTo(tb);
      });
      setState(() {
        _raw = list;
        _loading = false;
      });
    } else {
      setState(() {
        _error = res.error ?? '加载失败';
        _loading = false;
      });
    }
  }

  /// 取当前选中指标、最近 days 天的点
  List<_Point> get _points {
    final m = _metrics[_selected];
    final cutoff =
        DateTime.now().toUtc().subtract(Duration(days: widget.days));
    final out = <_Point>[];
    for (final row in _raw) {
      final tUtc = DateTime.tryParse('${row['received_at']}');
      if (tUtc == null) continue;
      if (tUtc.toUtc().isBefore(cutoff)) continue;
      final v = row[m.key];
      if (v == null) continue;
      final dv = (v is num) ? v.toDouble() : double.tryParse('$v');
      if (dv == null) continue;
      // 电压后端为 mV，转成 V 显示
      final val = m.key == 'V' ? dv / 1000.0 : dv;
      // +8h 转中国时间用于显示
      out.add(_Point(tUtc.add(const Duration(hours: 8)), val));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "近 ${widget.days} 天趋势",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        // 指标切换
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _metrics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final m = _metrics[i];
              final sel = i == _selected;
              return ChoiceChip(
                label: Text(m.label),
                selected: sel,
                selectedColor: m.color.withOpacity(0.25),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: sel ? m.color : kFontColorPallets[1],
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) => setState(() => _selected = i),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(height: 200, child: _buildChartArea()),
      ],
    );
  }

  Widget _buildChartArea() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
                style: TextStyle(color: kFontColorPallets[2], fontSize: 12)),
            TextButton(onPressed: _load, child: const Text('重试')),
          ],
        ),
      );
    }
    final pts = _points;
    if (pts.length < 2) {
      return Center(
        child: Text('暂无足够的历史数据',
            style: TextStyle(color: kFontColorPallets[2], fontSize: 12)),
      );
    }

    final m = _metrics[_selected];
    final spots = <FlSpot>[];
    for (var i = 0; i < pts.length; i++) {
      spots.add(FlSpot(i.toDouble(), pts[i].value));
    }
    final values = pts.map((e) => e.value).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final pad = ((maxY - minY).abs() * 0.15) + 0.5;

    String two(int n) => n.toString().padLeft(2, '0');

    return LineChart(
      LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: kFontColorPallets[2].withOpacity(0.15),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) => Text(
                v.toStringAsFixed(0),
                style: TextStyle(
                    fontSize: 10, color: kFontColorPallets[2]),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: (pts.length / 4).ceilToDouble().clamp(1, 9999),
              getTitlesWidget: (v, _) {
                final i = v.round();
                if (i < 0 || i >= pts.length) {
                  return const SizedBox.shrink();
                }
                final t = pts[i].time;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${two(t.month)}/${two(t.day)}',
                    style: TextStyle(
                        fontSize: 9, color: kFontColorPallets[2]),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (items) => items.map((it) {
              final t = pts[it.x.round()].time;
              return LineTooltipItem(
                '${two(t.month)}/${two(t.day)} ${two(t.hour)}:${two(t.minute)}\n'
                '${it.y.toStringAsFixed(1)}${m.unit}',
                const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: m.color,
            barWidth: 2.5,
            dotData: FlDotData(show: pts.length <= 30),
            belowBarData: BarAreaData(
              show: true,
              color: m.color.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }
}
