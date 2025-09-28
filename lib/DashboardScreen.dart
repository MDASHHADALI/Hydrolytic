//==============================================================================
// Dashboard View
//==============================================================================
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydro/theme/appTheme.dart';
import 'package:intl/intl.dart';

import 'main.dart';
import 'model/StationModel.dart';

class DashboardView extends StatelessWidget {
  final Function(int) navigateToTab;
  final Function(String) navigateToStation;
  const DashboardView({super.key, required this.navigateToTab, required this.navigateToStation});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('dashboard'),
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _buildLocalStationSnapshot(context)),
          const SizedBox(width: 16),
          Expanded(child: _buildWaterSecurityGauge(context)),
        ]),
        const SizedBox(height: 16),
        _buildRegionalStressChart(context),
        const SizedBox(height: 24),
        Text('Actionable Intelligence', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        _buildRecentAnomalies(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.8), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome, Analyst', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Summary for ${DateFormat.yMMMMd().format(DateTime.now())}', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 14)),
      ]),
    );
  }

  Widget _buildLocalStationSnapshot(BuildContext context) {
    final random = Random();
    final station = MockDataService().getStationById('DWLR_CH_BMP_001');
    final spots = List.generate(10, (i) => FlSpot(i.toDouble(), station.currentLevel + 0.5 + sin(i) * random.nextDouble()));

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () => navigateToStation(station.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Local Station', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
            Text(station.id, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Text('${station.currentLevel.toStringAsFixed(1)} m', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28, color: AppColors.primary)),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildWaterSecurityGauge(BuildContext context) {
    final securityValue = (55 + Random().nextInt(26)).toDouble();
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text('National Index', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Stack(alignment: Alignment.center, children: [
              Transform.rotate(
                angle: pi * 0.75,
                child: PieChart(PieChartData(startDegreeOffset: 0, sectionsSpace: 0, centerSpaceRadius: 40, sections: [
                  PieChartSectionData(value: securityValue, color: AppColors.secondary, radius: 20, showTitle: false),
                  PieChartSectionData(value: 100 - securityValue, color: AppColors.chartGrid, radius: 20, showTitle: false),
                ])),
              ),
              Positioned(
                bottom: 25,
                child: Column(children: [
                  Text('${securityValue.toInt()}%', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28, color: AppColors.secondary)),
                  Text('Secure', style: Theme.of(context).textTheme.bodyMedium),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildRegionalStressChart(BuildContext context) {
    final random = Random();
    final depleted = (10 + random.nextInt(16)).toDouble();
    final stressed = (25 + random.nextInt(21)).toDouble();
    final normal = 100 - depleted - stressed;
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text('Pan-India Water Stress', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(children: [
            const SizedBox(width: 5),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 150,
                child: Stack(alignment: Alignment.center, children: [
                  PieChart(PieChartData(sections: [
                    PieChartSectionData(color: AppColors.statusCritical, value: depleted, showTitle: false, radius: 25),
                    PieChartSectionData(color: AppColors.statusModerate, value: stressed, showTitle: false, radius: 25),
                    PieChartSectionData(color: AppColors.statusSafe, value: normal, showTitle: false, radius: 25),
                  ], sectionsSpace: 4, centerSpaceRadius: 50)),
                  Icon(Icons.pie_chart_outline_rounded, color: AppColors.fontBody.withOpacity(0.5), size: 40)
                ]),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 3,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Indicator(color: AppColors.statusCritical, text: 'Depleted', value: depleted),
                const SizedBox(height: 12),
                _Indicator(color: AppColors.statusModerate, text: 'Stressed', value: stressed),
                const SizedBox(height: 12),
                _Indicator(color: AppColors.statusSafe, text: 'Normal', value: normal),
              ]),
            )
          ]),
        ]),
      ),
    );
  }

  Widget _buildRecentAnomalies(BuildContext context) {
    final List<Map<String, dynamic>> anomalies = [
      {'type': 'Predictive Depletion Alert', 'stationId': 'DWLR_RJ_JAI_001', 'location': 'Jaipur, Rajasthan', 'severity': 'critical', 'insight': 'Depletion rate is 0.9m/week. With no rainfall forecasted, model predicts this well will cross the critical threshold of 10.0m within 2 weeks.', 'data': {'Current Trend': '-0.9m/week', 'Rain Forecast': '0mm (14d)'}, 'time': '30 mins ago'},
      {'type': 'Sensor Malfunction Suspected', 'stationId': 'DWLR_UP_LKN_008', 'location': 'Lucknow, UP', 'severity': 'low', 'insight': 'DWLR readings have been static for 72 hours. This is highly improbable and suggests a sensor fault or communication issue.', 'data': {'Static Reading': '72 hours', 'Status': 'Unchanged'}, 'time': 'Yesterday'},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: anomalies.map((anomaly) => AnomalyCard(anomaly: anomaly, navigateToStation: navigateToStation)).toList());
  }
}

//==============================================================================
// Shared Helper Widgets
//==============================================================================

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final double value;
  const _Indicator({required this.color, required this.text, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('${value.toStringAsFixed(1)}% of regions', style: Theme.of(context).textTheme.bodySmall)
        ]),
      )
    ]);
  }
}