import 'package:flutter/material.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/models/dialog_models.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:Gemu/styles/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DialogManager extends StatefulWidget {
  final Widget child;
  DialogManager({Key key, this.child}) : super(key: key);

  _DialogManagerState createState() => _DialogManagerState();
}

class _DialogManagerState extends State<DialogManager> {
  DialogService _dialogService = locator<DialogService>();

  @override
  void initState() {
    super.initState();
    _dialogService.registerDialogListener(_showDialog);
    _dialogService.registerDialogListenerThemeCustomLight(_openDialogLight);
    _dialogService.registerDialogListenerThemeCustomDark(_openDialogDark);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _showDialog(DialogRequest request) {
    var isConfirmationDialog = request.cancelTitle != null;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(request.title),
              content: Text(request.description),
              actions: <Widget>[
                if (isConfirmationDialog)
                  FlatButton(
                    child: Text(request.cancelTitle),
                    onPressed: () {
                      _dialogService
                          .dialogComplete(DialogResponse(confirmed: false));
                    },
                  ),
                FlatButton(
                  child: Text(request.buttonTitle),
                  onPressed: () {
                    _dialogService
                        .dialogComplete(DialogResponse(confirmed: true));
                  },
                ),
              ],
            ));
  }

  void _openDialogLight(DialogRequestThemeCustom request) {
    var isConfirmationDialog = request.cancelTitle != null;
    int currentPosition = 0;
    List<String> title = ['Primary color', 'Accent color'];
    List<Widget> content = [
      Container(
          height: 250,
          child: MaterialColorPicker(
            colors: fullMaterialColors,
            selectedColor: request.currentPrimaryColor,
            onColorChange: (color) => setState(() => themeCustomLight =
                (request.primaryColor)
                    ? themeCustomLight.copyWith(primaryColor: color)
                    : themeCustomLight.copyWith(accentColor: color)),
            onMainColorChange: (color) => setState(() => themeCustomLight =
                (request.primaryColor)
                    ? themeCustomLight.copyWith(primaryColor: color)
                    : themeCustomLight.copyWith(accentColor: color)),
          )),
      Container(
          height: 250,
          child: MaterialColorPicker(
            colors: fullMaterialColors,
            selectedColor: request.currentAccentColor,
            onColorChange: (color) => setState(() => themeCustomLight =
                (request.accentColor)
                    ? themeCustomLight.copyWith(primaryColor: color)
                    : themeCustomLight.copyWith(accentColor: color)),
            onMainColorChange: (color) => setState(() => themeCustomLight =
                (request.accentColor)
                    ? themeCustomLight.copyWith(primaryColor: color)
                    : themeCustomLight.copyWith(accentColor: color)),
          ))
    ];

    showDialog(
        context: context,
        builder: (_) => MyAlertDialog(
              isConfirmationDialog: isConfirmationDialog,
              request: request,
              currentPosition: currentPosition,
              title: title,
              content: content,
            ));
  }

  void _openDialogDark(DialogRequestThemeCustom request) {
    var isConfirmationDialog = request.cancelTitle != null;
    int currentPosition = 0;
    List<String> title = ['Primary color', 'Accent color'];
    List<Widget> content = [
      Container(
          height: 250,
          child: MaterialColorPicker(
            colors: fullMaterialColors,
            selectedColor: request.currentPrimaryColor,
            onColorChange: (color) => setState(() => themeCustomDark =
                (request.primaryColor)
                    ? themeCustomDark.copyWith(primaryColor: color)
                    : themeCustomDark.copyWith(accentColor: color)),
            onMainColorChange: (color) => setState(() => themeCustomDark =
                (request.primaryColor)
                    ? themeCustomDark.copyWith(primaryColor: color)
                    : themeCustomDark.copyWith(accentColor: color)),
          )),
      Container(
          height: 250,
          child: MaterialColorPicker(
            colors: fullMaterialColors,
            selectedColor: request.currentAccentColor,
            onColorChange: (color) => setState(() => themeCustomDark =
                (request.accentColor)
                    ? themeCustomDark.copyWith(primaryColor: color)
                    : themeCustomDark.copyWith(accentColor: color)),
            onMainColorChange: (color) => setState(() => themeCustomDark =
                (request.accentColor)
                    ? themeCustomDark.copyWith(primaryColor: color)
                    : themeCustomDark.copyWith(accentColor: color)),
          ))
    ];

    showDialog(
        context: context,
        builder: (_) => MyAlertDialog(
              isConfirmationDialog: isConfirmationDialog,
              request: request,
              currentPosition: currentPosition,
              title: title,
              content: content,
            ));
  }
}

class MyAlertDialog extends StatefulWidget {
  final isConfirmationDialog;
  final request;
  int currentPosition;
  final title;
  final content;

  MyAlertDialog(
      {@required this.isConfirmationDialog,
      @required this.request,
      @required this.currentPosition,
      @required this.title,
      @required this.content});

  @override
  _MyAlertDialogState createState() => _MyAlertDialogState();
}

class _MyAlertDialogState extends State<MyAlertDialog> {
  DialogService _dialogService = locator<DialogService>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(6.0),
      title: Text(widget.title[widget.currentPosition]),
      content: widget.content[widget.currentPosition],
      actions: [
        Row(
          children: [
            if (widget.isConfirmationDialog)
              FlatButton(
                child: Text(widget.request.cancelTitle),
                onPressed: () {
                  _dialogService
                      .dialogComplete(DialogResponse(confirmed: false));
                },
              ),
            FlatButton(
                onPressed: () => setState(() {
                      if (widget.currentPosition != 0) {
                        widget.currentPosition -= 1;
                      } else {
                        widget.currentPosition = 0;
                      }
                    }),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                )),
            FlatButton(
                onPressed: () => setState(() {
                      if (widget.currentPosition != 1) {
                        widget.currentPosition += 1;
                      } else {
                        widget.currentPosition = 1;
                      }
                    }),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                )),
            FlatButton(
                onPressed: () {
                  _dialogService
                      .dialogComplete(DialogResponse(confirmed: true));
                },
                child: Text(widget.request.confirmationTitle)),
          ],
        )
      ],
    );
  }
}
