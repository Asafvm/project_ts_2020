import 'dart:math';

import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:teamshare/screens/site/site_info_screen.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  final Site initialLocation;
  final bool isSelecting;

  MapScreen({this.initialLocation, this.isSelecting = false});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double latMax, lngMax, latMin, lngMin;
  LatLng _pickedLocation;
  Set<Marker> markers = Set<Marker>();

  Completer<GoogleMapController> _controller = Completer();

  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  @override
  Widget build(BuildContext context) {
    // List<Site> sitesList = Provider.of<List<Site>>(context);

    return MultiProvider(
      providers: [
        StreamProvider<List<Site>>.value(
          value: FirebaseFirestoreProvider.getSites(),
          initialData: [],
        ),
        StreamProvider<List<InstrumentInstance>>.value(
          value: FirebaseFirestoreProvider.getAllInstrumentsInstances(),
          initialData: [],
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('Map'),
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
        body: Consumer2<List<Site>, List<InstrumentInstance>>(
            builder: (context, sitesList, instanceList, child) =>
                _loadMap(sitesList, instanceList)),
      ),
    );
  }

  Widget _loadMap(List<Site> sitesList, List<InstrumentInstance> instanceList) {
    //calculate the center of an existing group of sites (if any)
    LatLng initialPos = LatLng(32.113540, 34.817882);
    if (sitesList.isNotEmpty) {
      latMax = sitesList.first.address.lat;
      lngMax = sitesList.first.address.lng;
      latMin = sitesList.first.address.lat;
      lngMin = sitesList.first.address.lng;
      sitesList.forEach((site) => {
            markers.add(new Marker(
                position: LatLng(site.address.lat, site.address.lng),
                onTap: () => _markerTap(site),
                icon: _colorSelector(instanceList, site.id),
                markerId: MarkerId(site.id))),
            if (site.address.lat > latMax) latMax = site.address.lat,
            if (site.address.lat < latMin) latMin = site.address.lat,
            if (site.address.lng > lngMax) lngMax = site.address.lng,
            if (site.address.lng < lngMin) lngMin = site.address.lng,
          });

      initialPos = LatLng((latMin + latMax) / 2.0,
          (lngMin + lngMax) / 2.0); //center of site cluster
      if (sitesList.isNotEmpty) _setLocation(initialPos, 12);
    }

    //map configurations
    return Stack(children: <Widget>[
      GoogleMap(
        initialCameraPosition: CameraPosition(
          target:
              sitesList.isNotEmpty ? initialPos : LatLng(32.113540, 34.817882),
          zoom: 13,
        ),
        zoomControlsEnabled: true,
        tiltGesturesEnabled: false,
        zoomGesturesEnabled: true,
        buildingsEnabled: true,
        onTap: (position) {
          _selectLocation(position);
          _customInfoWindowController.hideInfoWindow();
        },
        onCameraMove: (position) {
          _customInfoWindowController.onCameraMove();
        },
        onMapCreated: (GoogleMapController controller) async {
          _customInfoWindowController.googleMapController = controller;
          _controller.complete(controller);
          // _manager.setMapController(controller);
        },
        markers: markers,
      ),
      // _pickedLocation == null

      CustomInfoWindow(
        controller: _customInfoWindowController,
        height: 200,
        width: 200,
        offset: 50,
      ),
    ]);
  }

  void _markerTap(Site site) {
    _customInfoWindowController.addInfoWindow(
      Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 3)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        site.name,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        site.address.toString(),
                      ),
                    ),
                    Expanded(
                        child: OutlinedButton(
                      child: Text(
                        "Site Info",
                      ),
                      style: outlinedButtonStyle,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => MultiProvider(
                              providers: [
                                StreamProvider<List<Room>>(
                                  create: (context) =>
                                      FirebaseFirestoreProvider.getRooms(
                                          site.id),
                                  initialData: [],
                                ),
                                StreamProvider<List<Contact>>(
                                  create: (context) =>
                                      FirebaseFirestoreProvider.getContacts(),
                                  initialData: [],
                                ),
                                StreamProvider<List<Instrument>>(
                                  create: (context) => FirebaseFirestoreProvider
                                      .getInstruments(),
                                  initialData: [],
                                ),
                              ],
                              child: SiteInfoScreen(
                                site: site,
                              ),
                            ),
                          ),
                        );
                      },
                    )),
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
              color: Theme.of(context).primaryColor,
              width: 20.0,
              height: 10.0,
            ),
          ),
        ],
      ),
      LatLng(site.address.lat, site.address.lng),
    );
    _setLocation(LatLng(site.address.lat, site.address.lng));
  }

  void _addMarker(Marker marker) => markers.add(marker);

  void _selectLocation(LatLng position) {
    if (widget.isSelecting) {
      setState(() {
        _pickedLocation = position;
        _addMarker(Marker(markerId: MarkerId('1'), position: position));
      });
    }
  }

  Future<void> _setLocation(LatLng initialPos, [double zoom = 14]) async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(initialPos.latitude, initialPos.longitude),
        zoom: zoom,
      ),
    ));
  }

  BitmapDescriptor _colorSelector(
      List<InstrumentInstance> instanceList, String siteId) {
    double color = BitmapDescriptor.hueRed;
    List<InstrumentInstance> filtered = instanceList
        .where((instance) => instance.currentSiteId == siteId)
        .where((element) => element.nextMaintenance != null)
        .toList();

    if (filtered.isEmpty)
      return BitmapDescriptor.defaultMarkerWithHue(color);
    else {
      int minNextMaintance = filtered
          .reduce((value, element) =>
              min(value.nextMaintenance, element.nextMaintenance))
          .nextMaintenance;
      int diff = DateTime(minNextMaintance).difference(DateTime.now()).inDays;

      if (diff < 0)
        color = BitmapDescriptor.hueRed;
      else if (diff < 30)
        color = BitmapDescriptor.hueOrange;
      else
        color = BitmapDescriptor.hueGreen;
    }

    return BitmapDescriptor.defaultMarkerWithHue(color);
  }
}
