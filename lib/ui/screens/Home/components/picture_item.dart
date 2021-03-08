import 'package:flutter/material.dart';

class PictureItem extends StatefulWidget {
  final String pictureUrl;

  PictureItem({this.pictureUrl});

  @override
  PictureItemState createState() => PictureItemState();
}

class PictureItemState extends State<PictureItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Image.network(widget.pictureUrl),
    );
  }
}
