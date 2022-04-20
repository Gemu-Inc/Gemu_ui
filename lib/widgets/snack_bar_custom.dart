import 'package:flutter/material.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void messageUser(BuildContext context, String message) {
  return showTopSnackBar(
      context,
      CustomSnackBar.info(
        message: message,
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: Container(),
        textStyle: Theme.of(context).textTheme.bodyLarge!,
      ),
      leftPadding: 15,
      rightPadding: 15,
      showOutAnimationDuration: const Duration(milliseconds: 500),
      hideOutAnimationDuration: const Duration(milliseconds: 500),
      displayDuration: const Duration(seconds: 6));
}

void verifyAccount(BuildContext context) {
  ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
    content: Text(
      "Afin de sécuriser ton compte, tu peux dès maintenant vérifier ton email",
      style: textStyleCustom(Colors.white, 10),
      textAlign: TextAlign.center,
    ),
    leading: const Icon(
      Icons.warning,
      size: 30,
      color: Colors.white,
    ),
    backgroundColor: Theme.of(context).colorScheme.primary,
    actions: [
      TextButton(
          onPressed: () async {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            await AuthService.sendMailVerifyEmail(context);
            await Future.delayed(Duration(seconds: 5));
            await AuthService.signOut();
          },
          child: Text(
            'Vérifier',
            style: textStyleCustom(Colors.white, 10),
          )),
      TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
          child: Text(
            'Plus tard',
            style: textStyleCustom(Colors.white, 10),
          )),
    ],
  ));
}

class SnackBarCustom extends SnackBar {
  SnackBarCustom({
    required BuildContext context,
    required String error,
  }) : super(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(15.0)),
              child: Text(
                error,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ));
}
