import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/constants/route_names.dart';

class WelcomeScreenModel extends BaseModel {
  final NavigationService _navigationService = locator<NavigationService>();

  void navigateToSignIn() {
    _navigationService.navigateTo(LoginScreenRoute);
  }

  void navigateToRegister() {
    _navigationService.navigateTo(RegisterScreenRoute);
  }
}
