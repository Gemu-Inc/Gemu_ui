import 'package:flutter/material.dart';

import 'package:gemu/ui/constants/size_config.dart';
import 'package:gemu/ui/constants/constants.dart';

class SnackBarCustom extends SnackBar {
  SnackBarCustom({required String error})
      : super(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Container(
              height: 50,
              width: SizeConfig.screenWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color(0xFF222831),
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15.0)),
              child: Text(
                error,
                style: mystyle(12, Colors.white),
              ),
            ));
}
