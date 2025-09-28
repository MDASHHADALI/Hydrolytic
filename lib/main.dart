import 'package:flutter/material.dart';

// Imports for packages
import 'package:hydro/regionalScreen.dart';
import 'package:hydro/stationScreen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'DashboardScreen.dart';
import 'alertScreen.dart';
import 'analysisScreen.dart';
import 'theme/appTheme.dart';







//==============================================================================
// App Entry Point
//==============================================================================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hydrolytic',
      theme: buildAppTheme(),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//==============================================================================
// Main Screen
//==============================================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _selectedStationId = 'DWLR_CH_BMP_001';

  void _navigateToStationDetails(String stationId) {
    setState(() {
      _selectedStationId = stationId;
      _selectedIndex = 2;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardView(navigateToTab: _onItemTapped, navigateToStation: _navigateToStationDetails),
      RegionalAnalysisScreen(onStationTap: _navigateToStationDetails),
      StationDetailsScreen(key: ValueKey(_selectedStationId), stationId: _selectedStationId),
      const AnalysisScreen(),
      AlertsScreen(navigateToStation: _navigateToStationDetails),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.water_drop_outlined, color: AppColors.primary, size: 28),
        title: Column(
          children: [
            Text(
              'Hydrolytic',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 5,),
            Text(
              'Deep Data. Clear Insights.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.fontBody,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            tooltip: 'Profile',
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Regional'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Station'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class AnomalyCard extends StatelessWidget {
  final Map<String, dynamic> anomaly;
  final Function(String) navigateToStation;
  const AnomalyCard({super.key, required this.anomaly, required this.navigateToStation});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (anomaly['severity']) {
      case 'critical':
        icon = Icons.error_rounded;
        color = AppColors.statusCritical;
        break;
      case 'low':
        icon = Icons.info_outline_rounded;
        color = AppColors.primary;
        break;
      default: // 'moderate'
        icon = Icons.warning_rounded;
        color = AppColors.statusModerate;
    }
    final gradient = LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)], begin: Alignment.topCenter, end: Alignment.bottomCenter);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.5), width: 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(gradient: gradient, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(anomaly['type'], style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color))),
            Text(anomaly['time'] ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(anomaly['location'], style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 24),
            Text('AI Insight:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(anomaly['insight'], style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: (anomaly['data'] as Map<String, String>).entries.map((entry) => Expanded(
                  child: Column(children: [
                    Text(entry.key, style: Theme.of(context).textTheme.bodySmall),
                    Text(entry.value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ]),
                )).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => navigateToStation(anomaly['stationId']),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Investigate'),
                style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
              ),
            )
          ]),
        ),
      ]),
    );
  }
}