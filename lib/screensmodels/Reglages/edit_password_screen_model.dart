import 'package:Gemu/locator.dart';
import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/services/dialog_service.dart';

class EditPasswordScreenModel extends BaseModel {
  final AuthService _authService = locator<AuthService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  void navigateToEditProfile() {
    _navigationService.navigateTo(EditProfileScreenRoute);
  }

  Future updateUserPassword(String currentPassword, String newPassword) async {
    var result = await _authService.updatePassword(
        currentPassword: currentPassword, newPassword: newPassword);

    if (result is String) {
      await _dialogService.showDialog(
        title: 'Could not change password',
        description: result,
      );
    } else {
      await _dialogService.showDialog(
        title: 'Password successfully updated',
        description: 'Your password has been changed',
      );
    }
  }
}
