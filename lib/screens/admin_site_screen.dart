import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:teamshare/helpers/location_helper.dart';
import 'package:teamshare/providers/applogger.dart';
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
    } on Exception catch (e) {
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
            Container(
                width: double.infinity,
                height: 200,
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
                child: _previewImageUrl == null
                    ? Text('Choose a site')
                    : Image.network(_previewImageUrl)),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: Icon(Icons.location_on),
                  label: Text('Current Location'),
                ),
                FlatButton.icon(
                  onPressed: _selectOnMap,
                  icon: Icon(Icons.map),
                  label: Text('Select On Map'),
                ),
              ],
            )
          ],
        ));
  }
}
