import 'package:flutter/material.dart';

import 'package:gemu/constants/constants.dart';

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
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15.0)),
              child: Text(
                error,
                style: mystyle(
                    12,
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
              ),
            ));
}
