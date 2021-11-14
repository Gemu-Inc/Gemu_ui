import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/models/convo.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/ui/screens/Activities/Messages/messages_screen.dart';

class ConversationProvider extends StatelessWidget {
  const ConversationProvider({Key? key, required this.uid}) : super(key: key);

  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Convo>>.value(
      initialData: [],
      value: DatabaseService.streamConversations(uid),
      child: ConversationDetailsProvider(
        uid: uid,
      ),
    );
  }
}

class ConversationDetailsProvider extends StatelessWidget {
  const ConversationDetailsProvider({Key? key, this.uid}) : super(key: key);

  final String? uid;

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<UserModel>>.value(
      initialData: [],
      value: DatabaseService.getUsersByList(
          getUserIds(Provider.of<List<Convo>>(context))),
      child: MessagesScreen(),
    );
  }

  List<String> getUserIds(List<Convo> _convos) {
    final List<String> users = <String>[];
    if (_convos.isNotEmpty) {
      for (Convo c in _convos) {
        c.userIds![0] != uid
            ? users.add(c.userIds![0])
            : users.add(c.userIds![1]);
      }
    }
    return users;
  }
}
