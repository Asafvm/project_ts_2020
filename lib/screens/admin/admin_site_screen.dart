import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/site/site_info_screen.dart';
import 'package:teamshare/widgets/forms/add_site_form.dart';
import 'package:teamshare/widgets/list_items/site_list_item.dart';

class AdminSiteScreen extends StatefulWidget {
  @override
  _AdminSiteScreenState createState() => _AdminSiteScreenState();
}

class _AdminSiteScreenState extends State<AdminSiteScreen> {
  @override
  Widget build(BuildContext context) {
    List<Site> _siteList = Provider.of<List<Site>>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Sites"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add_location_alt_rounded,
          color: Colors.white,
        ),
        onPressed: () => _openAddSite(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _siteList.isEmpty
            ? Center(child: Text("You haven't registered any sites yet"))
            : ListView.builder(
                key: UniqueKey(), //new Key(Strings.randomString(20)),
                itemBuilder: (ctx, index) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => MultiProvider(
                          providers: [
                            StreamProvider<List<Room>>(
                              create: (context) =>
                                  FirebaseFirestoreProvider.getRooms(
                                      _siteList.elementAt(index).id),
                              initialData: [],
                            ),
                            StreamProvider<List<Contact>>(
                              create: (context) =>
                                  FirebaseFirestoreProvider.getContacts(),
                              initialData: [],
                            ),
                            StreamProvider<List<Instrument>>(
                              create: (context) =>
                                  FirebaseFirestoreProvider.getInstruments(),
                              initialData: [],
                            ),
                          ],
                          child: SiteInfoScreen(
                            site: _siteList.elementAt(index),
                          ),
                        ),
                      ),
                    );
                  },
                  child: SiteItemList(
                      key: UniqueKey(), site: _siteList.elementAt(index)),
                ),
                itemCount: _siteList.length,
              ),
      ),
    );
  }

  void _openAddSite(BuildContext ctx) {
    showModalBottomSheet(
        enableDrag: false,
        isDismissible: true,
        context: ctx,
        builder: (_) {
          return AddSiteForm();
        }).whenComplete(() => setState(() {}));
  }
}
