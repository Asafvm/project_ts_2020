import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/helpers/location_helper.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/contact/contact_selection_screen.dart';
import 'package:teamshare/screens/instrument/instrument_selection_screen.dart';
import 'package:teamshare/widgets/forms/add_room_form.dart';
import 'package:teamshare/widgets/list_items/instrument_instance_list_item.dart';
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
    _showPreview(widget.site.address.lat, widget.site.address.lng);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Room> roomList = Provider.of<List<Room>>(context);
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
                      tabs: _tabList,
                    ),
                  ), //defined in cons(
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Stack(
                          children: [
                            //Rooms
                            ListView.builder(
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    title: Text(roomList[index].roomTitle),
                                    subtitle: Text(roomList[index].toString()),
                                    trailing: FittedBox(
                                      child: Row(
                                        children: [
                                          IconButton(
                                              icon: Icon(
                                                Icons.contact_phone_sharp,
                                              ),
                                              onPressed: () => _registeContact(
                                                  roomList[index].id)),
                                          IconButton(
                                              icon: Icon(
                                                Icons.computer,
                                              ),
                                              onPressed: () =>
                                                  _registerInstrument(
                                                      roomList[index].id)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: roomList.length,
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FloatingActionButton(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onPressed: () => _openAddRoomForm(context),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: Icon(Icons.add),
                                ),
                              ),
                            ),
                          ],
                        ),

                        ///Instruments
                        Container(
                            child: StreamBuilder<List<InstrumentInstance>>(
                          stream: FirebaseFirestoreProvider
                              .getAllInstrumentsInstances(),
                          initialData: [],
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<InstrumentInstance> list = snapshot.data
                                  .where((element) =>
                                      element.currentSiteId == widget.site.id)
                                  .toList();
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  return InstrumentInstanceListItem(
                                      Icons.computer,
                                      context,
                                      list[index].serial);
                                },
                              );
                            } else
                              return Container();
                          },
                        )),
                        //Contacts
                        Container(
                          child: Center(
                            child: Text("There"),
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

  Future<void> _registerInstrument(String room) async {
    List<InstrumentInstance> selected =
        await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return MultiProvider(
          providers: [
            StreamProvider<List<Instrument>>(
                create: (context) => FirebaseFirestoreProvider.getInstruments(),
                initialData: []),
            StreamProvider<List<InstrumentInstance>>(
                create: (context) =>
                    FirebaseFirestoreProvider.getAllInstrumentsInstances(),
                initialData: []),
          ],
          child: InstrumentSelectionScreen(
            siteId: widget.site.id,
            roomId: room,
          ),
        );
      },
    ));

    await FirebaseFirestoreCloudFunctions.linkInstruments(
        selected, widget.site.id, room);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Relocation completed!')));
  }

  void _openAddRoomForm(BuildContext context) {
    showModalBottomSheet(
        enableDrag: false,
        isDismissible: true,
        context: context,
        builder: (_) {
          return AddRoomForm(siteId: widget.site.id);
        }).whenComplete(() => setState(() {}));
  }

  _registeContact(String room) async {
    List<Contact> selected = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return MultiProvider(
          providers: [
            StreamProvider<List<Contact>>(
                create: (context) => FirebaseFirestoreProvider.getContacts(),
                initialData: []),
          ],
          child: ContactSelectionScreen(
            siteId: widget.site.id,
            roomId: room,
          ),
        );
      },
    ));

    await FirebaseFirestoreCloudFunctions.linkContacts(
        selected, widget.site.id, room);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Assigning completed!')));
  }
}
