
//==============================================================================
// Comprehensive Analysis Screen (FIX for overflow)
//==============================================================================
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hydro/theme/appTheme.dart';
import 'package:intl/intl.dart';

enum AnalysisPeriod { monthly, yearly }
enum ChartType { rainfall, waterLevel }

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});
  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String _selectedState = 'Bihar';
  AnalysisPeriod _selectedPeriod = AnalysisPeriod.monthly;
  ChartType _selectedChart = ChartType.rainfall;
  static final Map<String, Map<String, dynamic>> stateData = {
    'Bihar': {'monthlyRain': [20.0, 30.0, 50.0, 80.0, 150.0, 250.0, 300.0, 280.0, 200.0, 100.0, 40.0, 20.0], 'monthlyLevel': [13.1, 13.0, 12.8, 12.5, 12.2, 12.5, 13.8, 14.2, 14.0, 13.5, 13.3, 13.2], 'yearlyRain': [1200.0, 1350.0, 1100.0, 1400.0, 1300.0], 'yearlyLevel': [13.5, 13.2, 13.4, 13.1, 12.9], 'avgLevel': 13.3, 'annualRain': 1320.5},
    'Rajasthan': {'monthlyRain': [5.0, 10.0, 15.0, 20.0, 30.0, 80.0, 150.0, 120.0, 60.0, 10.0, 5.0, 5.0], 'monthlyLevel': [10.5, 10.2, 10.0, 9.8, 9.6, 9.8, 10.8, 11.2, 11.0, 10.8, 10.6, 10.5], 'yearlyRain': [450.0, 550.0, 400.0, 600.0, 500.0], 'yearlyLevel': [10.8, 10.5, 10.7, 10.4, 10.2], 'avgLevel': 10.5, 'annualRain': 525.8},
    'Maharashtra': {'monthlyRain': [10.0, 15.0, 20.0, 40.0, 100.0, 280.0, 320.0, 250.0, 150.0, 80.0, 30.0, 10.0], 'monthlyLevel': [11.8, 11.6, 11.5, 11.2, 11.0, 11.4, 12.5, 12.8, 12.6, 12.2, 12.0, 11.9], 'yearlyRain': [950.0, 1100.0, 850.0, 1200.0, 1050.0], 'yearlyLevel': [12.2, 11.9, 12.1, 11.8, 11.6], 'avgLevel': 11.9, 'annualRain': 1045.2},
  };

  @override
  Widget build(BuildContext context) {
    final data = stateData[_selectedState]!;
    final bool isMonthly = _selectedPeriod == AnalysisPeriod.monthly;
    List<double> rainfall = isMonthly ? data['monthlyRain'] : data['yearlyRain'];
    List<double> waterLevel = isMonthly ? data['monthlyLevel'] : data['yearlyLevel'];
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildControlPanel(context),
        const SizedBox(height: 16),
        _buildMainContent(context, data, isMonthly, rainfall, waterLevel),
      ],
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Analysis Filters", style: Theme.of(context).textTheme.titleLarge),
              // FIX: Replaced the TextButton with a more compact IconButton to prevent overflow.
              IconButton(
                icon: const Icon(Icons.download_for_offline_outlined),
                tooltip: 'Download Report',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Downloading analysis report for $_selectedState...'),
                    backgroundColor: AppColors.fontTitle,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedState,
            decoration: InputDecoration(labelText: 'Select State', prefixIcon: const Icon(Icons.location_city_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            items: stateData.keys.map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedState = value);
            },
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: SegmentedButton<AnalysisPeriod>(
                segments: const [
                  ButtonSegment(value: AnalysisPeriod.monthly, label: Text('Monthly'), icon: Icon(Icons.calendar_view_month)),
                  ButtonSegment(value: AnalysisPeriod.yearly, label: Text('Yearly'), icon: Icon(Icons.calendar_today)),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (newSelection) => setState(() => _selectedPeriod = newSelection.first),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Map<String, dynamic> data, bool isMonthly, List<double> rainfall, List<double> waterLevel) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text("$_selectedState Data Visualization", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(children: [
            _buildStatCard(context, title: 'Avg. Water Level', value: '${data['avgLevel']} m', icon: Icons.water_drop_outlined, color: AppColors.secondary),
            const SizedBox(width: 16),
            _buildStatCard(context, title: 'Avg. Annual Rainfall', value: '${data['annualRain']} mm', icon: Icons.cloud_outlined, color: AppColors.primary),
          ]),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<ChartType>(
                  segments: const [
                    ButtonSegment(value: ChartType.rainfall, label: Text('Rainfall'), icon: Icon(Icons.bar_chart_rounded)),
                    ButtonSegment(value: ChartType.waterLevel, label: Text('Water Level'), icon: Icon(Icons.show_chart_rounded)),
                  ],
                  selected: {_selectedChart},
                  onSelectionChanged: (newSelection) => setState(() => _selectedChart = newSelection.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: _selectedChart == ChartType.rainfall ? _buildStateRainfallChart(context, isMonthly, rainfall) : _buildStateWaterLevelChart(context, isMonthly, waterLevel),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color)),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontSize: 22)),
        ]),
      ),
    );
  }

  Widget _buildStateRainfallChart(BuildContext context, bool isMonthly, List<double> rainfall) {
    const axisTextStyle = TextStyle(color: AppColors.fontBody, fontSize: 10);
    return BarChart(
      key: const ValueKey('rainfallChart'),
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(getTooltipColor: (_) => AppColors.fontTitle, getTooltipItem: (_, __, rod, ___) => BarTooltipItem('${rod.toY.toStringAsFixed(1)} mm', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        barGroups: List.generate(rainfall.length, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: rainfall[i], width: 20, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)), gradient: const LinearGradient(colors: [AppColors.primary, AppColors.chartLine], begin: Alignment.bottomCenter, end: Alignment.topCenter))])),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(), rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: axisTextStyle))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (value, meta) {
            if (isMonthly) {
              if (value.toInt() % 2 != 0) return const SizedBox();
              return Text(DateFormat('MMM').format(DateTime(0, value.toInt() + 1)), style: axisTextStyle);
            } else {
              final currentYear = DateTime.now().year;
              final startYear = currentYear - (rainfall.length - 1);
              return Text((startYear + value.toInt()).toString(), style: axisTextStyle);
            }
          })),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.chartGrid, strokeWidth: 1, dashArray: [3, 4])),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildStateWaterLevelChart(BuildContext context, bool isMonthly, List<double> waterLevel) {
    const axisTextStyle = TextStyle(color: AppColors.fontBody, fontSize: 10);
    return LineChart(
      key: const ValueKey('waterLevelChart'),
      LineChartData(
        lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(getTooltipColor: (_) => AppColors.fontTitle, getTooltipItems: (spots) => spots.map((spot) => LineTooltipItem('${spot.y.toStringAsFixed(1)} m', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))).toList())),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(waterLevel.length, (i) => FlSpot(i.toDouble(), waterLevel[i])),
            color: AppColors.secondary, barWidth: 4, isStrokeCapRound: true, isCurved: true, curveSmoothness: 0.35, dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.3), AppColors.secondary.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          )
        ],
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(), rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(1), style: axisTextStyle))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (value, meta) {
            if (isMonthly) {
              if (value.toInt() % 2 != 0) return const SizedBox();
              return Text(DateFormat('MMM').format(DateTime(0, value.toInt() + 1)), style: axisTextStyle);
            } else {
              final currentYear = DateTime.now().year;
              final startYear = currentYear - (waterLevel.length - 1);
              return Text((startYear + value.toInt()).toString(), style: axisTextStyle);
            }
          })),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.chartGrid, strokeWidth: 1, dashArray: [3, 4])),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}