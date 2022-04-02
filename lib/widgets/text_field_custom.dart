import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/riverpod/Login/login_provider.dart';

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
        cursorColor: Theme.of(context).colorScheme.primary,
        keyboardType: widget.textInputType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.submit,
        decoration: InputDecoration(
            fillColor: Theme.of(context).canvasColor,
            filled: true,
            labelText: widget.label,
            // labelStyle:
            //    style( 13,
            //     widget.focusNode.hasFocus
            //         ? Theme.of(context).colorScheme.primary
            //         : Colors.grey
            //         ),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary)),
            prefixIcon: Icon(widget.icon,
                color: widget.focusNode.hasFocus
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey),
            suffixIcon: widget.controller.text.isEmpty
                ? SizedBox()
                : widget.obscure
                    ? IconButton(
                        icon: Icon(
                          Icons.remove_red_eye_sharp,
                          color: widget.focusNode.hasFocus
                              ? Theme.of(context).colorScheme.primary
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
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                        onPressed: widget.clear)));
  }
}

class TextFieldCustomLogin extends ConsumerStatefulWidget {
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
  final Function(String)? changed;
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
      required this.changed,
      required this.isDayMood})
      : super(key: key);

  @override
  _TextFieldCustomLoginState createState() => _TextFieldCustomLoginState();
}

class _TextFieldCustomLoginState extends ConsumerState<TextFieldCustomLogin> {
  late bool pwdVisible;

  @override
  void initState() {
    super.initState();
    if (widget.obscure) {
      Future.delayed(
          Duration.zero,
          () => ref
              .read(passwordVisibilityNotifierProvider.notifier)
              .updateVisibilityPassword(true));
    }
  }

  @override
  Widget build(BuildContext context) {
    pwdVisible = ref.watch(passwordVisibilityNotifierProvider);
    return TextField(
        maxLines: 1,
        obscureText: widget.obscure ? pwdVisible : false,
        controller: widget.controller,
        focusNode: widget.focusNode,
        cursorColor: widget.isDayMood ? cPrimaryPurple : cPrimaryPink,
        keyboardType: widget.textInputType,
        textInputAction: widget.textInputAction,
        onChanged: widget.changed,
        onSubmitted: widget.submit,
        decoration: InputDecoration(
            fillColor: Theme.of(context).canvasColor,
            filled: true,
            labelText: widget.label,
            labelStyle: textStyleCustom(
                widget.focusNode.hasFocus
                    ? widget.isDayMood
                        ? cSecondaryPurple
                        : cPrimaryPink
                    : Colors.grey,
                13),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: widget.isDayMood ? cPrimaryPurple : cPrimaryPink,
            )),
            prefixIcon: Icon(widget.icon,
                color: widget.focusNode.hasFocus
                    ? widget.isDayMood
                        ? cSecondaryPurple
                        : cPrimaryPink
                    : Colors.grey),
            suffixIcon: widget.controller.text.isEmpty
                ? SizedBox()
                : widget.obscure
                    ? IconButton(
                        icon: Icon(
                          Icons.remove_red_eye_sharp,
                          color: widget.focusNode.hasFocus
                              ? widget.isDayMood
                                  ? cSecondaryPurple
                                  : cPrimaryPink
                              : Colors.grey,
                        ),
                        onPressed: () {
                          ref
                              .read(passwordVisibilityNotifierProvider.notifier)
                              .updateVisibilityPassword(!pwdVisible);
                        })
                    : IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: widget.focusNode.hasFocus
                              ? widget.isDayMood
                                  ? cSecondaryPurple
                                  : cPrimaryPink
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
        cursorColor: widget.isDayMood ? cPrimaryPink : cPrimaryPurple,
        keyboardType: widget.textInputType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.submit,
        decoration: InputDecoration(
            fillColor: Theme.of(context).canvasColor,
            filled: true,
            labelText: widget.label,
            labelStyle: textStyleCustom(
                widget.focusNode.hasFocus
                    ? widget.isDayMood
                        ? cPrimaryPink
                        : cPrimaryPurple
                    : Colors.grey,
                13),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: widget.isDayMood ? cPrimaryPink : cPrimaryPurple,
            )),
            prefixIcon: Icon(widget.icon,
                color: widget.focusNode.hasFocus
                    ? widget.isDayMood
                        ? cPrimaryPink
                        : cSecondaryPurple
                    : Colors.grey),
            suffixIcon: widget.controller.text.isEmpty
                ? SizedBox()
                : widget.obscure
                    ? IconButton(
                        icon: Icon(
                          Icons.remove_red_eye_sharp,
                          color: widget.focusNode.hasFocus
                              ? widget.isDayMood
                                  ? cPrimaryPink
                                  : cSecondaryPurple
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
                                  ? cPrimaryPink
                                  : cSecondaryPurple
                              : Colors.grey,
                        ),
                        onPressed: widget.clear)));
  }
}
