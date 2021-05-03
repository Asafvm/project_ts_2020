import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/widgets/list_items/member_list_item.dart';

class AdminTeamManagmentScreen extends StatefulWidget {
  @override
  _AdminTeamManagmentScreenState createState() =>
      _AdminTeamManagmentScreenState();
}

class _AdminTeamManagmentScreenState extends State<AdminTeamManagmentScreen> {
  Team currentTeam = TeamProvider().getCurrentTeam;
  List<String> members = [];
  final scaffoldState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    members = Provider.of<List<String>>(context);
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text("Team Managment"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                InkWell(
                  onTap: () => _takePicture(context),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: currentTeam.logoUrl == null
                              ? AssetImage('assets/pics/unknown.jpg')
                              : NetworkImage(currentTeam.logoUrl),
                          fit: BoxFit.fitHeight),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.person_add),
                    onPressed: () => _pickContact(context),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editTeamName(context),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    currentTeam.name,
                    style: TextStyle(fontSize: 26),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              currentTeam.description,
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: members.length,
                itemBuilder: (BuildContext context, int index) {
                  return MemberListItem(
                    key: UniqueKey(),
                    name: members.elementAt(index),
                    removeFunction:
                        members.elementAt(index) == currentTeam.creatorEmail
                            ? null
                            : () {},
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _takePicture(BuildContext context) {
    scaffoldState.currentState.showBottomSheet(
      (context) {
        return Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Colors.black,
                      width: 2,
                      style: BorderStyle.solid))),
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: IconButton(
                    icon: Icon(Icons.photo), onPressed: _pickFromGallery),
              ),
              Expanded(
                child: IconButton(
                    icon: Icon(Icons.camera_alt_rounded),
                    onPressed: _pickFromCamera),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickContact(BuildContext context) {
    scaffoldState.currentState.showBottomSheet(
      (context) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: Colors.black, width: 2, style: BorderStyle.solid),
            ),
          ),
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: IconButton(
                    icon: Icon(Icons.contact_mail),
                    onPressed: _pickFromContacts),
              ),
              Expanded(
                child: IconButton(
                    icon: Icon(Icons.keyboard), onPressed: _writeManualy),
              ),
            ],
          ),
        );
      },
    );
  }

  Future _pickFromGallery() async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxHeight: 100,
      maxWidth: 100,
    );

    await FirebaseFirestoreCloudFunctions.updateTeamLogo(
            teamid: currentTeam.id, url: imageFile.path)
        .then((_) => currentTeam.logoUrl = imageFile.path);
  }

  Future _pickFromCamera() async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxHeight: 100,
      maxWidth: 100,
    );

    await FirebaseFirestoreCloudFunctions.updateTeamLogo(
            teamid: currentTeam.id, url: imageFile.path)
        .then((_) => currentTeam.logoUrl = imageFile.path);
  }

  Future _pickFromContacts() async {
    final EmailContact contact =
        await FlutterContactPicker.pickEmailContact(askForPermission: true);
    if (contact != null) {
      setState(() {
        members.add(contact.email.email);
      });
      await FirebaseFirestoreCloudFunctions.addTeamMember(
          currentTeam.id, [contact.email.email]);
    }
  }

  Future _writeManualy() async {
    TextEditingController _textController = TextEditingController();
    bool _valid = true;

    return showDialog(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Enter Email"),
              content: TextField(
                controller: _textController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _valid ? null : "Must be a valid email",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (_textController.text.isEmpty ||
                        !emailRegExp.hasMatch(_textController.text)) {
                      setState(() {
                        _valid = false;
                      });
                    } else {
                      setState(() {
                        _valid = true;
                        members.add(_textController.text);
                      });

                      await FirebaseFirestoreCloudFunctions.addTeamMember(
                          currentTeam.id, [_textController.text]);
                      Navigator.of(context).pop("");
                    }
                  },
                  child: Text(
                    "OK",
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop("");
                  },
                  child: Text(
                    "Cancel",
                  ),
                ),
              ],
              elevation: 10,
            );
          },
        );
      },
      context: context,
    );
  }

  _editTeamName(BuildContext context) {
    scaffoldState.currentState.showBottomSheet((context) {
      final teamText = TextEditingController();
      final descText = TextEditingController();

      teamText.text = currentTeam.name;
      descText.text = currentTeam.description;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: teamText,
              decoration: InputDecoration(hintText: "Team Name"),
              maxLines: 1,
              maxLength: 40,
            ),
            TextField(
              controller: descText,
              decoration: InputDecoration(hintText: "Description"),
              maxLength: 200,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      FirebaseFirestoreCloudFunctions.updateTeam(
                          teamid: currentTeam.id,
                          data: {
                            'name': teamText.text,
                            'description': descText.text
                          });
                    },
                    child: Text("Save")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel"))
              ],
            )
          ],
        ),
      );
    });
  }
}
