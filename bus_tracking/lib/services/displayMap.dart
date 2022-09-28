import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

class displayMap extends StatefulWidget {
  const displayMap({Key? key}) : super(key: key);

  @override
  State<displayMap> createState() => _displayMapState();
}

class _displayMapState extends State<displayMap> {

    final PopupController _popupController = PopupController();
    MapController _mapController = MapController();
    double _zoom = 7;

  //   final List<LatLng> _latLngList = [
  //   LatLng(13, 77.5),
  //   LatLng(13.02, 77.51),
  //   LatLng(13.05, 77.53),
  //   LatLng(13.055, 77.54),
  //   LatLng(13.059, 77.55),
  //   LatLng(13.07, 77.55),
  //   LatLng(13.1, 77.5342),
  //   LatLng(13.12, 77.51),
  //   LatLng(13.015, 77.53),
  //   LatLng(13.155, 77.54),
  //   LatLng(13.159, 77.55),
  //   LatLng(13.17, 77.55),
  // ];
  final List<LatLng> _latLngList = [
    LatLng(15.518921, 74.925977)
  ];
  List<Marker> _markers = [];

    @override
  void initState() {
    _markers = _latLngList
        .map((pointe) => Marker(
              point: pointe,
              width: 60,
              height: 60,
              builder: (context) => const Icon(
                Icons.pin_drop,
                size: 60,
                color: Colors.blueAccent,
              ),
            ))
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('Map'),
        // ),
        body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            // swPanBoundary: LatLng(13, 77.5),
            // nePanBoundary: LatLng(13.07001, 77.58),
            center: _latLngList.elementAt(0),
            bounds: LatLngBounds.fromPoints(_latLngList),
            zoom: _zoom,
            plugins: [
              MarkerClusterPlugin(),
            ],
            
          ),
          layers: [
            TileLayerOptions(
              minZoom: 2,
              maxZoom: 18,
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
              polygonOptions: const PolygonOptions(
                  borderColor: Colors.blueAccent,
                  color: Colors.black12,
                  borderStrokeWidth: 3),
              
              builder: (context, markers) {
                return Container(
                  alignment: Alignment.center,
                  decoration:
                      const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  child: Text('${markers.length}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}