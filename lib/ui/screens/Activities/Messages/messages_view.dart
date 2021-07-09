import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';

import 'package:gemu/models/chat_messages.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/ui/constants/constants.dart';

import 'text_message.dart';
import 'audio_message.dart';
import 'video_message.dart';

class NewConversationScreen extends StatelessWidget {
  const NewConversationScreen(
      {required this.uid, required this.contact, required this.convoID});

  final String? uid, convoID;
  final UserModel? contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
          child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ])),
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
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
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  contact!.imageUrl!))),
                    ),
                    SizedBox(width: 10.0),
                    Text(contact!.username)
                  ],
                ),
              )),
          preferredSize: Size.fromHeight(60)),
      body: ChatScreen(uid: uid, contact: contact, convoID: convoID),
    );
  }
}

class ChatScreen extends StatefulWidget {
  ChatScreen({required this.uid, required this.contact, required this.convoID});

  final String? uid, convoID;
  final UserModel? contact;

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();

  String? uid, convoID;
  UserModel? contact;
  late List<DocumentSnapshot> listMessage;

  bool isWritting = false;

  @override
  void initState() {
    super.initState();
    uid = widget.uid;
    convoID = widget.convoID;
    contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Column(
            children: [message(), chatInputField()],
          )
        ],
      ),
    );
  }

  Widget message() {
    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(convoID)
            .collection(convoID!)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          listMessage = snapshot.data!.docs;
          if (listMessage.length == 0) {
            return Center(
              child: Text('Pas encore de message avec cet utilisateur'),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(1.0),
            reverse: true,
            controller: _listScrollController,
            itemCount: listMessage.length,
            itemBuilder: (BuildContext context, int index) =>
                buildItem(index, listMessage[index]),
          );
        },
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (!document['read'] && document['idTo'] == uid) {
      DatabaseService.updateMessageRead(document, convoID!);
    }

    if (document['idTo'] == uid) {
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: 5.0,
        ),
        width: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Bubble(
                color: Theme.of(context).canvasColor,
                elevation: 0,
                padding: BubbleEdges.all(10.0),
                nip: BubbleNip.leftTop,
                child: Text(
                  document['content'],
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Container(
          margin: EdgeInsets.symmetric(vertical: 5.0),
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: Bubble(
                  color: Theme.of(context).accentColor,
                  elevation: 0,
                  padding: BubbleEdges.all(10.0),
                  nip: BubbleNip.rightTop,
                  child: Text(
                    document['content'],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ));
    }
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
                        onTap: () => onSendMessage(_messageController.text),
                        child: Text('Envoyer',
                            style: mystyle(15, Theme.of(context).primaryColor)))
              ],
            ),
          ))
        ],
      )),
    );
  }

  void onSendMessage(String content) {
    if (content.trim() != '') {
      _messageController.clear();
      content = content.trim();
      DatabaseService.sendMessage(convoID, uid, contact!.uid, content,
          DateTime.now().millisecondsSinceEpoch.toString());
      _listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
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
}

class MessageStatusDot extends StatelessWidget {
  final MessageStatus? status;

  MessageStatusDot({Key? key, this.status}) : super(key: key);

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

  Color? dotColor(MessageStatus? status, BuildContext context) {
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
