import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:Gemu/models/dialog_models.dart';

class DialogService {
  GlobalKey<NavigatorState> _dialogNavigationKey = GlobalKey<NavigatorState>();
  late Function(DialogRequest) _showDialogListener;
  late Function(DialogRequest) _showDialogConfirmationListener;
  Completer<DialogResponse>? _dialogCompleter;

  GlobalKey<NavigatorState> get dialogNavigationKey => _dialogNavigationKey;

  /// Registers a callback function. Typically to show the dialog
  void registerDialogListener(Function(DialogRequest) showDialogListener) {
    _showDialogListener = showDialogListener;
  }

  void registerDialogConfirmationListener(
      Function(DialogRequest) showDialogListener) {
    _showDialogConfirmationListener = showDialogListener;
  }

  /// Calls the dialog listener and returns a Future that will wait for dialogComplete.
  Future<DialogResponse> showDialog({
    String? title,
    String? description,
    String buttonTitle = 'Ok',
  }) {
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogListener(DialogRequest(
      title: title,
      description: description,
      buttonTitle: buttonTitle,
    ));
    return _dialogCompleter!.future;
  }

  /// Shows a confirmation dialog
  Future<DialogResponse> showConfirmationDialog(
      {required String title,
      required String description,
      String confirmationTitle = 'Ok',
      String cancelTitle = 'Cancel'}) {
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogConfirmationListener(DialogRequest(
        title: title,
        description: description,
        buttonTitle: confirmationTitle,
        cancelTitle: cancelTitle));
    return _dialogCompleter!.future;
  }

  /// Completes the _dialogCompleter to resume the Future's execution call
  void dialogComplete(DialogResponse response) {
    _dialogNavigationKey.currentState!.pop();
    _dialogCompleter!.complete(response);
    _dialogCompleter = null;
  }
}
