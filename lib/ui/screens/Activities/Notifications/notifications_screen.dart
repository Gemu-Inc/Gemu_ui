import 'package:Gemu/constants/variables.dart';
import 'package:flutter/material.dart';

import 'package:Gemu/models/notifications.dart';

class NotificationsScreen extends StatefulWidget {
  final String? whatActivity;

  NotificationsScreen({this.whatActivity});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    switch (widget.whatActivity) {
      case "All activities":
        return notificationsAllActivities();
      case "Comments":
        return notificationsComments();
      case "Follows":
        return notificationsFollows();
      case "Up&Down":
        return notificationsUpDown();
      default:
        return SizedBox();
    }
  }

  Widget notificationsAllActivities() {
    return ListView.builder(
        itemCount: demoNotifications.length,
        itemBuilder: (context, index) {
          return myNotification(demoNotifications[index]);
        });
  }

  Widget notificationsComments() {
    return ListView.builder(
      itemCount: demoNotifications.length,
      itemBuilder: (context, index) {
        switch (demoNotifications[index].notificationType) {
          case NotificationType.comment:
            return myNotification(demoNotifications[index]);
          default:
            return SizedBox();
        }
      },
    );
  }

  Widget notificationsFollows() {
    return ListView.builder(
      itemCount: demoNotifications.length,
      itemBuilder: (context, index) {
        switch (demoNotifications[index].notificationType) {
          case NotificationType.follow:
            return myNotification(demoNotifications[index]);
          default:
            return SizedBox();
        }
      },
    );
  }

  Widget notificationsUpDown() {
    return ListView.builder(
      itemCount: demoNotifications.length,
      itemBuilder: (context, index) {
        switch (demoNotifications[index].notificationType) {
          case NotificationType.updown:
            return myNotification(demoNotifications[index]);
          default:
            return SizedBox();
        }
      },
    );
  }

  Widget myNotification(NotificationDemo notification) {
    return ListTile(
      leading: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black), shape: BoxShape.circle),
        child: Icon(Icons.person),
      ),
      title: Text(
        notification.text!,
        style: mystyle(12),
      ),
      subtitle: Text(
        notification.time!,
        style: mystyle(12),
      ),
    );
  }
}
