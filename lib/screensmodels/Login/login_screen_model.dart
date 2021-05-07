import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:flutter/foundation.dart';

class LoginScreenModel extends BaseModel {
  final AuthService? _authService = locator<AuthService>();
  final NavigationService? _navigationService = locator<NavigationService>();
  final DialogService? _dialogService = locator<DialogService>();

  Future login({
    required String email,
    required String password,
  }) async {
    setBusy(true);

    var result = await _authService!.loginWithEmail(
      email: email,
      password: password,
    );

    setBusy(false);

    if (result is bool) {
      if (result) {
        _navigationService!.navigateAndRemoveUntil(NavScreenRoute);
      } else {
        await _dialogService!.showDialog(
          title: 'Login Failure',
          description: 'General login failure. Please try again later',
        );
      }
    } else {
      await _dialogService!.showDialog(
        title: 'Login Failure',
        description: result,
      );
    }
  }
}
