import 'package:flutter/material.dart';

import 'package:gemu/models/chat_messages.dart';

class TextMessage extends StatelessWidget {
  final ChatMessage? message;

  TextMessage({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15 * 0.75,
        vertical: 15 / 2,
      ),
      decoration: BoxDecoration(
          color: message!.isSender
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(30)),
      child: Text(
        message!.text!,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
