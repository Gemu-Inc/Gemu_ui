import 'package:Gemu/locator.dart';
import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/firestore_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/models/user.dart';
import 'package:Gemu/services/dialog_service.dart';

class EditUserNameScreenModel extends BaseModel {
  final AuthService _authService = locator<AuthService>();
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  void navigateToEditProfile() {
    _navigationService.navigateAndRemoveUntil(EditProfileScreenRoute);
  }

  Stream<UserC> get userData {
    var currentUser = _authService.currentUser;
    return _firestoreService.userData(currentUser.id);
  }

  Future updateUserPseudo(String currentName, var currentUserID) async {
    //var currentUser = _authService.currentUser;

    var result = await _firestoreService.updateUserPseudo(
        currentName ?? currentUser.pseudo, currentUserID);

    if (result is String) {
      await _dialogService.showDialog(
        title: 'Could not change username',
        description: result,
      );
    } else {
      await _dialogService.showDialog(
        title: 'Username successfully updated',
        description: 'Your username has been changed',
      );
    }
  }
}
