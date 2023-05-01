import 'dart:async';

import 'package:bus_tracking/pages/location.dart';
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
            // backgroundColor: widget.delay < 300 ? Color.fromARGB(255, 225, 245, 255) : Colors.red[400],
            flexibleSpace: Container(
              decoration: gradientBoxDecoration()
            ),
            title: const Text("NWKRTC"),
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
            // Column(
            //   children: [
            //     busLocationButton(),

            //     NorthButton(),
            //   ],
            // ),
            
            bottomDetailsSheet(widget.busNo, widget.delay, recenterMethod(), NorthButtonBlue()),

            ],
          ),
        ),
      ),
    );
  }

  Padding busLocationButton() {
    return Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 20, 30),
                child: Align(
                    alignment: Alignment.topRight,
                    // Location Recenter
                    child: recenterMethod(),
                  ),
              );
  }

  FloatingActionButton recenterMethod() {
    return FloatingActionButton(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,

                    onPressed: () {
                      _mapController.moveAndRotate(LatLng(widget.lat,widget.long), _zoom, 0.0);
                    },
                    child: Icon(MyFlutterApp.my_location)
                  );
  }

  Padding NorthButton() {
    return Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 20, 15),
                child: Align(
                    alignment: Alignment.topRight,
                    // add your floating action button
                    child: NorthButtonBlue(),
                  ),
              );
  }

  FloatingActionButton NorthButtonBlue() {
    return FloatingActionButton(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    onPressed: () {
                      
                      _mapController.rotate(0);
                    },
                    child: Icon(Icons.north_rounded)
                  );
  }
}

DraggableScrollableController _DSController = DraggableScrollableController();

/// Return the bottom widget with detals of bus and its position.
Widget bottomDetailsSheet(String? busNo, int? delay, Widget busLocationButton, Widget NorthButton) {

  TextStyle blackBoldTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  ListTile customListTile(String title, String subtitle) {
    return ListTile(
      title: Text(
        title,
        style: blackBoldTextStyle,
      ),
      subtitle: Text(
        subtitle,
        style: blackBoldTextStyle,
      ),
    );
  }


  return DraggableScrollableSheet(
    initialChildSize: .1,
    minChildSize: .1,
    maxChildSize: .3,
    controller: _DSController,
    builder: (BuildContext context, ScrollController scrollController) {
      return Container(
        // decoration: gradientBoxDecoration(),
        // color: Colors.grey[300],
        decoration: BoxDecoration(
        // color:  Color.fromARGB(255, 160, 206, 207),
        color: Colors.grey.shade300,
        gradient:gradientColor(),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
          )
      ),
        child: ListView(
          controller: scrollController,
          children: [
            draggableLine(),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                busLocationButton,
                dragUpButton(_DSController, scrollController),
                NorthButton
              ],
            ),
            
            customListTile("Last Updated", "${delay}s ago"),
            customListTile("Bus Number", busNo.toString()),
          ],
        ),
      );     
    },
  );
}

FloatingActionButton dragUpButton(DraggableScrollableController _DSController, ScrollController scrollController) {
  return FloatingActionButton(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  onPressed: () {
                    _DSController.jumpTo(0.3);
                  },
                  child: Icon(Icons.keyboard_double_arrow_up)
                );
}

BoxDecoration gradientBoxDecoration() {
  return BoxDecoration(
        color:  Colors.grey.shade300,
        gradient:gradientColor(),
        
      );
}

LinearGradient gradientColor() {
  return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF37474F),
            Color(0xFF1565C0),
          ],
        );
}

Column draggableLine() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    
    children: [
      Container(
        width: 50,
        height: 5,
        decoration: BoxDecoration(
          border: Border.all(),
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
      )
    ],
  );
}
