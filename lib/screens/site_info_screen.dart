import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as widgets;
import 'package:teamshare/helpers/location_helper.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:url_launcher/url_launcher.dart';

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
          Column(
            children: [
              Text(
                widget.site.name,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: Image.network(
                      _previewImageUrl,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white),
                      child: Material(
                        child: Row(
                          children: [
                            IconButton(
                                splashColor: Theme.of(context).accentColor,
                                splashRadius: 20,
                                iconSize: 35,
                                color: Theme.of(context).primaryColor,
                                icon:
                                    Image.asset('assets/icons/googlemaps.png'),
                                tooltip: 'Directions',
                                onPressed: () => launchGoogleMaps(
                                    widget.site.address.lat,
                                    widget.site.address.lng)),
                            IconButton(
                                splashColor: Theme.of(context).accentColor,
                                splashRadius: 20,
                                iconSize: 35,
                                color: Theme.of(context).primaryColor,
                                icon: Image.asset('assets/icons/waze.png'),
                                tooltip: 'Directions',
                                onPressed: () => launchWaze(
                                    widget.site.address.lat,
                                    widget.site.address.lng)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  widget.site.address.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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

  void launchWaze(double lat, double lng) async {
    var url = 'waze://?ll=${lat.toString()},${lng.toString()}';
    var fallbackUrl =
        'https://waze.com/ul?ll=${lat.toString()},${lng.toString()}&navigate=yes';
    try {
      bool launched =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }

  void launchGoogleMaps(double lat, double lng) async {
    var url = 'google.navigation:q=${lat.toString()},${lng.toString()}';
    var fallbackUrl =
        'https://www.google.com/maps/search/?api=1&query=${lat.toString()},${lng.toString()}';
    try {
      bool launched =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }
}
