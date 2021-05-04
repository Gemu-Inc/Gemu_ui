import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:provider/provider.dart';

import 'package:Gemu/constants/variables.dart';
import 'package:Gemu/models/user.dart';

import 'userRow.dart';

class ContactsScreen extends StatefulWidget {
  @override
  ContactsScreenState createState() => ContactsScreenState();
}

class ContactsScreenState extends State<ContactsScreen> {
  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser.uid;
    final List<UserModel> userDirectory = Provider.of<List<UserModel>>(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: GradientAppBar(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ]),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context)),
          title: Text(
            'Contacts',
            style: mystyle(15),
          ),
        ),
        body: uid != null && userDirectory != null
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
      if (contact.id != uid) {
        list.add(UserRow(
          uid: uid,
          contact: contact,
        ));
      }
    }
    return list;
  }
}
