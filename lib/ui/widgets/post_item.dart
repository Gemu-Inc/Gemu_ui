import 'package:Gemu/ui/widgets/text_field_container.dart';
import 'package:flutter/material.dart';

class PostItem extends StatelessWidget {
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Text(
                          'Pseudo',
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        ),
                      )
                    ],
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.menu,
                        size: 30,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () => print('Options post'))
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
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                        Icons.image,
                        size: 60,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Container(
                            margin: EdgeInsets.only(left: 25.0),
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
                        Container(
                            margin: EdgeInsets.only(left: 40.0),
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
                            ))
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
              child: Text('Content post'),
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
