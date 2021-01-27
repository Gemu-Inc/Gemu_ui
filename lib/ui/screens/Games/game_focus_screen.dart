import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GameFocusScreen extends StatefulWidget {
  const GameFocusScreen({Key key, @required this.imageUrl}) : super(key: key);

  final String imageUrl;

  @override
  _GameFocusScreenState createState() => _GameFocusScreenState();
}

class _GameFocusScreenState extends State<GameFocusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1C25),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context)),
        title: PreferredSize(
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).accentColor
                      ]),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color(0xFF222831)),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(widget.imageUrl))),
            ),
            preferredSize: Size.fromWidth(100)),
        centerTitle: true,
      ),
    );
  }
}
