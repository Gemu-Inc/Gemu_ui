import 'package:flutter/material.dart';

class ContentPostDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: 70.0,
        width: MediaQuery.of(context).size.width / 2,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '0ruj#0827',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey[300]),
              ),
              Text(
                'Video title and some other stuff',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                'Different # select by the user',
                style: TextStyle(color: Colors.grey),
              )
            ]));
  }
}
