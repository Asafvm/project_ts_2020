import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeamThumbnail extends StatelessWidget {
  final String teamDocId;

  const TeamThumbnail({Key key, this.teamDocId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<Map<String, dynamic>>(
          stream: Firestore.instance
              .collection("teams")
              .document(teamDocId)
              .get()
              .then((value) => value.data)
              .asStream(),
          builder: (context, snapshot) {
            if (snapshot == null || snapshot.hasData == false) {
              return LinearProgressIndicator();
            } else {
              return ListView.builder(
                itemBuilder: (ctx, index) => ListTile(
                  leading: Image(
                    image: AssetImage('assets/pics/unknown.jpg'),
                  ),
                  title: Text(snapshot.data['name']),
                  subtitle: Text(
                    snapshot.data['description'],
                    overflow: TextOverflow.fade,
                  ),
                  onTap: () {},
                ),
                itemCount: 1,
                shrinkWrap: true,
              );

              // Container(
              //   child: Text(snapshot.data.toString()),
              // );
            }
          },
        ),
      ),
    );
  }
}
