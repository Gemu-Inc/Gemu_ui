import 'package:Gemu/constants/variables.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'package:Gemu/models/chat_messages.dart';

import 'text_message.dart';
import 'audio_message.dart';
import 'video_message.dart';

class MessagesView extends StatefulWidget {
  final String name;
  final bool isActive;

  MessagesView({@required this.name, @required this.isActive});

  @override
  MessagesViewState createState() => MessagesViewState();
}

class MessagesViewState extends State<MessagesView> {
  TextEditingController _messageController = TextEditingController();

  bool isWritting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ]),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  shape: BoxShape.circle),
              child: Icon(Icons.person),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  widget.isActive ? 'Active' : 'Active 3m ago',
                  style: TextStyle(fontSize: 12),
                )
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.local_phone),
            onPressed: () {},
          ),
          IconButton(icon: Icon(Icons.videocam), onPressed: () {})
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
              itemCount: demeChatMessages.length,
              itemBuilder: (context, index) => message(demeChatMessages[index]),
            ),
          )),
          chatInputField()
        ],
      ),
    );
  }

  Widget messageContaint(ChatMessage message) {
    switch (message.messageType) {
      case ChatMessageType.text:
        return TextMessage(message: message);
        break;
      case ChatMessageType.audio:
        return AudioMessage(message: message);
        break;
      case ChatMessageType.video:
        return VideoMessage(
          message: message,
        );
        break;
      default:
        return SizedBox();
    }
  }

  Widget message(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment:
            message.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isSender) ...[
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black)),
              child: Icon(Icons.person),
            ),
            SizedBox(
              width: 15 / 2,
            )
          ],
          messageContaint(message),
          if (message.isSender)
            MessageStatusDot(
              status: message.messageStatus,
            )
        ],
      ),
    );
  }

  Widget chatInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15 / 2),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 32,
                color: Theme.of(context).canvasColor.withOpacity(0.08))
          ]),
      child: SafeArea(
          child: Row(
        children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15 * 0.75),
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(40)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type message",
                      border: InputBorder.none,
                    ),
                    onTap: () {
                      setState(() {
                        isWritting = !isWritting;
                      });
                    },
                  ),
                ),
                isWritting == false
                    ? Row(
                        children: [
                          Icon(Icons.mic),
                          SizedBox(
                            width: 7,
                          ),
                          Icon(Icons.image),
                          SizedBox(
                            width: 7,
                          ),
                          Icon(Icons.camera_alt_outlined)
                        ],
                      )
                    : GestureDetector(
                        onTap: () => print('Envoyer'),
                        child: Text('Envoyer',
                            style: mystyle(15, Theme.of(context).primaryColor)))
              ],
            ),
          ))
        ],
      )),
    );
  }
}

class MessageStatusDot extends StatelessWidget {
  final MessageStatus status;

  MessageStatusDot({Key key, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15 / 2),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
          color: dotColor(status, context),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black)),
      child: Icon(
        status == MessageStatus.not_sent ? Icons.close : Icons.done,
        size: 8,
        color: Colors.black,
      ),
    );
  }

  Color dotColor(MessageStatus status, BuildContext context) {
    switch (status) {
      case MessageStatus.not_sent:
        return Colors.red[400];
      case MessageStatus.not_view:
        return Colors.transparent;
      case MessageStatus.viewed:
        return Theme.of(context).primaryColor;
      default:
        return Colors.transparent;
    }
  }
}
