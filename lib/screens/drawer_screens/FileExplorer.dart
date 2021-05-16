import 'dart:io';

import 'package:flutter/material.dart';
import 'package:teamshare/helpers/decoration_library.dart';
import 'package:teamshare/screens/pdf/pdf_viewer_page.dart';
import 'package:share/share.dart';

class FileExplorer extends StatefulWidget {
  final Future<Directory> path; //starting path

  const FileExplorer({this.path});
  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  bool _multiSelect = false;
  List<bool> _selectedList = [];
  List<FileSystemEntity> files;

  String _textFilter = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_multiSelect)
            IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  Share.shareFiles(files
                      .where((element) => _selectedList[files.indexOf(element)])
                      .map((e) => e.path)
                      .toList());
                }),
          if (_multiSelect)
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                          'Delete ${_selectedList.where((element) => element).length} Files?'),
                      content:
                          Text('This action cannot be reversed\nAre you sure?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              files
                                  .where((element) =>
                                      _selectedList[files.indexOf(element)])
                                  .toList()
                                  .forEach((element) {
                                element.delete();
                              });

                              setState(() {
                                _multiSelect = false;
                              });
                              Navigator.pop(context);
                            },
                            child: Text('OK')),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'))
                      ],
                    ),
                  );
                })
        ],
      ),
      body: FutureBuilder<Directory>(
        future: widget.path,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            files = snapshot.data
                .listSync(); //list of SystemFileEntities (file,folders,etc)
            //sort folders first
            files.sort((a, b) => a
                .statSync()
                .type
                .toString()
                .compareTo(b.statSync().type.toString()));

            return Column(
              children: [
                TextField(
                  decoration: DecorationLibrary.searchDecoration(
                      context: context, hint: 'Search'),
                  onChanged: (value) => setState(() {
                    _textFilter = value;
                  }),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: files //filter by search text
                        .where((element) => element.path
                            .substring(element.path.lastIndexOf('/') + 1)
                            .toLowerCase()
                            .contains(_textFilter.toLowerCase()))
                        .toList()
                        .length,
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

                                else if (files[index].path.endsWith(".")) {}
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
