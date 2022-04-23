import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/models/notification.dart';

class NotifTile extends StatefulWidget {
  final List<NotificationUser> notifications;
  final NotificationUser notification;

  NotifTile({required this.notifications, required this.notification});

  @override
  NotifTileState createState() => NotifTileState();
}

class NotifTileState extends State<NotifTile> {
  accepteDemandeFollow() async {
    await widget.notification.reference.update({'seen': true});

    me!.ref!
        .collection('followers')
        .doc(widget.notification.from)
        .get()
        .then((user) {
      if (!user.exists) {
        user.reference.set({});
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.notification.from)
            .collection('following')
            .doc(me!.uid)
            .set({});
        DatabaseService.addNotification(me!.uid, widget.notification.from,
            "a accepté votre demande de follow", "follow");
      }
    });

    await widget.notification.reference
        .update({'text': 'a commencé à vous suivre'});
  }

  refuseDemandeFollow() async {
    await widget.notification.reference.delete();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.notification.from)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }
        UserModel user = UserModel.fromMap(snapshot.data, snapshot.data.data());
        switch (widget.notification.type) {
          case 'comment':
            return notificationComment(user);
          case 'follow':
            return notificationFollow(user);
          case 'updown':
            return notificationUpDown(user);
          default:
            return Container();
        }
      },
    );
  }

  Widget notificationComment(UserModel user) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        child: ListTile(
            onTap: () => print('go sur le comment'),
            leading: Stack(
              children: [
                user.imageUrl == null
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
                                    user.imageUrl!))),
                      ),
                if (!widget.notification.seen)
                  Positioned(
                      top: 5,
                      right: 1,
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ))
              ],
            ),
            title: Text(user.username),
            subtitle: Text(widget.notification.text),
            trailing: Text(Helpers.datePostView(widget.notification.date))),
      ),
    );
  }

  Widget notificationFollow(UserModel user) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: (widget.notification.text == 'voudrait vous suivre' &&
              widget.notification.seen == false)
          ? Container(
              height: 80,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    Container(
                      height: 80,
                      alignment: Alignment.topCenter,
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                          child: Stack(
                            children: [
                              user.imageUrl == null
                                  ? Container(
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          shape: BoxShape.circle),
                                      child: Icon(Icons.person),
                                    )
                                  : Container(
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(
                                                  user.imageUrl!))),
                                    ),
                              if (!widget.notification.seen)
                                Positioned(
                                    top: 5,
                                    right: 1,
                                    child: CircleAvatar(
                                      radius: 6,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                    ))
                            ],
                          )),
                    ),
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.only(top: 5.0, left: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: TextStyle(
                                fontSize: 16, fontStyle: FontStyle.normal),
                          ),
                          SizedBox(
                            height: 3.0,
                          ),
                          Text(
                            widget.notification.text,
                            style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.caption!.color),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      accepteDemandeFollow();
                                    },
                                    child: Text(
                                      'Confirmer',
                                      style: TextStyle(color: Colors.green),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      refuseDemandeFollow();
                                    },
                                    child: Text(
                                      'Supprimer',
                                      style: TextStyle(color: Colors.red),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
                    Text(Helpers.datePostView(widget.notification.date))
                  ],
                ),
              ),
            )
          : ListTile(
              leading: Stack(
                children: [
                  user.imageUrl == null
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
                                      user.imageUrl!))),
                        ),
                  if (!widget.notification.seen)
                    Positioned(
                        top: 5,
                        right: 1,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ))
                ],
              ),
              title: Text(user.username),
              subtitle: Text(widget.notification.text),
              trailing: Text(Helpers.datePostView(widget.notification.date))),
    );
  }

  Widget notificationUpDown(UserModel user) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
          onTap: () => print('go sur le post ou le commentaire up&down'),
          leading: Stack(
            children: [
              user.imageUrl == null
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
                              image:
                                  CachedNetworkImageProvider(user.imageUrl!))),
                    ),
              if (!widget.notification.seen)
                Positioned(
                    top: 5,
                    right: 1,
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ))
            ],
          ),
          title: Text(user.username),
          subtitle: Text(widget.notification.text),
          trailing: Text(Helpers.datePostView(widget.notification.date))),
    );
  }
}
