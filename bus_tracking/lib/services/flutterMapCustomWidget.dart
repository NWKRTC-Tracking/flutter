
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:bus_tracking/presentation/my_flutter_app_icons.dart';
import 'package:latlong2/latlong.dart';

class FlutterMapCustomWidget extends StatelessWidget {
  const FlutterMapCustomWidget({
    super.key,
    required MapController mapController,
    required List<LatLng> latLngList,
    required double zoom,
    required List<Marker> markers,
  }) : _mapController = mapController, _latLngList = latLngList, _zoom = zoom, _markers = markers;

  final MapController _mapController;
  final List<LatLng> _latLngList;
  final double _zoom;
  final List<Marker> _markers;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        maxZoom: 18,
        minZoom: 4,
        center: _latLngList.elementAt(0),
        bounds: LatLngBounds.fromPoints(_latLngList),
        zoom: _zoom,
        interactiveFlags: InteractiveFlag.all,
        plugins: [
          MarkerClusterPlugin(),
        ],
      ),
      layers: [
        TileLayerOptions(
          minZoom: 2,
          maxZoom: 25,
        
          backgroundColor: Colors.black,
          // errorImage: ,
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerClusterLayerOptions(
          maxClusterRadius: 190,
          disableClusteringAtZoom: 16,
          size: const Size(50, 50),
          
          fitBoundsOptions: const FitBoundsOptions(
            padding: EdgeInsets.all(50),
          
          ),
          markers: _markers,
          // polygonOptions: const PolygonOptions(
          //     borderColor: Colors.blueAccent,
          //     color: Colors.black12,
          //     borderStrokeWidth: 3),
          builder: (context, markers) {
            return Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Colors.orange, shape: BoxShape.circle),
              child: Text('${markers.length}'),
            );
          },
        ),
      ],
    );
  }
}
