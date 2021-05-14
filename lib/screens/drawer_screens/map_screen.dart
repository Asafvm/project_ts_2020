import 'dart:ui';

import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:teamshare/screens/site/site_info_screen.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  final Site initialLocation;
  final bool isSelecting;

  MapScreen({this.initialLocation, this.isSelecting = false});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _pickedLocation;
  Set<Marker> markers = Set<Marker>();
  //GoogleMapController mapController;
  ClusterManager _manager;
  List<Site> sitesList;

  // Completer<GoogleMapController> _controller = Completer();

  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  final CameraPosition _initialCameraPosition =
      CameraPosition(target: LatLng(32.113540, 34.817882), zoom: 12.0);

  List<ClusterItem<Location>> items = [
    for (int j = 0; j < 10; j++)
      ClusterItem(
        LatLng(32.113540 + j * 0.001, 34.817882 + j + 0.001),
      )
  ];

  @override
  void initState() {
    _manager = _initClusterManager();
    super.initState();
  }

  Widget _loadMap() {
    return StreamBuilder(
        stream: FirebaseFirestoreProvider.getSites(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text('Loading maps..');

          sitesList = snapshot.data;
          if (sitesList.isNotEmpty)
            for (int i = 0; i < sitesList.length; i++) {
              markers.add(new Marker(
                  position: LatLng(
                      sitesList[i].address.lat, sitesList[i].address.lng),
                  onTap: () {
                    _customInfoWindowController.addInfoWindow(
                      Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: Text(
                                      sitesList[i].name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                            color: Colors.blue,
                                            fontSize: 18,
                                          ),
                                    )),
                                    Expanded(
                                        child: Text(
                                      sitesList[i].address.houseNumber +
                                          "  " +
                                          sitesList[i].address.street +
                                          "\n" +
                                          sitesList[i].address.city +
                                          " , " +
                                          sitesList[i].address.country,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                            color: Colors.blue,
                                            fontSize: 12,
                                          ),
                                    )),
                                    Expanded(
                                        child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                              child: Text(
                                                "Site Info",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              style: TextButton.styleFrom(
                                                  backgroundColor: Colors.blue),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        MultiProvider(
                                                      providers: [
                                                        StreamProvider<
                                                            List<Room>>(
                                                          create: (context) =>
                                                              FirebaseFirestoreProvider
                                                                  .getRooms(
                                                                      sitesList[
                                                                              i]
                                                                          .id),
                                                          initialData: [],
                                                        ),
                                                        StreamProvider<
                                                            List<Contact>>(
                                                          create: (context) =>
                                                              FirebaseFirestoreProvider
                                                                  .getContacts(),
                                                          initialData: [],
                                                        ),
                                                        StreamProvider<
                                                            List<Instrument>>(
                                                          create: (context) =>
                                                              FirebaseFirestoreProvider
                                                                  .getInstruments(),
                                                          initialData: [],
                                                        ),
                                                      ],
                                                      child: SiteInfoScreen(
                                                        site: sitesList[i],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ))),
                                  ],
                                ),
                              ),
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Triangle.isosceles(
                            edge: Edge.BOTTOM,
                            child: Container(
                              color: Colors.white,
                              width: 20.0,
                              height: 10.0,
                            ),
                          ),
                        ],
                      ),
                      LatLng(
                          sitesList[i].address.lat, sitesList[i].address.lng),
                    );
                  },
                  icon: BitmapDescriptor.defaultMarker,
                  markerId: MarkerId(sitesList[i].id)));

              items = [
                for (int j = 0; j < 10; j++)
                  ClusterItem(
                    LatLng(sitesList[i].address.lat + j * 0.001,
                        sitesList[i].address.lng + j + 0.001),
                  )
              ];
            }

          return Stack(children: <Widget>[
            new GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialLocation == null
                    ? LatLng(32.113540, 34.817882) // default = afeka's location
                    : LatLng(widget.initialLocation.address.lat,
                        widget.initialLocation.address.lng),
                zoom: 10,
              ),
              onTap: (position) {
                _selectLocation(position);
                _customInfoWindowController.hideInfoWindow();
              },
              onCameraMove: (position) {
                _customInfoWindowController.onCameraMove();
              },
              onMapCreated: (GoogleMapController controller) async {
                _customInfoWindowController.googleMapController = controller;
                _manager.setMapController(controller);
              },

              markers: markers,
              // _pickedLocation == null
            ),
            CustomInfoWindow(
              controller: _customInfoWindowController,
              height: 200,
              width: 200,
              offset: 50,
            ),
          ]);
        });
  }

  void _addMarker(Marker marker) => markers.add(marker);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a Location'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _pickedLocation == null
                  ? null
                  : () {
                      Navigator.of(context).pop(_pickedLocation);
                    },
            ),
        ],
      ),
      body: _loadMap(),
    );
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<Location>(items, _updateMarkers,
        markerBuilder: _markerBuilder,
        initialZoom: _initialCameraPosition.zoom,
        stopClusteringZoom: 17.0);
  }

  void _updateMarkers(Set<Marker> markers) {
    print('Updated ${markers.length} markers');
    setState(() {
      this.markers = markers;
    });
  }

  static Future<Marker> Function(Cluster<Location>) get _markerBuilder =>
      (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            print('---- $cluster');
            cluster.items.forEach((p) => print(p));
          },
          icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
              text: cluster.isMultiple ? cluster.count.toString() : null),
        );
      };
  static Future<BitmapDescriptor> _getMarkerBitmap(int size, {String text}) async {
    if (kIsWeb) size = (size / 2).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.orange;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  void _selectLocation(LatLng position) {
    if (widget.isSelecting) {
      setState(() {
        _pickedLocation = position;
        _addMarker(Marker(markerId: MarkerId('1'), position: position));
      });
    }
  }
}
