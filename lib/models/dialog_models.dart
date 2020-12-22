import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DialogRequest {
  final String title;
  final String description;
  final String buttonTitle;
  final String cancelTitle;

  DialogRequest(
      {@required this.title,
      @required this.description,
      @required this.buttonTitle,
      this.cancelTitle});
}

class DialogRequestThemeCustom {
  final Color currentPrimaryColor;
  final Color currentAccentColor;
  final String confirmationTitle;
  final String cancelTitle;
  final bool primaryColor;
  final bool accentColor;

  DialogRequestThemeCustom(
      {@required this.currentPrimaryColor,
      @required this.currentAccentColor,
      @required this.confirmationTitle,
      @required this.cancelTitle,
      @required this.primaryColor,
      @required this.accentColor});
}

class DialogRequestReAuth {
  final String title;
  final String description;
  String password;
  final String confirmationTitle;
  final String cancelTitle;

  DialogRequestReAuth(
      {@required this.title,
      @required this.description,
      @required this.password,
      @required this.confirmationTitle,
      @required this.cancelTitle});
}

class DialogResponse {
  final String fieldOne;
  final String fieldTwo;
  final bool confirmed;

  DialogResponse({
    this.fieldOne,
    this.fieldTwo,
    this.confirmed,
  });
}
