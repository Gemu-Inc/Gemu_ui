import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/locator.dart';
import 'package:flutter/foundation.dart';

class RegisterScreenModel extends BaseModel {
  final AuthService _authService = locator<AuthService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  Future signUp(
      {@required String pseudo,
      @required String email,
      @required String password}) async {
    setBusy(true);

    var result = await _authService.signUpWithEmail(
        email: email,
        password: password,
        pseudo: pseudo,
        photoURL: null,
        points: '0');

    setBusy(false);

    if (result is bool) {
      if (result) {
        _navigationService.navigateAndRemoveUntil(NavScreenRoute);
      } else {
        await _dialogService.showDialog(
          title: 'Sign Up Failure',
          description: 'General sign up failure. Please try again later',
        );
      }
    } else {
      await _dialogService.showDialog(
        title: 'Sign Up Failure',
        description: result,
      );
    }
  }
}
