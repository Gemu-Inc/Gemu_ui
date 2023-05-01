import 'package:flutter/material.dart';

import 'package:gemu/models/chat_messages.dart';

class VideoMessage extends StatelessWidget {
  final ChatMessage message;

  VideoMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      decoration: BoxDecoration(
          color: message.isSender
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).canvasColor,
          borderRadius: BorderRadiusDirectional.circular(20)),
      child: AspectRatio(
        aspectRatio: 0.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /*ClipRRect(
              child: Image.network(
                  "https://firebasestorage.googleapis.com/v0/b/gemu-app.appspot.com/o/posts%2FValorant%2Fpictures%2FPictureF65wJ5TGmvgO8t7HUZJYcw1PmbA2-0?alt=media&token=a2ded5d8-bdcd-4f1b-856e-58d3398c1955"),
            ),*/
            Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle),
              child: Icon(Icons.play_arrow, size: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
