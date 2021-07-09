import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:gemu/models/user.dart';

import 'messages_view.dart';

class MessageCard extends StatelessWidget {
  MessageCard(
      {Key? key,
      required this.uid,
      required this.peer,
      required this.lastMessage})
      : super(key: key);

  final String uid;
  final UserModel? peer;
  Map<dynamic, dynamic>? lastMessage;

  BuildContext? context;
  String? groupId;
  bool? read;

  @override
  Widget build(BuildContext context) {
    if (lastMessage!['idFrom'] == uid) {
      read = true;
    } else {
      read = lastMessage!['read'] == null ? true : lastMessage!['read'];
    }
    this.context = context;
    groupId = getGroupChatId();

    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => NewConversationScreen(
                  uid: uid, contact: peer, convoID: groupId))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15 * 0.75),
        child: Row(
          children: [
            Stack(
              children: [
                peer!.imageUrl == null
                    ? Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Icon(Icons.person),
                      )
                    : Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                    peer!.imageUrl!))),
                      ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          peer!.username,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        read!
                            ? Container()
                            : Icon(Icons.brightness_1,
                                color: Theme.of(context).accentColor, size: 15),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Opacity(
                      opacity: 0.64,
                      child: Text(
                        lastMessage!['content'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: 0.64,
              child: Text(getTime(lastMessage!['timestamp'])),
            )
          ],
        ),
      ),
    );
  }

  String getTime(String timestamp) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    DateFormat format;
    if (dateTime.difference(DateTime.now()).inMilliseconds <= 86400000) {
      format = DateFormat('jm');
    } else {
      format = DateFormat.yMd('en_US');
    }
    return format
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp)));
  }

  String getGroupChatId() {
    if (uid.hashCode <= peer!.uid.hashCode) {
      return uid + '_' + peer!.uid;
    } else {
      return peer!.uid + '_' + uid;
    }
  }
}
