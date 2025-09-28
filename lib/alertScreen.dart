//==============================================================================
// Alerts Screen
//==============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydro/theme/appTheme.dart';

import 'main.dart';

class AlertsScreen extends StatefulWidget {
  final Function(String) navigateToStation;
  const AlertsScreen({super.key, required this.navigateToStation});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  Set<NotificationDelivery> _selectedDelivery = {NotificationDelivery.push};

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activeAlerts = [
      {'type': 'Critical Depletion', 'stationId': 'DWLR_CH_BMP_001', 'location': 'Champapur, Bihar', 'severity': 'critical', 'insight': 'Water level dropped by 2.5m in 48 hours, crossing the critical threshold of 12.0m. Immediate intervention required.', 'data': {'Level Drop': '2.5m', 'Threshold': '12.0m'}, 'time': '15 mins ago'},
      {'type': 'Abnormal Recharge Rate', 'stationId': 'DWLR_RJ_JOD_006', 'location': 'Jodhpur, Rajasthan', 'severity': 'moderate', 'insight': 'Post-rainfall monitoring indicates a lower than expected recharge rate (0.1m/day vs historical 0.3m/day).', 'data': {'Actual': '0.1m/day', 'Expected': '0.3m/day'}, 'time': '2 hours ago'},
      {'type': 'Sensor Malfunction Suspected', 'stationId': 'DWLR_UP_LKN_008', 'location': 'Lucknow, Uttar Pradesh', 'severity': 'low', 'insight': 'DWLR readings have been static for 72 hours, despite fluctuating rainfall data in the catchment area.', 'data': {'Static Reading': '72 hours', 'Rainfall': 'Fluctuating'}, 'time': 'Yesterday'},
    ];
    return ListView(
      key: const PageStorageKey('alerts'),
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildNotificationSettingsCard(context),
        const Divider(height: 40),
        Text('Your Active Alerts', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (activeAlerts.isEmpty)
          _buildNoAlertsState(context)
        else
          ...activeAlerts.map((alert) => AnomalyCard(anomaly: alert, navigateToStation: widget.navigateToStation)).toList(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.8), AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 30),
          const SizedBox(width: 10),
          Text('Alerts & Notifications', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 4),
        Text('Manage your alert preferences and view active warnings.', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 14)),
      ]),
    );
  }

  Widget _buildNotificationSettingsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Delivery Preferences', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Center(
            child: ToggleButtons(
              isSelected: NotificationDelivery.values.map((e) => _selectedDelivery.contains(e)).toList(),
              onPressed: (index) => setState(() {
                final delivery = NotificationDelivery.values[index];
                _selectedDelivery.contains(delivery) ? _selectedDelivery.remove(delivery) : _selectedDelivery.add(delivery);
              }),
              borderRadius: BorderRadius.circular(10),
              selectedBorderColor: AppColors.primary,
              selectedColor: Colors.white,
              fillColor: AppColors.primary,
              color: AppColors.fontBody,
              splashColor: AppColors.primary.withOpacity(0.2),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.sms_outlined), Text('SMS')])),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.email_outlined), Text('Email')])),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.notifications_outlined), Text('Push')])),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Alert Thresholds', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildThresholdSlider(context, 'Critical Depletion', Colors.red, 0.5, (val) => print('Critical Depletion Threshold: $val')),
          _buildThresholdSlider(context, 'Abnormal Recharge', Colors.orange, 0.3, (val) => print('Abnormal Recharge Threshold: $val')),
          _buildThresholdSlider(context, 'Sensor Anomalies', Colors.blue, 0.7, (val) => print('Sensor Anomaly Threshold: $val')),
        ]),
      ),
    );
  }

  Widget _buildThresholdSlider(BuildContext context, String title, Color color, double initialValue, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(activeTrackColor: color, inactiveTrackColor: color.withOpacity(0.3), thumbColor: color, overlayColor: color.withOpacity(0.2), valueIndicatorColor: color, showValueIndicator: ShowValueIndicator.always, trackHeight: 6, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10), valueIndicatorTextStyle: const TextStyle(color: Colors.white)),
          child: Slider(value: initialValue, min: 0.0, max: 1.0, divisions: 10, label: (initialValue * 100).toInt().toString(), onChanged: onChanged),
        ),
      ]),
    );
  }

  Widget _buildNoAlertsState(BuildContext context) {
    return Card(
      elevation: 0, color: AppColors.card, margin: const EdgeInsets.symmetric(vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(children: [
          Icon(Icons.check_circle_outline_rounded, size: 80, color: AppColors.statusSafe.withOpacity(0.6)),
          const SizedBox(height: 16),
          Text('No Active Alerts', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.fontTitle)),
          const SizedBox(height: 8),
          Text('All monitored stations are operating within normal parameters.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => widget.navigateToStation('DWLR_CH_BMP_001'),
            icon: const Icon(Icons.line_axis), label: const Text('View All Stations'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          ),
        ]),
      ),
    );
  }
}

enum NotificationDelivery { sms, email, push }