import 'package:flutter/material.dart';

import 'package:Gemu/models/chat_messages.dart';

class AudioMessage extends StatelessWidget {
  final ChatMessage message;

  AudioMessage({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      padding: EdgeInsets.symmetric(horizontal: 15 * 0.75, vertical: 15 / 2.5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: message.isSender
              ? Theme.of(context).primaryColor
              : Theme.of(context).canvasColor),
      child: Row(
        children: [
          Icon(Icons.play_arrow, color: Colors.white),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15 / 2),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  Positioned(
                      left: 0,
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                      ))
                ],
              ),
            ),
          ),
          Text(
            "0.37",
            style: TextStyle(
                fontSize: 12, color: message.isSender ? Colors.white : null),
          )
        ],
      ),
    );
  }
}
