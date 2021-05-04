import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Gemu/models/user.dart';
import 'package:Gemu/models/convo.dart';
import 'package:Gemu/services/database_service.dart';
import 'package:Gemu/ui/screens/Activities/Messages/messages_screen.dart';

class ConversationProvider extends StatelessWidget {
  const ConversationProvider({Key key, @required this.uid}) : super(key: key);

  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Convo>>.value(
      value: DatabaseService.streamConversations(uid),
      child: ConversationDetailsProvider(
        uid: uid,
      ),
    );
  }
}

class ConversationDetailsProvider extends StatelessWidget {
  const ConversationDetailsProvider({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<UserModel>>.value(
      value: DatabaseService.getUsersByList(
          getUserIds(Provider.of<List<Convo>>(context))),
      child: MessagesScreen(),
    );
  }

  List<String> getUserIds(List<Convo> _convos) {
    final List<String> users = <String>[];
    if (_convos != null) {
      for (Convo c in _convos) {
        c.userIds[0] != uid ? users.add(c.userIds[0]) : users.add(c.userIds[1]);
      }
    }
    return users;
  }
}
