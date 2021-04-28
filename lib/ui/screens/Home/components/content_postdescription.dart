import 'package:flutter/material.dart';

import 'package:Gemu/constants/variables.dart';

import '../profile_view.dart';

class ContentPostDescription extends StatelessWidget {
  final String idUser, username, caption;
  final List hashtags;

  ContentPostDescription(
      {this.idUser, this.username, this.caption, this.hashtags});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 110,
        width: MediaQuery.of(context).size.width / 2,
        child: Column(
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
              Container(
                  child: SingleChildScrollView(
                child: Text(
                  caption,
                  style: TextStyle(color: Colors.grey),
                ),
              )),
              Expanded(
                child: Container(
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, childAspectRatio: 4),
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: hashtags.length,
                        itemBuilder: (context, index) {
                          return Text(
                            '#${hashtags[index]}',
                            style: TextStyle(color: Colors.grey),
                          );
                        })),
              )
            ]));
  }
}
