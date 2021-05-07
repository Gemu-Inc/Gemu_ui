import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/locator.dart';

class StartUpScreenModel extends BaseModel {
  final AuthService? _authService = locator<AuthService>();
  final NavigationService? _navigationService = locator<NavigationService>();

  Future handleStartUpLogic() async {
    var hasLoggedInUser = await _authService!.isUserLoggedIn();
    if (hasLoggedInUser) {
      _navigationService!.navigateAndRemoveUntil(NavScreenRoute);
    } else {
      _navigationService!.navigateAndRemoveUntil(WelcomeScreenRoute);
    }
  }
}
