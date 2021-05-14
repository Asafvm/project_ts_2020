import 'dart:io';

import 'package:flutter/material.dart';
import 'package:teamshare/screens/pdf/pdf_viewer_page.dart';

//TODO: add sharing and browsing functionality
class FileExplorer extends StatefulWidget {
  final Future<Directory> path; //starting path

  const FileExplorer({this.path});
  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  bool _multiSelect = false;
  List<bool> _selectedList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //TODO: add action[] on multiselect

        actions: [
          if (_multiSelect)
            IconButton(icon: Icon(Icons.share), onPressed: () {}),
          IconButton(icon: Icon(Icons.delete), onPressed: () {})
        ],
      ),
      body: FutureBuilder<Directory>(
        future: widget.path,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<FileSystemEntity> files = snapshot.data
                .listSync(); //list of SystemFileEntities (file,folders,etc)
            //sort folders first
            files.sort((a, b) => a
                .statSync()
                .type
                .toString()
                .compareTo(b.statSync().type.toString()));

            return Column(
              children: [
                Text(snapshot.data.path), //TODO: change to filter text
                Expanded(
                  child: ListView.builder(
                    itemCount: files.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      FileSystemEntity file = files[index];
                      FileStat fileStats = file.statSync();
                      return _multiSelect
                          ? CheckboxListTile(
                              value: _selectedList[index],
                              onChanged: (value) {
                                setState(() {
                                  _selectedList[index] = value;
                                  if (_selectedList
                                          .where((element) => element == true)
                                          .length ==
                                      0)
                                    _multiSelect =
                                        false; //disable multiselect on empty selected list
                                });
                              },
                              title: Text(file.path.substring(
                                  files[index].path.lastIndexOf('/') + 1)),
                              subtitle: Text('${fileStats.modified.toLocal()}'),
                              secondary: Icon(
                                  fileStats.type.toString() == "file"
                                      ? Icons.file_copy
                                      : Icons.folder),
                            )
                          : ListTile(
                              onLongPress: () {
                                _initSelectedList(files.length);
                                setState(() {
                                  _multiSelect = true;
                                  _selectedList[index] =
                                      true; //mark first selected
                                });
                              },
                              onTap: () {
                                //open if has pdf extension
                                if (files[index].path.endsWith(".pdf"))
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PDFScreen(
                                        fields: [],
                                        instrumentID: "",
                                        onlyFields: true,
                                        pathPDF: files[index].path),
                                  ));

                                //TODO: else if folder call FileExplorer(currect path + folder name])

                                else if(files[index].path.endsWith(".")){
                                  
                                }
                              },

                              leading: Icon(fileStats.type.toString() == "file"
                                  ? Icons.file_copy
                                  : Icons.folder), //set icon
                              title: Text(file.path.substring(
                                  files[index].path.lastIndexOf('/') + 1)),
                              subtitle: Text('${fileStats.modified.toLocal()}'),
                            );
                    },
                  ),
                ),
              ],
            );
          } else
            return Container();
        },
      ),
    );
  }

  void _initSelectedList(int length) {
    _selectedList = List<bool>.filled(length, false);
  }
}
