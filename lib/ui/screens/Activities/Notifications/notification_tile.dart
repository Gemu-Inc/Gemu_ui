import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotifTile extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> notification;

  NotifTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(notification.data()!['from'])
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Container(),
          );
        }
        DocumentSnapshot<Map<String, dynamic>> user = snapshot.data;
        return ListTile(
          onTap: () => print('Notif'),
          leading: user.data()!['imageUrl'] == null
              ? Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      shape: BoxShape.circle),
                  child: Icon(Icons.person),
                )
              : Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              user.data()!['imageUrl']))),
                ),
          title: Text(user.data()!['username']),
          subtitle: Text(notification.data()!['text']),
        );
      },
    );
  }
}
