import 'package:flutter/material.dart';

import 'package:gemu/constants/constants.dart';

class TextFieldCustom extends TextField {
  TextFieldCustom({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool obscure,
    required IconData icon,
    required TextInputAction textInputAction,
    TextInputType? textInputType,
    required Function() clear,
    Function(String)? submit,
  }) : super(
            obscureText: obscure,
            controller: controller,
            focusNode: focusNode,
            cursorColor: Theme.of(context).primaryColor,
            keyboardType: textInputType,
            textInputAction: textInputAction,
            onSubmitted: submit,
            decoration: InputDecoration(
                fillColor: Theme.of(context).canvasColor,
                filled: true,
                labelText: label,
                labelStyle: mystyle(
                    15,
                    focusNode.hasFocus
                        ? Theme.of(context).primaryColor
                        : Colors.grey),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor)),
                prefixIcon: Icon(icon,
                    color: focusNode.hasFocus
                        ? Theme.of(context).primaryColor
                        : Colors.grey),
                suffixIcon: controller.text.isEmpty
                    ? SizedBox()
                    : IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: focusNode.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        onPressed: clear)));
}
