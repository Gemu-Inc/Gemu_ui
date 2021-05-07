import 'package:flutter/material.dart';

enum NotificationType { comment, follow, updown }

class NotificationDemo {
  final String? text, time;
  final NotificationType notificationType;

  NotificationDemo(
      {this.text, required this.time, required this.notificationType});
}

List demoNotifications = [
  NotificationDemo(
      text: "User1 a commenté votre post",
      time: "6 m ago",
      notificationType: NotificationType.comment),
  NotificationDemo(
      text: "User2 a commenté votre post",
      time: "3 m ago",
      notificationType: NotificationType.comment),
  NotificationDemo(
      text: "User3 vous suit",
      time: "8 m ago",
      notificationType: NotificationType.follow),
  NotificationDemo(
      text: "User4 vous suit",
      time: "10 m ago",
      notificationType: NotificationType.follow),
  NotificationDemo(
      text: "User5 vous suit",
      time: "6 h ago",
      notificationType: NotificationType.updown),
  NotificationDemo(
      text: "User6 vous suit",
      time: "1 day ago",
      notificationType: NotificationType.updown),
];
