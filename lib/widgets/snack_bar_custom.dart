import 'package:flutter/material.dart';

import 'package:gemu/constants/constants.dart';

class SnackBarCustom extends SnackBar {
  SnackBarCustom(
      {required BuildContext context,
      required String error,
      required double padddingVertical})
      : super(
            padding: EdgeInsets.symmetric(
                vertical: padddingVertical, horizontal: 15.0),
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color(0xFF222831).withOpacity(0.8),
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15.0)),
              child: Text(
                error,
                style: mystyle(12, Colors.white),
              ),
            ));
}