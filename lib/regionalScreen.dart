//==============================================================================
// Regional Analysis Screen
//==============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hydro/theme/appTheme.dart';
import 'package:latlong2/latlong.dart';

import 'model/StationModel.dart';

class RegionalAnalysisScreen extends StatelessWidget {
  final Function(String) onStationTap;
  const RegionalAnalysisScreen({super.key, required this.onStationTap});

  @override
  Widget build(BuildContext context) {
    final stations = MockDataService().getAllStations();
    List<Marker> buildMarkers() {
      return stations.map((station) {
        Color markerColor;
        switch (station.status) {
          case 'critical': markerColor = AppColors.statusCritical; break;
          case 'moderate': markerColor = AppColors.statusModerate; break;
          default: markerColor = AppColors.statusSafe;
        }
        return Marker(
          width: 80.0, height: 80.0,
          point: station.coordinates,
          child: GestureDetector(
            onTap: () => onStationTap(station.id),
            child: Tooltip(
              message: "${station.id}\n${station.location}",
              child: Icon(Icons.location_pin, color: markerColor, size: 40.0),
            ),
          ),
        );
      }).toList();
    }

    return Scaffold(
      body: FlutterMap(
        key: const PageStorageKey('map'),
        options: const MapOptions(initialCenter: LatLng(25.7820, 87.5029), initialZoom: 5.0),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.myapp'),
          MarkerLayer(markers: buildMarkers()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showSearch(context: context, delegate: StationSearchDelegate(allStations: stations, onStationSelected: (stationId) {
            Navigator.of(context).pop();
            onStationTap(stationId);
          }));
        },
        tooltip: 'Search Stations',
        child: const Icon(Icons.search),
      ),
    );
  }
}

class StationSearchDelegate extends SearchDelegate<String> {
  final List<Station> allStations;
  final Function(String) onStationSelected;

  StationSearchDelegate({required this.allStations, required this.onStationSelected});

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final searchResults = allStations.where((station) {
      final stationId = station.id.toLowerCase();
      final location = station.location.toLowerCase();
      final searchQuery = query.toLowerCase();
      return stationId.contains(searchQuery) || location.contains(searchQuery);
    }).toList();
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final station = searchResults[index];
        return ListTile(
          leading: const Icon(Icons.analytics_outlined),
          title: Text(station.id),
          subtitle: Text(station.location),
          onTap: () => onStationSelected(station.id),
        );
      },
    );
  }
}
