import 'package:flutter/material.dart';

import 'package:Gemu/constants/variables.dart';

import '../profile_view.dart';

class ContentPostDescription extends StatelessWidget {
  final String idUser, username, caption, hashtags;

  ContentPostDescription(
      {this.idUser, this.username, this.caption, this.hashtags});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 5.0),
        width: MediaQuery.of(context).size.width / 2,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileView(
                                idUser: idUser,
                              ))),
                  child: Text(username, style: mystyle(15))),
              Text(
                caption,
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                hashtags,
                style: TextStyle(color: Colors.grey),
              )
            ]));
  }
}
