import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:teamshare/helpers/location_helper.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/screens/map_screen.dart';

class SiteInfoScreen extends StatefulWidget {
  final Site site;

  const SiteInfoScreen({this.site});

  @override
  _SiteInfoScreenState createState() => _SiteInfoScreenState();
}

class _SiteInfoScreenState extends State<SiteInfoScreen> {
  String _previewImageUrl;

  void _showPreview(double lat, double lng) {
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
      lat: lat,
      lng: lng,
    );
    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  @override
  void initState() {
    _showPreview(widget.site.address.lat, widget.site.address.lng);
    super.initState();
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
                              : Image.network(
                                  _previewImageUrl,
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.directions),
                        tooltip: 'Directions',
                        onPressed: null, //TODO: open maps or waze
                      ),
                    ],
                  ),
                ),
                Flexible(
                    flex: 6,
                    fit: FlexFit.tight,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name'),
                          Text('City'),
                          Text('Street'),
                        ],
                      ),
                    )),
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
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: Colors.black,
                            style: BorderStyle.solid)),
                    child: tabSite,
                  ), //defined in cons(
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
