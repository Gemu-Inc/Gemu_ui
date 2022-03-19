import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/constants/constants.dart';

import 'messages_view.dart';

class UserRow extends StatelessWidget {
  const UserRow({required this.uid, required this.contact});

  final String uid;
  final UserModel contact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => createConversation(context),
        child: ListTile(
            leading: contact.imageUrl == null
                ? Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person))
                : Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image:
                                CachedNetworkImageProvider(contact.imageUrl!))),
                  ),
            title: Text(
              contact.username,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Icon(Icons.message)));
  }

  void createConversation(BuildContext context) {
    String convoID = getConvoID(uid, contact.uid);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewConversationScreen(
                uid: uid, contact: contact, convoID: convoID)));
  }

  static String getConvoID(String uid, String? pid) {
    return uid.hashCode <= pid.hashCode ? uid + '_' + pid! : pid! + '_' + uid;
  }
}
