import 'package:flutter/material.dart';

import 'package:gemu/constants/constants.dart';

class TextFieldCustom extends StatefulWidget {
  final BuildContext context;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final bool obscure;
  final IconData icon;
  final TextInputAction textInputAction;
  final TextInputType? textInputType;
  final Function() clear;
  final Function(String)? submit;

  const TextFieldCustom(
      {Key? key,
      required this.context,
      required this.controller,
      required this.focusNode,
      required this.label,
      required this.obscure,
      required this.icon,
      required this.textInputAction,
      this.textInputType,
      required this.clear,
      this.submit})
      : super(key: key);

  @override
  _TextFieldCustomState createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  bool pwdVisible = false;

  @override
  void initState() {
    if (widget.obscure) {
      setState(() {
        pwdVisible = !pwdVisible;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        maxLines: 1,
        obscureText: pwdVisible,
        controller: widget.controller,
        focusNode: widget.focusNode,
        cursorColor: Theme.of(context).primaryColor,
        keyboardType: widget.textInputType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.submit,
        decoration: InputDecoration(
            fillColor: Theme.of(context).canvasColor,
            filled: true,
            labelText: widget.label,
            labelStyle: mystyle(
                13,
                widget.focusNode.hasFocus
                    ? Theme.of(context).primaryColor
                    : Colors.grey),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            prefixIcon: Icon(widget.icon,
                color: widget.focusNode.hasFocus
                    ? Theme.of(context).primaryColor
                    : Colors.grey),
            suffixIcon: widget.controller.text.isEmpty
                ? SizedBox()
                : widget.obscure
                    ? IconButton(
                        icon: Icon(
                          Icons.remove_red_eye_sharp,
                          color: widget.focusNode.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            pwdVisible = !pwdVisible;
                          });
                        })
                    : IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: widget.focusNode.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        onPressed: widget.clear)));
  }
}

class TextFieldCustomLogin extends StatefulWidget {
  final BuildContext context;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final bool obscure;
  final IconData icon;
  final TextInputAction textInputAction;
  final TextInputType? textInputType;
  final Function() clear;
  final Function(String)? submit;
  final bool isDayMood;

  const TextFieldCustomLogin(
      {Key? key,
      required this.context,
      required this.controller,
      required this.focusNode,
      required this.label,
      required this.obscure,
      required this.icon,
      required this.textInputAction,
      this.textInputType,
      required this.clear,
      this.submit,
      required this.isDayMood})
      : super(key: key);

  @override
  _TextFieldCustomLoginState createState() => _TextFieldCustomLoginState();
}

class _TextFieldCustomLoginState extends State<TextFieldCustomLogin> {
  bool pwdVisible = false;

  @override
  void initState() {
    if (widget.obscure) {
      setState(() {
        pwdVisible = !pwdVisible;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        maxLines: 1,
        obscureText: pwdVisible,
        controller: widget.controller,
        focusNode: widget.focusNode,
        cursorColor: widget.isDayMood ? cPurpleBtn : cPinkBtn,
        keyboardType: widget.textInputType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.submit,
        decoration: InputDecoration(
            fillColor: Theme.of(context).canvasColor,
            filled: true,
            labelText: widget.label,
            labelStyle: mystyle(
                13,
                widget.focusNode.hasFocus
                    ? widget.isDayMood
                        ? cLightPurple
                        : cDarkPink
                    : Colors.grey),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: widget.isDayMood ? cPurpleBtn : cPinkBtn,
            )),
            prefixIcon: Icon(widget.icon,
                color: widget.focusNode.hasFocus
                    ? widget.isDayMood
                        ? cLightPurple
                        : cDarkPink
                    : Colors.grey),
            suffixIcon: widget.controller.text.isEmpty
                ? SizedBox()
                : widget.obscure
                    ? IconButton(
                        icon: Icon(
                          Icons.remove_red_eye_sharp,
                          color: widget.focusNode.hasFocus
                              ? widget.isDayMood
                                  ? cLightPurple
                                  : cDarkPink
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            pwdVisible = !pwdVisible;
                          });
                        })
                    : IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: widget.focusNode.hasFocus
                              ? widget.isDayMood
                                  ? cLightPurple
                                  : cDarkPink
                              : Colors.grey,
                        ),
                        onPressed: widget.clear)));
  }
}

class TextFieldCustomRegister extends StatefulWidget {
  final BuildContext context;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final bool obscure;
  final IconData icon;
  final TextInputAction textInputAction;
  final TextInputType? textInputType;
  final Function() clear;
  final Function(String)? submit;
  final bool isDayMood;

  const TextFieldCustomRegister(
      {Key? key,
      required this.context,
      required this.controller,
      required this.focusNode,
      required this.label,
      required this.obscure,
      required this.icon,
      required this.textInputAction,
      this.textInputType,
      required this.clear,
      this.submit,
      required this.isDayMood})
      : super(key: key);

  @override
  _TextFieldCustomRegisterState createState() =>
      _TextFieldCustomRegisterState();
}

class _TextFieldCustomRegisterState extends State<TextFieldCustomRegister> {
  bool pwdVisible = false;

  @override
  void initState() {
    if (widget.obscure) {
      setState(() {
        pwdVisible = !pwdVisible;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        maxLines: 1,
        obscureText: pwdVisible,
        controller: widget.controller,
        focusNode: widget.focusNode,
        cursorColor: widget.isDayMood ? cPinkBtn : cPurpleBtn,
        keyboardType: widget.textInputType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.submit,
        decoration: InputDecoration(
            fillColor: Theme.of(context).canvasColor,
            filled: true,
            labelText: widget.label,
            labelStyle: mystyle(
                13,
                widget.focusNode.hasFocus
                    ? widget.isDayMood
                        ? cDarkPink
                        : cLightPurple
                    : Colors.grey),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: widget.isDayMood ? cPinkBtn : cPurpleBtn,
            )),
            prefixIcon: Icon(widget.icon,
                color: widget.focusNode.hasFocus
                    ? widget.isDayMood
                        ? cDarkPink
                        : cLightPurple
                    : Colors.grey),
            suffixIcon: widget.controller.text.isEmpty
                ? SizedBox()
                : widget.obscure
                    ? IconButton(
                        icon: Icon(
                          Icons.remove_red_eye_sharp,
                          color: widget.focusNode.hasFocus
                              ? widget.isDayMood
                                  ? cDarkPink
                                  : cLightPurple
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            pwdVisible = !pwdVisible;
                          });
                        })
                    : IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: widget.focusNode.hasFocus
                              ? widget.isDayMood
                                  ? cDarkPink
                                  : cLightPurple
                              : Colors.grey,
                        ),
                        onPressed: widget.clear)));
  }
}
