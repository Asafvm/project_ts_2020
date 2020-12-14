import 'package:flutter/material.dart';

class InstrumentInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TBA")),
      body: Column(
        children: [
          Flexible(
            //General info
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          Flexible(
            //log and forms
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
              // child: DefaultTabController(
              //     initialIndex: 0,
              //     length: 2,
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       children: <Widget>[
              //         tabbar, //defined in consts
              //         SizedBox(
              //           height: 200,
              //           child: TabBarView(
              //             children: [
              //               Column(
              //                 mainAxisSize: MainAxisSize.min,
              //                 mainAxisAlignment: MainAxisAlignment.start,
              //                 children: [
              //                   Row(
              //                     children: [
              //                       Flexible(
              //                         flex: 1,
              //                         fit: FlexFit.tight,
              //                         child: IconButton(
              //                           icon: Icon(Icons.add_a_photo),
              //                           iconSize: 50,
              //                           onPressed: () {},
              //                         ),
              //                       ),
              //                       Flexible(
              //                         flex: 3,
              //                         fit: FlexFit.tight,
              //                         child: Column(
              //                           mainAxisSize: MainAxisSize.min,
              //                           children: [
              //                             _buildDescFormField(),
              //                             Row(
              //                               mainAxisSize: MainAxisSize.min,
              //                               children: <Widget>[
              //                                 Expanded(
              //                                     child: _buildRefFormField()),
              //                                 Expanded(
              //                                     child: _buildAltRefFormField()),
              //                               ],
              //                             ),
              //                           ],
              //                         ),
              //                       )
              //                     ],
              //                   ),
              //                   Row(
              //                     children: <Widget>[
              //                       Expanded(child: _buildMinStorageFormField()),
              //                       Expanded(child: _buildPerStorageFormField()),
              //                     ],
              //                   ),
              //                   Expanded(
              //                     flex: 3,
              //                     child: instrumentList == null
              //                         ? Text(
              //                             "No Instruments listed",
              //                             style: TextStyle(color: Colors.red),
              //                           )
              //                         : DropdownButton(
              //                             hint: Text("Device"),
              //                             items: instrumentList
              //                                 .map((e) => DropdownMenuItem(
              //                                       child: Text(e.getCodeName()),
              //                                     ))
              //                                 .toList(),
              //                             onChanged: (val) {},
              //                           ),
              //                   ),
              //                 ],
              //               ),
              //               Column(
              //                 children: [
              //                   Row(
              //                     children: <Widget>[
              //                       Expanded(child: _buildManFormField()),
              //                       Expanded(child: _buildModelFormField()),
              //                     ],
              //                   ),
              //                   Row(
              //                     children: <Widget>[
              //                       Expanded(child: _buildPriceFormField())
              //                     ],
              //                   ),
              //                   Row(
              //                     children: <Widget>[
              //                       Expanded(
              //                         child: SwitchListTile(
              //                           title: Text("Track Serials"),
              //                           value: _isTracking,
              //                           onChanged: (val) {
              //                             setState(() {
              //                               _isTracking = val;
              //                               _newPart.serialTracking = val;
              //                             });
              //                           },
              //                         ),
              //                       ),
              //                       Expanded(
              //                         child: SwitchListTile(
              //                             title: Text("Active"),
              //                             value: _isActive,
              //                             onChanged: (val) {
              //                               setState(() {
              //                                 _isActive = val;
              //                                 _newPart.setActive(val);
              //                               });
              //                             }),
              //                       ),
              //                     ],
              //                   ),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ),

              //         Container(
              //             margin: EdgeInsets.symmetric(vertical: 20),
              //             child: FlatButton(
              //               onPressed: () async {
              //                 _partForm.currentState.save();
              //                 setState(() {
              //                   _uploading = true;
              //                 });
              //                 //send to server
              //                 try {
              //                   await FirebaseFirestoreProvider.uploadPart(
              //                           _newPart)
              //                       .then((_) async => await showDialog(
              //                           context: context,
              //                           builder: (ctx) => AlertDialog(
              //                                 title: Text('Success!'),
              //                                 content:
              //                                     Text('New Part created!\n'),
              //                                 actions: <Widget>[
              //                                   FlatButton(
              //                                     onPressed:
              //                                         Navigator.of(context).pop,
              //                                     child: Text('Ok'),
              //                                   ),
              //                                 ],
              //                               )).then(
              //                           (_) => Navigator.of(context).pop()));
              //                 } catch (error) {
              //                   showDialog(
              //                       context: context,
              //                       builder: (ctx) => AlertDialog(
              //                             title: Text('Error!'),
              //                             content: Text('Operation failed\n' +
              //                                 error.toString()),
              //                             actions: <Widget>[
              //                               FlatButton(
              //                                 onPressed:
              //                                     Navigator.of(context).pop,
              //                                 child: Text('Ok'),
              //                               ),
              //                             ],
              //                           ));
              //                 } finally {
              //                   setState(() {
              //                     _newPart = null;
              //                     _uploading = false;
              //                   });
              //                 }
              //               },
              //               child: Text(
              //                 'Add New Part',
              //                 style: TextStyle(color: Colors.white),
              //               ),
              //               color: Theme.of(context).primaryColor,
              //             ))
              //       ],
              //     ),
              //   ),
            ),
          )
        ],
      ),
    );
  }
}
