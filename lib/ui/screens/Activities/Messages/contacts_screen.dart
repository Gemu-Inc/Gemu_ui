import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/user.dart';

import 'userRow.dart';

class ContactsScreen extends StatefulWidget {
  @override
  ContactsScreenState createState() => ContactsScreenState();
}

class ContactsScreenState extends State<ContactsScreen> {
  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final List<UserModel> userDirectory = Provider.of<List<UserModel>>(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary
                  ])),
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context)),
                title: Text(
                  'Contacts',
                  style: mystyle(15),
                ),
              ),
            ),
            preferredSize: Size.fromHeight(60)),
        body: uid.isNotEmpty && userDirectory.isNotEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: ListView(
                  shrinkWrap: true,
                  children: getListViewItems(userDirectory, uid),
                ),
              )
            : Container());
  }

  List<Widget> getListViewItems(List<UserModel> userDirectory, String uid) {
    final List<Widget> list = [];
    for (UserModel contact in userDirectory) {
      if (contact.uid != uid) {
        list.add(UserRow(
          uid: uid,
          contact: contact,
        ));
      }
    }
    return list;
  }
}
