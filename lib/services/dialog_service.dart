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
  Function(DialogRequestThemeCustom) _showDialogListenerThemeCustomLight;
  Function(DialogRequestThemeCustom) _showDialogListenerThemeCustomDark;
  Completer<DialogResponse> _dialogCompleter;

  GlobalKey<NavigatorState> get dialogNavigationKey => _dialogNavigationKey;

  /// Registers a callback function. Typically to show the dialog
  void registerDialogListener(Function(DialogRequest) showDialogListener) {
    _showDialogListener = showDialogListener;
  }

  void registerDialogListenerThemeCustomLight(
      Function(DialogRequestThemeCustom) showDialogListener) {
    _showDialogListenerThemeCustomLight = showDialogListener;
  }

  void registerDialogListenerThemeCustomDark(
      Function(DialogRequestThemeCustom) showDialogListener) {
    _showDialogListenerThemeCustomDark = showDialogListener;
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

  Future<DialogResponse> showDialogThemeCustomLight(
      {@required Color currentPrimaryColor,
      @required Color currentAccentColor,
      @required bool primaryColor,
      @required bool accentColor,
      String confirmationTitle = 'Done',
      String cancelTitle = 'Cancel'}) {
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogListenerThemeCustomLight(DialogRequestThemeCustom(
        currentPrimaryColor: currentPrimaryColor,
        currentAccentColor: currentAccentColor,
        confirmationTitle: confirmationTitle,
        cancelTitle: cancelTitle,
        primaryColor: primaryColor,
        accentColor: accentColor));
    return _dialogCompleter.future;
  }

  Future<DialogResponse> showDialogThemeCustomDark(
      {@required Color currentPrimaryColor,
      @required Color currentAccentColor,
      @required bool primaryColor,
      @required bool accentColor,
      String confirmationTitle = 'Done',
      String cancelTitle = 'Cancel'}) {
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogListenerThemeCustomDark(DialogRequestThemeCustom(
        currentPrimaryColor: currentPrimaryColor,
        currentAccentColor: currentAccentColor,
        confirmationTitle: confirmationTitle,
        cancelTitle: cancelTitle,
        primaryColor: primaryColor,
        accentColor: accentColor));
    return _dialogCompleter.future;
  }

  /// Completes the _dialogCompleter to resume the Future's execution call
  void dialogComplete(DialogResponse response) {
    _dialogNavigationKey.currentState.pop();
    _dialogCompleter.complete(response);
    _dialogCompleter = null;
  }
}
