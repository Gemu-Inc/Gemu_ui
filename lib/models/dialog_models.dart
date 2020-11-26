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

class DialogRequestLightCustom {
  final String title;
  final Color currentColor;
  final bool primaryColor;
  final String buttonTitle;
  final String cancelTitle;

  DialogRequestLightCustom(
      {@required this.title,
      @required this.currentColor,
      @required this.primaryColor,
      @required this.buttonTitle,
      this.cancelTitle});
}

class DialogRequestDarkCustom {
  final String title;
  final Color currentColor;
  final bool primaryColor;
  final String buttonTitle;
  final String cancelTitle;

  DialogRequestDarkCustom(
      {@required this.title,
      @required this.currentColor,
      @required this.primaryColor,
      @required this.buttonTitle,
      this.cancelTitle});
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
