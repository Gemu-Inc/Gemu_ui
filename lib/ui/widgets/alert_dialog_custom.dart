import 'package:flutter/material.dart';

class AlertDialogCustom extends AlertDialog {
  AlertDialogCustom(
      BuildContext context, String title, String content, List<Widget> actions)
      : super(
            backgroundColor: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            title: Text(title),
            content: Text(content),
            actions: actions);
}
