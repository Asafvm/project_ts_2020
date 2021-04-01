import 'package:flutter/material.dart';

class MemberListItem extends StatelessWidget {
  final String name;
  final Function removeFunction;

  const MemberListItem({Key key, this.name, this.removeFunction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                name,
                textAlign: TextAlign.start,
              ),
            ),
            Switch(
              activeColor: Theme.of(context).primaryColor,
              onChanged: (bool value) {},
              value: false,
            ),
            IconButton(
              icon: Icon(
                Icons.remove_circle,
                color: Colors.red,
              ),
              onPressed: () => removeFunction(name),
            ),
          ],
        ),
      ),
    );
  }
}
