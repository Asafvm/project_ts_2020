import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teamshare/models/site.dart';

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
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation == null
              ? LatLng(32.113540, 34.817882) // default = afeka's location
              : LatLng(widget.initialLocation.address.lat,
                  widget.initialLocation.address.lng),
          zoom: 18,
        ),
        onTap: _selectLocation,
        markers: markers, // _pickedLocation == null
      ),
    );
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
