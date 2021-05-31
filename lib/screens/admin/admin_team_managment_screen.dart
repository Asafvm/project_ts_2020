import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/helpers/picker_helper.dart';
import 'package:teamshare/models/team.dart';
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
  Map<String, bool> members = Map<String, bool>();
  List<String> membersToRemove = List<String>.empty(growable: true);
  final scaffoldState = GlobalKey<ScaffoldState>();
  bool _isExpanded = false;
  int _maxLines = 2;
  bool _changedMembers = false;
  bool _changedDetails = false;
  bool _changedLogo = false;
  double _progress = 0;

  bool _updating = false;

  bool _init = true;

  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty)
      members = Map<String, bool>.fromEntries(
          Provider.of<Iterable<MapEntry<String, bool>>>(context,
              listen: _init)); //stop listening if data recieved

    return WillPopScope(
      onWillPop: () async => _editing ? false : true,
      child: Scaffold(
        key: scaffoldState,
        appBar: AppBar(
          title: Text("Team Managment"),
          actions: [
            if (!_editing)
              IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _changedDetails ||
                          _changedLogo ||
                          _changedMembers ||
                          membersToRemove.isNotEmpty
                      ? () async {
                          await _updateTeam();
                          setState(() {
                            _init = false;
                            _changedDetails = false;
                            _changedLogo = false;
                            _changedMembers = false;
                          });
                        }
                      : null)
          ],
        ),
        body: _updating
            ? Center(
                child: CircularProgressIndicator(
                  value: _progress,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () async {
                            String _img = await PickerHelper.takePicture(
                                context: context,
                                fileName: 'logoUrl',
                                uploadPath: null);
                            if (_img.isNotEmpty)
                              setState(() {
                                currentTeam.logoUrl = _img;
                                _changedLogo = true;
                              });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: currentTeam.logoUrl == null
                                      ? AssetImage(
                                          'assets/pics/unknown.jpg') //no pic
                                      : currentTeam.logoUrl.contains("http")
                                          ? NetworkImage(currentTeam
                                              .logoUrl) //cloud storage pic
                                          : Image.file(
                                                  File(currentTeam.logoUrl))
                                              .image, //local pic
                                  fit: BoxFit.fitHeight),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: Icon(Icons.person_add),
                            onPressed: () async {
                              String contact =
                                  await PickerHelper.pickContact(context);
                              if (contact != null && contact.isNotEmpty) {
                                setState(() {
                                  members
                                      .addEntries([MapEntry(contact, false)]);
                                  _changedMembers = true;
                                });
                              }
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              setState(() {
                                _editing = true;
                              });
                              await _editTeamName(context);
                            },
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
                    child: Container(
                      color: Colors.black12,
                      padding: const EdgeInsets.all(15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          currentTeam.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: _isExpanded ? null : _maxLines,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: members.keys.length,
                        itemBuilder: (BuildContext context, int index) {
                          return MemberListItem(
                            key: UniqueKey(),
                            name: members.keys.elementAt(index),
                            isSelected: members[members.keys.elementAt(index)],
                            onSwitch: (String name, bool value) {
                              members[name] = value;
                              _changedMembers = true;
                            },
                            onRemove: members.keys.elementAt(index) ==
                                    currentTeam.creatorEmail
                                ? null
                                : (String name) {
                                    setState(() {
                                      members.remove(name);
                                      membersToRemove.add(name);
                                    });
                                  },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _editTeamName(BuildContext context) {
    return scaffoldState.currentState.showBottomSheet((context) {
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
              maxLines: null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                    style: outlinedButtonStyle,
                    onPressed: () {
                      setState(() {
                        _editing = false;
                        currentTeam.name = teamText.text;
                        currentTeam.description = descText.text;
                        _changedDetails = true;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text("Save")),
                OutlinedButton(
                    style: outlinedButtonStyle,
                    onPressed: () {
                      setState(() {
                        _editing = false;
                      });
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

  Future<void> _updateTeam() async {
    setState(() {
      _updating = true;
      _progress = 0;
    });
    if (!(currentTeam.logoUrl == null) &&
        !currentTeam.logoUrl.contains("http") &&
        _changedLogo)
      await FirebaseFirestoreCloudFunctions.updateTeamLogo(
          teamid: currentTeam.id, url: currentTeam.logoUrl);
    setState(() {
      _progress = 30;
    });
    if (_changedMembers)
      await FirebaseFirestoreCloudFunctions.addTeamMember(
          currentTeam.id, members);
    setState(() {
      _progress = 50;
    });
    if (membersToRemove.isNotEmpty)
      await FirebaseFirestoreCloudFunctions.removeTeamMember(
          currentTeam.id, membersToRemove);
    setState(() {
      _progress = 70;
    });
    if (_changedDetails)
      await FirebaseFirestoreCloudFunctions.updateTeam(
          teamid: currentTeam.id, data: currentTeam.toJson());
    setState(() {
      _progress = 100;
      _updating = false;
    });
  }
}
