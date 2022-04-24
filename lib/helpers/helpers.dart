import 'package:flutter/material.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/widgets/alert_dialog_custom.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as time;

class Helpers {
  static Future<bool> willPopCallbackNav(
      BuildContext context, String navigation) async {
    await navNonAuthKey.currentState!.maybePop();
    return false;
  }

  static Future<bool> willPopCallbackShowDialog(BuildContext context) async {
    Helpers.hideKeyboard(context);
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialogCustom(context, "Annuler l'inscription",
              "Êtes-vous sur de vouloir annuler votre inscription?", [
            TextButton(
                onPressed: () {
                  Navigator.pop(mainKey.currentContext!);
                  navNonAuthKey.currentState!
                      .pushNamedAndRemoveUntil(Welcome, (route) => false);
                },
                child: Text(
                  "Oui",
                  style: textStyleCustomBold(Colors.green, 12),
                )),
            TextButton(
                onPressed: () => Navigator.pop(mainKey.currentContext!),
                child: Text(
                  "Non",
                  style: textStyleCustomBold(Colors.red, 12),
                ))
          ]);
        });
    return true;
  }

  static hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static String datePostView(int timestamp) {
    initializeDateFormatting();
    DateTime timePost = DateTime.fromMillisecondsSinceEpoch(timestamp);

    return time.format(timePost);
  }

  static String datePostInfo(int timestamp) {
    initializeDateFormatting();
    DateTime timePost = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateFormat format;

    format = new DateFormat.yMMMd("fr_FR");

    return format.format(timePost).toString();
  }

  static String dateBirthday(DateTime date) {
    initializeDateFormatting();
    DateFormat format = new DateFormat.yMMMd("fr_FR");

    return format.format(date).toString();
  }
}
