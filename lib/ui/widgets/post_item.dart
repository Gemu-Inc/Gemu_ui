import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Gemu/models/post.dart';
import 'package:Gemu/models/user.dart';

//Post item mode scroll infini à retravailler
class PostItem extends StatelessWidget {
  final Post post;
  final Future<UserC> user;

  const PostItem({
    Key key,
    this.post,
    this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();
    return Container(
        margin: EdgeInsets.only(top: 20.0),
        height: MediaQuery.of(context).size.height / 1.80,
        width: MediaQuery.of(context).size.width / 1.10,
        decoration: BoxDecoration(
            color: Colors.black12.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width / 1.10,
              //color: Colors.pink,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<UserC>(
                      future: user,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          UserC _user = snapshot.data;
                          return Row(
                            children: [
                              Container(
                                margin: EdgeInsets.all(3.0),
                                width: 33,
                                height: 33,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(_user.photoURL))),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 5.0),
                                child: Text(
                                  _user.pseudo,
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor),
                                ),
                              )
                            ],
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      }),
                ],
              ),
            ),
            Container(
              //color: Colors.purple,
              height: 225,
              width: MediaQuery.of(context).size.width / 1.10,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width / 1.20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black)),
                      child: SizedBox(
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrl,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Container(
                                alignment: Alignment.center,
                                height: 35.0,
                                width: 35.0,
                                decoration: BoxDecoration(
                                    color: Colors.black12.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.green,
                                )),
                            Container(
                                margin: EdgeInsets.only(left: 5.0),
                                alignment: Alignment.center,
                                height: 35.0,
                                width: 35.0,
                                decoration: BoxDecoration(
                                    color: Colors.black12.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Icon(
                                  Icons.arrow_downward,
                                  color: Colors.red,
                                )),
                          ],
                        ),
                        Container(
                            alignment: Alignment.center,
                            height: 35.0,
                            width: 45.0,
                            decoration: BoxDecoration(
                                color: Colors.black12.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 5.0),
                                  child: Icon(Icons.comment,
                                      color: Theme.of(context).accentColor),
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor),
                                )
                              ],
                            )),
                        Container(
                            alignment: Alignment.center,
                            height: 35.0,
                            width: 35.0,
                            decoration: BoxDecoration(
                                color: Colors.black12.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                              Icons.remove_red_eye,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width / 1.10,
              //color: Colors.pink,
              alignment: Alignment.center,
              child: Text(post.content),
            ),
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width / 1.10,
              //color: Colors.purple,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 25.0),
                    height: 40,
                    width: 175,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.black12.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Comment',
                            labelStyle: TextStyle(
                                color: Theme.of(context).accentColor))),
                  ),
                  GestureDetector(
                    onTap: () => print('Envoi commentaire'),
                    child: Container(
                      height: 40,
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.black12.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                        Icons.send,
                        size: 25,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
