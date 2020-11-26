import 'dart:async';
import 'package:Gemu/constants/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:Gemu/models/dialog_models.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/navigation_service.dart';

class DialogService {
  GlobalKey<NavigatorState> _dialogNavigationKey = GlobalKey<NavigatorState>();
  Function(DialogRequest) _showDialogListener;
  Function(DialogRequestLightCustom) _showDialogListenerLightCustom;
  Function(DialogRequestDarkCustom) _showDialogListenerDarkCustom;
  Completer<DialogResponse> _dialogCompleter;

  GlobalKey<NavigatorState> get dialogNavigationKey => _dialogNavigationKey;

  /// Registers a callback function. Typically to show the dialog
  void registerDialogListener(Function(DialogRequest) showDialogListener) {
    _showDialogListener = showDialogListener;
  }

  void registerDialogListenerLightCustom(
      Function(DialogRequestLightCustom) showDialogListener) {
    _showDialogListenerLightCustom = showDialogListener;
  }

  void registerDialogListenerDarkCustom(
      Function(DialogRequestDarkCustom) showDialogListener) {
    _showDialogListenerDarkCustom = showDialogListener;
  }

  /// Calls the dialog listener and returns a Future that will wait for dialogComplete.
  Future<DialogResponse> showDialog({
    String title,
    String description,
    String buttonTitle = 'Ok',
  }) {
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogListener(DialogRequest(
      title: title,
      description: description,
      buttonTitle: buttonTitle,
    ));
    return _dialogCompleter.future;
  }

  /// Shows a confirmation dialog
  Future<DialogResponse> showConfirmationDialog(
      {@required String title,
      @required String description,
      String confirmationTitle = 'Ok',
      String cancelTitle = 'Cancel'}) {
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogListener(DialogRequest(
        title: title,
        description: description,
        buttonTitle: confirmationTitle,
        cancelTitle: cancelTitle));
    return _dialogCompleter.future;
  }

  Future<DialogResponse> showDialogLightCustom(
      {@required String title,
      @required Color currentColor,
      @required bool primaryColor,
      String confirmationTitle = 'Done'}) {
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogListenerLightCustom(DialogRequestLightCustom(
        title: title,
        currentColor: currentColor,
        primaryColor: primaryColor,
        buttonTitle: confirmationTitle));
    return _dialogCompleter.future;
  }

  Future<DialogResponse> showDialogDarkCustom(
      {@required String title,
      @required Color currentColor,
      @required bool primaryColor,
      String confirmationTitle = 'Done'}) {
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogListenerDarkCustom(DialogRequestDarkCustom(
        title: title,
        currentColor: currentColor,
        primaryColor: primaryColor,
        buttonTitle: confirmationTitle));
    return _dialogCompleter.future;
  }

  /// Completes the _dialogCompleter to resume the Future's execution call
  void dialogComplete(DialogResponse response) {
    _dialogNavigationKey.currentState.pop();
    _dialogCompleter.complete(response);
    _dialogCompleter = null;
  }
}
