import 'package:flutter/material.dart';
import 'package:teamshare/helpers/decoration_library.dart';

class SearchBar extends StatefulWidget {
  final String label;
  final Function onChange;

  const SearchBar({Key key, this.label, this.onChange}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) => widget.onChange(value),
        decoration: DecorationLibrary.searchDecoration(
            hint: widget.label, context: context),
      ),
    );
  }
}
