//==============================================================================
// Station Details Screen (FIX for overflow)
//==============================================================================
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hydro/theme/appTheme.dart';
import 'package:intl/intl.dart';

import 'model/StationModel.dart';

class StationDetailsScreen extends StatelessWidget {
  final String stationId;
  const StationDetailsScreen({super.key, required this.stationId});

  List<Map<String, dynamic>> _generateStationReadings(double baseLevel, int numberOfDays) {
    final random = Random(stationId.hashCode);
    final readings = <Map<String, dynamic>>[];
    for (int i = 0; i < numberOfDays; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final level = baseLevel + sin(i * pi / 15 + random.nextDouble()) * 0.8 + (random.nextDouble() - 0.5) * 0.4;
      final rainfall = random.nextDouble() * (i % 7 == 0 ? 40 : 5);
      final recharge = rainfall * (0.5 + random.nextDouble() * 0.4);
      readings.add({"date": date, "level": level, "rainfall": rainfall, "recharge": recharge});
    }
    return readings;
  }

  @override
  Widget build(BuildContext context) {
    final station = MockDataService().getStationById(stationId);
    return CustomScrollView(
      key: PageStorageKey('station_details_$stationId'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text('Station Analytics', style: Theme.of(context).textTheme.headlineSmall),
                // FIX: Replaced the TextButton with a more compact IconButton to prevent overflow.
                IconButton(
                  icon: const Icon(Icons.download_for_offline_outlined),
                  tooltip: 'Download Report',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Downloading report for $stationId...'),
                    backgroundColor: AppColors.fontTitle,
                    behavior: SnackBarBehavior.floating,
                  )),
                ),
              ]),
              Text(station.location, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 16),
              _buildKeyMetrics(context, station),
            ]),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: _buildHydrographCard(context, station)),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: _buildRainfallRechargeTabs(context, station)),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: _buildRecentReadingsTable(context, station)),
            const SizedBox(height: 16),
          ]),
        ),
      ],
    );
  }

  Widget _buildKeyMetrics(BuildContext context, Station station) {
    Color statusColor;
    IconData trendIcon;
    switch (station.status) {
      case 'critical':
      case 'Stressed': statusColor = AppColors.statusCritical; trendIcon = Icons.trending_down; break;
      case 'moderate': statusColor = AppColors.statusModerate; trendIcon = Icons.trending_up; break;
      default: statusColor = AppColors.statusSafe; trendIcon = Icons.trending_flat;
    }
    return Row(children: [
      _buildStatCard(context, title: 'Current Level', value: '${station.currentLevel} m', icon: Icons.water_drop, color: AppColors.primary),
      const SizedBox(width: 12),
      _buildStatCard(context, title: '7-Day Change', value: '${station.sevenDayChange} m', icon: trendIcon, color: statusColor),
      const SizedBox(width: 12),
      _buildStatCard(context, title: 'Aquifer Status', value: station.status, icon: Icons.shield_outlined, color: statusColor),
    ]);
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontSize: 18)),
          ]),
        ),
      ),
    );
  }

  Widget _buildHydrographCard(BuildContext context, Station station) {
    final readings = _generateStationReadings(station.currentLevel, 30);
    final spots = readings.reversed.map((entry) => FlSpot(readings.indexOf(entry).toDouble(), entry['level'])).toList();
    const axisTextStyle = TextStyle(color: AppColors.fontBody, fontSize: 12, fontWeight: FontWeight.bold);
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Groundwater Hydrograph', style: Theme.of(context).textTheme.titleLarge),
          Text('Last 30 days', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                minY: 8, maxY: 16,
                extraLinesData: ExtraLinesData(horizontalLines: [
                  HorizontalLine(y: station.criticalLevel, color: AppColors.statusCritical.withOpacity(0.8), strokeWidth: 2, dashArray: [8, 4], label: HorizontalLineLabel(show: true, labelResolver: (_) => 'Critical Level', alignment: Alignment.topRight, padding: const EdgeInsets.only(right: 5, bottom: 2), style: const TextStyle(color: AppColors.statusCritical, fontWeight: FontWeight.bold, fontSize: 12))),
                ]),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 25, interval: 2, getTitlesWidget: (value, meta) => (value == meta.max) ? const SizedBox.shrink() : Text(meta.formattedValue, style: const TextStyle(color: AppColors.fontBody, fontSize: 13))), axisNameWidget: const Text('Water Level (m)', style: axisTextStyle), axisNameSize: 22),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 7, getTitlesWidget: (value, meta) => (value == meta.max || value == meta.min) ? const SizedBox.shrink() : Text(DateFormat('d/M').format(DateTime.now().subtract(Duration(days: 29 - value.toInt()))), style: const TextStyle(color: AppColors.fontBody, fontSize: 13))), axisNameWidget: const Text('Date', style: axisTextStyle), axisNameSize: 30),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  ),
                ],
                lineTouchData: LineTouchData(handleBuiltInTouches: true, touchTooltipData: LineTouchTooltipData(getTooltipColor: (_) => AppColors.fontTitle, getTooltipItems: (touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final date = DateTime.now().subtract(Duration(days: 29 - barSpot.x.toInt()));
                    return LineTooltipItem('${DateFormat.MMMd().format(date)}\n', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), children: [TextSpan(text: '${barSpot.y.toStringAsFixed(2)} m', style: const TextStyle(color: Colors.white))]);
                  }).toList();
                })),
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.chartGrid, strokeWidth: 1, dashArray: [3, 4])),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildRainfallRechargeTabs(BuildContext context, Station station) {
    final readings = _generateStationReadings(station.currentLevel, 7);
    final rainfallData = readings.map((r) => r['rainfall'] as double).toList().reversed.toList();
    final rechargeData = readings.map((r) => r['recharge'] as double).toList().reversed.toList();
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: DefaultTabController(
        length: 2,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.all(16.0), child: Text('Hydrological Inputs (Last 7 Days)', style: Theme.of(context).textTheme.titleLarge)),
          const TabBar(tabs: [
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_outlined), SizedBox(width: 8), Text('Rainfall')])),
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.waterfall_chart_outlined), SizedBox(width: 8), Text('Recharge')])),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: TabBarView(clipBehavior: Clip.none, children: [
              Padding(padding: const EdgeInsets.all(16.0), child: _buildBarChart(context, 'Rainfall (mm)', rainfallData, AppColors.primary)),
              Padding(padding: const EdgeInsets.all(16.0), child: _buildBarChart(context, 'Estimated Recharge (mm)', rechargeData, null)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, String yAxisTitle, List<double> data, Color? barColor) {
    const axisTextStyle = TextStyle(color: AppColors.fontBody, fontSize: 10);
    Color getBarColor(double value) {
      if (barColor != null) return barColor;
      if (value < 7) return AppColors.statusCritical;
      if (value <= 20) return AppColors.statusModerate;
      return AppColors.statusSafe;
    }
    return BarChart(BarChartData(
        barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: data[i], color: getBarColor(data[i]), width: 20, borderRadius: BorderRadius.circular(4))])),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(), rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (value, meta) => (value == meta.max) ? const SizedBox.shrink() : Text(meta.formattedValue, style: const TextStyle(color: AppColors.fontBody, fontSize: 13))), axisNameWidget: Text(yAxisTitle, style: axisTextStyle), axisNameSize: 30),
          bottomTitles: AxisTitles(axisNameWidget: const Text('Date', style: axisTextStyle), sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text(DateFormat('d/M').format(DateTime.now().subtract(Duration(days: 6 - value.toInt()))), style: axisTextStyle))),
        ),
        gridData: const FlGridData(show: false)));
  }

  Widget _buildRecentReadingsTable(BuildContext context, Station station) {
    final readings = _generateStationReadings(station.currentLevel, 20);
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(16.0), child: Text('Recent Readings', style: Theme.of(context).textTheme.titleLarge)),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Expanded(flex: 3, child: Text('Date', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
            Expanded(flex: 2, child: Text('Level (m)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('Rain (mm)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
          ]),
        ),
        const Divider(height: 1),
        ...readings.map((item) {
          final isEven = readings.indexOf(item).isEven;
          return Container(
            color: isEven ? AppColors.background : AppColors.card,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(flex: 3, child: Text(DateFormat.yMMMd().format(item['date']))),
              Expanded(flex: 2, child: Text((item['level'] as double).toStringAsFixed(2), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text((item['rainfall'] as double).toStringAsFixed(1), textAlign: TextAlign.right)),
            ]),
          );
        }),
      ]),
    );
  }
}