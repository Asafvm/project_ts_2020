import 'package:flutter/material.dart';
import 'package:teamshare/helpers/location_helper.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/widgets/forms/add_room_form.dart';
import 'package:url_launcher/url_launcher.dart';

class SiteInfoScreen extends StatefulWidget {
  final Site site;

  const SiteInfoScreen({this.site});

  @override
  _SiteInfoScreenState createState() => _SiteInfoScreenState();
}

class _SiteInfoScreenState extends State<SiteInfoScreen>
    with SingleTickerProviderStateMixin {
  MediaQueryData mediaQuery;
  String _previewImageUrl;
  List<Room> rooms;
  var _buttonColor = Colors.green;

  var _buttonLocation = 30.0;

  TabController _tabController;
  List<Tab> _tabList = [
    Tab(text: "Rooms"),
    Tab(text: "Instruments"),
    Tab(text: "Contacts"),
  ];
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
    _tabController = TabController(length: _tabList.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _showPreview(widget.site.address.lat, widget.site.address.lng);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mediaQuery = MediaQuery.of(context);

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
                          style: BorderStyle.solid),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      indicatorColor: _buttonColor,
                      tabs: _tabList,
                    ),
                  ), //defined in cons(
                  Expanded(
                    child: Stack(
                      children: [
                        TabBarView(
                          children: [
                            //Rooms
                            FutureBuilder(
                              future: FirebaseFirestoreProvider.getRooms(
                                  widget.site.id),
                              initialData: [],
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                else
                                  return ListView.builder(
                                    itemBuilder: (context, index) {
                                      return Card(
                                        child: ListTile(
                                          title: Text(
                                              snapshot.data[index].roomTitle),
                                          subtitle: Text(
                                              snapshot.data[index].decription),
                                          trailing: FittedBox(
                                            child: Row(
                                              children: [
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.contact_phone_sharp,
                                                    ),
                                                    onPressed: () => {}),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.computer,
                                                    ),
                                                    onPressed: _registerInstrument),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: snapshot.data.length,
                                  );
                              },
                            ),

                            ///Instruments
                            Container(),
                            //Contacts
                            Container(),
                          ],
                        ),
                        Positioned(
                          bottom: mediaQuery.size.height * .02,
                          left: _buttonLocation,
                          child: FloatingActionButton(
                            onPressed: _tabActionButton,
                            backgroundColor: _buttonColor,
                            child: Icon(Icons.add),
                          ),
                        ),
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

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          _buttonColor = Colors.green;
          _buttonLocation = mediaQuery.size.width * .45;
          break;

        case 1:
          _buttonColor = Colors.orange;
          _buttonLocation = mediaQuery.size.width * .45;
          break;

        case 2:
          _buttonColor = Colors.red;
          _buttonLocation = mediaQuery.size.width * .8;
          break;
      }
      setState(() {});
    }
  }

  void _tabActionButton() {
    switch (_tabController.index) {
      case 0:
        _openAddRoomForm(context);
        break;

      case 1:
        break;

      case 2:
        break;
    }
  }

  void _openAddRoomForm(BuildContext ctx) {
    showModalBottomSheet(
        enableDrag: false,
        isDismissible: true,
        context: ctx,
        builder: (_) {
          return AddRoomForm(siteId: widget.site.id);
        }).whenComplete(() => setState(() {}));
  }

  void _registerInstrument() {

      


  }
}
