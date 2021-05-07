import 'package:Gemu/constants/variables.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:Gemu/models/user.dart';

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
            leading: contact.photoURL == null
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
                                CachedNetworkImageProvider(contact.photoURL!))),
                  ),
            title: Text(
              contact.pseudo!,
              style: mystyle(12),
            ),
            trailing: Icon(Icons.message)));
  }

  void createConversation(BuildContext context) {
    String convoID = getConvoID(uid, contact.id);
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
