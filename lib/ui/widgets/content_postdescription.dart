import 'package:flutter/material.dart';

class ContentPostDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 70.0,
        padding: EdgeInsets.only(left: 20.0),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    '0ruj#0827',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[300]),
                  ),
                ],
              ),
              Text(
                'Video title and some other stuff',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                'Different # select by the user',
                style: TextStyle(color: Colors.grey),
              )
              /*Row(children: [
                Icon(
                  Icons.music_note,
                  size: 15.0,
                  color: Colors.white,
                ),
                Text('Artist name - Album name - song',
                    style: TextStyle(fontSize: 12.0))
              ]),*/
            ]));
  }
}
