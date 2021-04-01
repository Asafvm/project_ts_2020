import 'package:flutter/material.dart';
import 'package:teamshare/models/site.dart';

class SiteItemList extends StatelessWidget {
  final Site site;

  const SiteItemList({Key key, this.site}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).primaryColor, width: 3),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.location_city),
        ),
        title: Text(site.name),
        subtitle: Text(site.address.toString()),
      ),
    );
  }
}
