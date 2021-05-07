import 'package:Gemu/locator.dart';
import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/database_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/models/user.dart';
import 'package:Gemu/services/dialog_service.dart';

class EditEmailScreenModel extends BaseModel {
  final AuthService? _authService = locator<AuthService>();
  final DatabaseService? _firestoreService = locator<DatabaseService>();
  final NavigationService? _navigationService = locator<NavigationService>();
  final DialogService? _dialogService = locator<DialogService>();

  void navigateToEditProfile() {
    _navigationService!.navigateTo(EditProfileScreenRoute);
  }

  Future updateUserEmail(
      String currentPassword, String? newEmail, var currentUserID) async {
    //var currentUser = _authService.currentUser;

    var result = await _authService!.updateEmail(
        password: currentPassword, newEmail: newEmail ?? currentUser!.email!);

    print(result);

    if (result is String) {
      await _dialogService!.showDialog(
        title: 'Could not change email',
        description: result,
      );
    } else {
      await _firestoreService!
          .updateUserEmail(newEmail ?? currentUser!.email, currentUserID);
      await _dialogService!.showDialog(
        title: 'Email successfully updated',
        description: 'Your email has been changed',
      );
    }
  }
}
