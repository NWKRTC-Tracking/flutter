import 'dart:async';

import 'package:bus_tracking/presentation/my_flutter_app_icons.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import 'package:latlong2/latlong.dart';
import'../presentation/my_flutter_app_icons.dart';
import'../presentation/BusLocation.dart';

class displayMap extends StatefulWidget {
  double lat, long;
  String busNo;
  int delay;
  displayMap({Key? key, required this.lat, required this.long, required this.busNo, required this.delay})
      : super(key: key);
  @override
  State<displayMap> createState() => _displayMapState();
}

class _displayMapState extends State<displayMap> {

  final PopupController _popupController = PopupController();
  MapController _mapController = MapController();
  final double _zoom = 12;

  List<LatLng> _latLngList = [];
  List<Marker> _markers = [];

  @override
  void initState() {
    setState(() {
      _latLngList = [LatLng(widget.lat, widget.long)];
    });
    _markers = _latLngList
        .map((pointe) => Marker(
              point: pointe,
              width: 60,
              height: 60,
              builder: (context) => const Icon(
                MyFlutterApp.location_on,
                size: 60,
                color: Colors.blueAccent,
              ),
            ))
        .toList();
    super.initState();
    anchorPos = AnchorPos.align(AnchorAlign.top);
  }

  late AnchorPos<dynamic> anchorPos;

  @override
  Widget build(BuildContext context) {
    if (widget.lat != null) {
      setState(() {
        _latLngList = [LatLng(widget.lat, widget.long)];
        _markers = _latLngList
            .map((pointe) => Marker(
                  point: pointe,
                  width: 60,
                  height: 60,
                  // builder: (context) => const Icon(
                  //   MyFlutterApp.location_on,
                  //   // Icons.bus_alert_outlined,
                  //   // ImageIcon(AssetImage('assets/bus.png')) ,
                  //   size: 60,
                  //   shadows: <Shadow>[Shadow(color: Colors.black, blurRadius: 1.0)],
                  //   color: Colors.black,
                  // ),
                  builder: (context) => const ImageIcon(
                      AssetImage("assets/images/bus.png"),
                      color: Colors.black,
                      size: 60,
                      
                  ),
                  anchorPos: anchorPos
                  
                ))
            .toList();
      });
    }
    return Expanded(
      child: SafeArea(
        child: Scaffold(
          //TODO
          // appBar: AppBar(
          //   elevation: 5,
          //  toolbarHeight: 80,
          //   backgroundColor: widget.delay < 300 ? Colors.blueGrey[800] : Colors.red[400],
          //   title: widget.delay < 300 ? Text('Bus No : ${widget.busNo} \nLast updated : ${widget.delay}s ago'):
          //                               Text('Bus No : ${widget.busNo} \nBus Status : Offline'),
          //   centerTitle: true,
          // ),
          appBar: AppBar(
            elevation: 5,
          //  toolbarHeight: 30,
            backgroundColor: widget.delay < 300 ? Colors.blueGrey[800] : Colors.red[400],
            title: Text("NWKRTC"),
            centerTitle: true,
          ),
          body: Stack(
            children: <Widget>[
            FlutterMap(
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
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 15, 20, 30),
                  child: Align(
                      alignment: Alignment.topRight,
                      // Location Recenter
                      child: FloatingActionButton(
                        backgroundColor: Colors.blue[800],
                        onPressed: () {
                          _mapController.moveAndRotate(LatLng(widget.lat,widget.long), _zoom, 0.0);
                        },
                        child: Icon(MyFlutterApp.my_location)
                      ),
                    ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(0, 30, 20, 15),
                  child: Align(
                      alignment: Alignment.topRight,
                      // add your floating action button
                      child: FloatingActionButton(
                        backgroundColor: Colors.blue[800],
                        onPressed: () {
                          // print('Location recenter');
                          // _mapController.move(LatLng(widget.lat,widget.long), _zoom);
                          // _mapController.moveAndRotate(center, zoom, degree)
                          _mapController.rotate(0);
                        },
                        child: Icon(Icons.north_rounded)
                      ),
                    ),
                ),
              ],
            ),
            
           
            ],
          ),
        ),
      ),
    );
  }
}
