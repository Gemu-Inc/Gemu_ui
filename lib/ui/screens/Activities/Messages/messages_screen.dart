import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Gemu/models/user.dart';
import 'package:Gemu/models/convo.dart';
import 'package:Gemu/providers/newMessageProvider.dart';

import 'message_card.dart';

class MessagesScreen extends StatefulWidget {
  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final List<Convo> _convos = Provider.of<List<Convo>>(context);
    final List<UserModel> _users = Provider.of<List<UserModel>>(context);
    return Scaffold(
      body: _convos.length != 0 && _users.length != 0
          ? Column(
              children: [
                Container(
                  margin: EdgeInsets.all(20.0),
                  height: 35,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor,
                          offset: Offset(-5.0, 5.0),
                        )
                      ]),
                  child: Row(
                    children: [
                      SizedBox(width: 5.0),
                      Icon(
                        Icons.search,
                        size: 20.0,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        'Rechercher',
                        style: TextStyle(fontSize: 15.0),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: getWidgets(context, uid, _convos, _users),
                ))
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => NewMessageProvider())),
        child: Icon(Icons.message),
      ),
    );
  }

  Map<String?, UserModel> getUserMap(List<UserModel> users) {
    final Map<String?, UserModel> userMap = Map();
    for (UserModel u in users) {
      userMap[u.id] = u;
    }
    return userMap;
  }

  List<Widget> getWidgets(BuildContext context, String uid, List<Convo> _convos,
      List<UserModel> _users) {
    final List<Widget> list = <Widget>[];

    if (_convos != null && _users != null && uid != null) {
      final Map<String?, UserModel> userMap = getUserMap(_users);
      for (Convo c in _convos) {
        if (c.userIds![0] == uid) {
          list.add(MessageCard(
              uid: uid,
              peer: userMap[c.userIds![1]],
              lastMessage: c.lastMessage));
        } else {
          list.add(MessageCard(
              uid: uid,
              peer: userMap[c.userIds![0]],
              lastMessage: c.lastMessage));
        }
      }
    }
    return list;
  }
}
