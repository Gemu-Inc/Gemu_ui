import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  final String whatActivity;

  NotificationsScreen({this.whatActivity});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(widget.whatActivity),
    );
  }
}
