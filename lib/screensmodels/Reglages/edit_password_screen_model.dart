import 'package:Gemu/locator.dart';
import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/navigation_service.dart';

class EditPasswordScreenModel extends BaseModel {
  final AuthService _authService = locator<AuthService>();
  final NavigationService _navigationService = locator<NavigationService>();

  void navigateToEditProfile() {
    _navigationService.navigateTo(EditProfileScreenRoute);
  }

  Future updateUserPassword(String currentPassword, String newPassword) async {
    await _authService.updatePassword(
        currentPassword: currentPassword, newPassword: newPassword);
  }
}
