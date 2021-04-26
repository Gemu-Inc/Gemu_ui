import 'package:flutter/material.dart';

import 'package:Gemu/models/chat.dart';

import 'message_card.dart';

class MessagesScreen extends StatefulWidget {
  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20.0),
            height: 35,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    offset: Offset(-5.0, 5.0),
                  )
                ]),
            child: Row(
              children: [
                SizedBox(width: 5.0),
                Icon(
                  Icons.search,
                  size: 20.0,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  'Rechercher',
                  style: TextStyle(fontSize: 15.0),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chatsData.length,
              itemBuilder: (context, index) => MessageCard(
                chat: chatsData[index],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print('Write a new message'),
        child: Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
