import 'package:flutter/material.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:gemu/services/database_service.dart';
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
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
    ),
    leading: const Icon(
      Icons.info,
      size: 33,
    ),
    backgroundColor: Theme.of(context).colorScheme.primary,
    actions: [
      TextButton(
          onPressed: () async {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            await AuthService.sendMailVerifyEmail();
            messageUser(
                context, "Vous allez être déconnecter dans quelques instants");
            await AuthService.signOut();
          },
          child: Text(
            'Vérifier',
            style: Theme.of(context).textTheme.bodySmall,
          )),
      TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
          child: Text(
            'Plus tard',
            style: Theme.of(context).textTheme.bodySmall,
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
