import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:teamshare/helpers/location_helper.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/screens/map_screen.dart';

class AdminSiteScreen extends StatefulWidget {
  @override
  _AdminSiteScreenState createState() => _AdminSiteScreenState();
}

class _AdminSiteScreenState extends State<AdminSiteScreen> {
  String _previewImageUrl;

  Future<void> _getCurrentLocation() async {
    try {
      final locData = await Location().getLocation();
      _showPreview(locData.latitude, locData.longitude);
    } on Exception catch (_) {
      return;
    }
  }

  void _showPreview(double lat, double lng) {
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
      lat: lat,
      lng: lng,
    );
    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  Future<void> _selectOnMap() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(
          initialLocation: null,
          isSelecting: true,
        ),
      ),
    );
    if (selectedLocation == null)
      return;
    else {
      _showPreview(selectedLocation.latitude, selectedLocation.longitude);
      String add = await LocationHelper.getPlaceAddress(
          selectedLocation.latitude, selectedLocation.longitude);
      Applogger.consoleLog(MessegeType.info, add);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Sites'),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 4,
            fit: FlexFit.tight,
            child: Row(
              children: [
                Flexible(
                  flex: 4,
                  fit: FlexFit.tight,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _previewImageUrl == null
                              ? Text('Choose a site')
                              : Image.network(_previewImageUrl),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(Icons.location_on),
                            tooltip: 'Current Location',
                            onPressed: _getCurrentLocation,
                          ),
                          IconButton(
                            icon: Icon(Icons.map),
                            tooltip: 'Select On Map',
                            onPressed: _selectOnMap,
                          ),
                          IconButton(
                            icon: Icon(Icons.directions),
                            tooltip: 'Directions',
                            onPressed: null, //TOFO: open maps or waze
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(flex: 6, fit: FlexFit.tight, child: Container()),
              ],
            ),
          ),
          Flexible(
            flex: 7,
            fit: FlexFit.tight,
            child: DefaultTabController(
              initialIndex: 0,
              length: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  tabSite, //defined in cons(
                  Expanded(
                    child: TabBarView(
                      children: [
                        //Rooms
                        Container(),

                        ///Instruments
                        Container(),
                        //Contacts
                        Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
