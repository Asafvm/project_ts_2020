import 'package:flutter/material.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/site.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactListTile extends StatelessWidget {
  final Contact contact;
  final String siteName;
  final Room room;

  ContactListTile({this.contact, this.siteName, this.room});

  @override
  Widget build(BuildContext context) {
    final String _emailLaunchUrl = 'mailto: ${contact.email}';
    final String _phoneLaunchUri = 'tel: ${contact.phone}';

    return ListTile(
      leading: Icon(Icons.person),
      title: Text(contact.getFullName()),
      subtitle: siteName != null
          ? Text('$siteName - ${room.toString()}')
          : Container(),
      trailing: SizedBox(
        width: 100,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: IconButton(
                    icon: Icon(Icons.phone),
                    onPressed: () async {
                      if (await canLaunch(_phoneLaunchUri)) {
                        await launch(_phoneLaunchUri);
                      } else {
                        throw 'Could not launch $_phoneLaunchUri';
                      }
                    })),
            Expanded(
                child: IconButton(
                    icon: Icon(Icons.mail),
                    onPressed: () async {
                      if (await canLaunch(_emailLaunchUrl)) {
                        await launch(_emailLaunchUrl);
                      } else {
                        throw 'Could not launch $_emailLaunchUrl';
                      }
                    })),
          ],
        ),
      ),
    );
  }
}
