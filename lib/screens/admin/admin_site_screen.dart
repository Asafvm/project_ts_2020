import 'package:flutter/material.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/site/site_info_screen.dart';
import 'package:teamshare/widgets/forms/add_site_form.dart';
import 'package:teamshare/widgets/list_items/instrument_list_item.dart';
import 'package:teamshare/widgets/list_items/site_list_item.dart';

class AdminSiteScreen extends StatefulWidget {
  @override
  _AdminSiteScreenState createState() => _AdminSiteScreenState();
}

class _AdminSiteScreenState extends State<AdminSiteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Sites"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () => _openAddSite(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder(
          stream: FirebaseFirestoreProvider.getSites(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (!snapshot.hasData || snapshot.data.length == 0)
                return Center(
                    child: Text("You haven't registered any sites yet"));
              else
                return ListView.builder(
                  key: UniqueKey(), //new Key(Strings.randomString(20)),
                  itemBuilder: (ctx, index) => GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => SiteInfoScreen(
                            site: snapshot.data.elementAt(index),
                          ),
                        ),
                      );
                    },
                    child: SiteItemList(
                        key: UniqueKey(), site: snapshot.data.elementAt(index)),
                  ),
                  itemCount: snapshot.data.length,
                );
            } else
              return Center(child: CircularProgressIndicator());
          },
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
