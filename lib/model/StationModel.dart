//==============================================================================
// 1. Data Models & Centralized Mock Data Service
//==============================================================================

import 'package:latlong2/latlong.dart';

/// A model class for a station to ensure type safety.
class Station {
  final String id;
  final String location;
  final LatLng coordinates;
  final String status;
  final double currentLevel;
  final double sevenDayChange;
  final double criticalLevel;

  Station({
    required this.id,
    required this.location,
    required this.coordinates,
    required this.status,
    required this.currentLevel,
    required this.sevenDayChange,
    required this.criticalLevel,
  });
}

/// A centralized service to provide mock data throughout the app.
class MockDataService {
  static final List<Station> _stations = [
    Station(id: 'DWLR_CH_BMP_001', location: 'Champapur, Bihar', coordinates: const LatLng(25.7820, 87.5029), status: 'critical', currentLevel: 13.1, sevenDayChange: -0.4, criticalLevel: 12.0),
    Station(id: 'DWLR_RJ_JAI_001', location: 'Jaipur, Rajasthan', coordinates: const LatLng(26.9124, 75.7873), status: 'critical', currentLevel: 9.8, sevenDayChange: -0.9, criticalLevel: 10.0),
    Station(id: 'DWLR_MH_PUN_002', location: 'Pune, Maharashtra', coordinates: const LatLng(18.5204, 73.8567), status: 'moderate', currentLevel: 11.5, sevenDayChange: 0.2, criticalLevel: 11.0),
    Station(id: 'DWLR_KA_BLR_003', location: 'Bengaluru, Karnataka', coordinates: const LatLng(12.9716, 77.5946), status: 'safe', currentLevel: 14.2, sevenDayChange: -0.1, criticalLevel: 13.5),
    Station(id: 'DWLR_TN_CHE_004', location: 'Chennai, Tamil Nadu', coordinates: const LatLng(13.0827, 80.2707), status: 'safe', currentLevel: 10.3, sevenDayChange: 0.5, criticalLevel: 10.0),
    Station(id: 'DWLR_RJ_JOD_006', location: 'Jodhpur, Rajasthan', coordinates: const LatLng(26.2389, 73.0243), status: 'moderate', currentLevel: 10.8, sevenDayChange: -0.6, criticalLevel: 10.5),
    Station(id: 'DWLR_UP_LKN_008', location: 'Lucknow, Uttar Pradesh', coordinates: const LatLng(26.8467, 80.9462), status: 'safe', currentLevel: 15.0, sevenDayChange: 0.0, criticalLevel: 14.0),
  ];

  List<Station> getAllStations() => _stations;

  Station getStationById(String id) {
    return _stations.firstWhere((s) => s.id == id, orElse: () => _stations.first);
  }
}