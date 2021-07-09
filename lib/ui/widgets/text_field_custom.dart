import 'package:flutter/material.dart';

import 'package:gemu/ui/constants/constants.dart';

class TextFieldCustom extends TextField {
  TextFieldCustom(
      {required BuildContext context,
      required TextEditingController controller,
      required String label,
      required bool obscure,
      required IconData icon})
      : super(
            obscureText: obscure,
            controller: controller,
            cursorColor: Theme.of(context).accentColor,
            decoration: InputDecoration(
                fillColor: Theme.of(context).canvasColor,
                filled: true,
                labelText: label,
                labelStyle: mystyle(15, Theme.of(context).accentColor),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor)),
                prefixIcon: Icon(
                  icon,
                  color: Theme.of(context).accentColor,
                ),
                suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () => controller.clear())));
}
