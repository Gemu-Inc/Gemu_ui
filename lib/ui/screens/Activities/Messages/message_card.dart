import 'package:flutter/material.dart';

import 'package:Gemu/models/chat.dart';

import 'messages_view.dart';

class MessageCard extends StatelessWidget {
  final Chat chat;

  MessageCard({Key key, @required this.chat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessagesView(
                    name: chat.name,
                    isActive: chat.isActive,
                  ))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15 * 0.75),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                  child: Icon(Icons.person),
                ),
                if (chat.isActive)
                  Positioned(
                    right: 5,
                    bottom: 5,
                    child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                          color: Colors.green[400],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black)),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Opacity(
                      opacity: 0.64,
                      child: Text(
                        chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: 0.64,
              child: Text(chat.time),
            )
          ],
        ),
      ),
    );
  }
}
