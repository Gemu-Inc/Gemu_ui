import 'package:flutter/material.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/models/dialog_models.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:Gemu/styles/styles.dart';

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
    _dialogService.registerDialogListenerLightCustom(_openDialogLight);
    _dialogService.registerDialogListenerDarkCustom(_openDialogDark);
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

  void _openDialogLight(DialogRequestLightCustom request) {
    var isConfirmationDialog = request.cancelTitle != null;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(request.title),
          content: Container(
              height: 250,
              child: MaterialColorPicker(
                selectedColor: request.currentColor,
                onColorChange: (color) => setState(() => lightThemeCustom =
                    (request.primaryColor)
                        ? lightThemeCustom.copyWith(primaryColor: color)
                        : lightThemeCustom.copyWith(accentColor: color)),
                onMainColorChange: (color) => setState(() => lightThemeCustom =
                    (request.primaryColor)
                        ? lightThemeCustom.copyWith(primaryColor: color)
                        : lightThemeCustom.copyWith(accentColor: color)),
              )),
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
              onPressed: () {
                _dialogService.dialogComplete(DialogResponse(confirmed: true));
              },
              child: Text(
                request.buttonTitle,
                style: Theme.of(context).textTheme.button,
              ),
            )
          ],
        );
      },
    );
  }

  void _openDialogDark(DialogRequestDarkCustom request) {
    var isConfirmationDialog = request.cancelTitle != null;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(request.title),
          content: Container(
              height: 250,
              child: MaterialColorPicker(
                selectedColor: request.currentColor,
                onColorChange: (color) => setState(() => darkThemeCustom =
                    (request.primaryColor)
                        ? darkThemeCustom.copyWith(primaryColor: color)
                        : darkThemeCustom.copyWith(accentColor: color)),
                onMainColorChange: (color) => setState(() => darkThemeCustom =
                    (request.primaryColor)
                        ? darkThemeCustom.copyWith(primaryColor: color)
                        : darkThemeCustom.copyWith(accentColor: color)),
              )),
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
              onPressed: () {
                _dialogService.dialogComplete(DialogResponse(confirmed: true));
              },
              child: Text(
                request.buttonTitle,
                style: Theme.of(context).textTheme.button,
              ),
            )
          ],
        );
      },
    );
  }
}
