import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Icon icon;
  final Function action;
  CustomAppBar(this.title, this.icon, this.action);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: (icon == null || action == null)
            ? AppBar(
                title: Text(
                  title,
                ),
              )
            : AppBar(
                title: Text(
                  title,
                ),
                actions: <Widget>[IconButton(icon: icon, onPressed: action)],
              ));
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}
