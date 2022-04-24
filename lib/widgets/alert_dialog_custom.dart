import 'package:flutter/material.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/services/auth_service.dart';

class AlertDialogCustom extends AlertDialog {
  AlertDialogCustom(
      BuildContext context, String title, String content, List<Widget> actions)
      : super(
            backgroundColor: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            content:
                Text(content, style: Theme.of(context).textTheme.bodyLarge),
            actions: actions);
}

class AlertDialogResetPassword extends AlertDialog {
  AlertDialogResetPassword(
      BuildContext context, String title, Widget content, List<Widget> actions)
      : super(
            backgroundColor: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            content: content,
            actions: actions);
}

Future verifyAccount(BuildContext context) {
  return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.white,
                size: 44,
              ),
              Text(
                "Vérifier mon compte",
                style: textStyleCustomBold(Colors.white, 14),
                textAlign: TextAlign.center,
              )
            ],
          ),
          content: Text(
            "Afin de sécuriser ton compte, tu peux dès maintenant vérifier ton email!",
            style: textStyleCustomBold(Colors.white, 14),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  Navigator.pop(mainKey.currentContext!);
                  await AuthService.sendMailVerifyEmail(context);
                },
                child: Text(
                  'Vérifier',
                  style: textStyleCustomBold(Colors.green, 12),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(mainKey.currentContext!);
                },
                child: Text(
                  'Plus tard',
                  style: textStyleCustomBold(Colors.red, 12),
                )),
          ],
        );
      });
}
