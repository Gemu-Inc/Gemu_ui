import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void messageUser(BuildContext context, String message) {
  return showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        message: message,
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: Container(),
        textStyle: Theme.of(context).textTheme.bodyLarge!,
      ),
      animationDuration: const Duration(milliseconds: 500),
      reverseAnimationDuration: const Duration(milliseconds: 500),
      displayDuration: const Duration(seconds: 6));
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
