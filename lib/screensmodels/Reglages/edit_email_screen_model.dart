import 'package:Gemu/locator.dart';
import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/firestore_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/models/user.dart';

class EditEmailScreenModel extends BaseModel {
  final AuthService _authService = locator<AuthService>();
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final NavigationService _navigationService = locator<NavigationService>();

  void navigateToEditProfile() {
    _navigationService.navigateTo(EditProfileScreenRoute);
  }

  Stream<UserC> get userData {
    var currentUser = _authService.currentUser;
    return _firestoreService.userData(currentUser.id);
  }

  Future updateUserEmail(String currentPassword, String newEmail) async {
    var currentUser = _authService.currentUser;

    var user = await _authService.updateEmail(
        password: currentPassword, newEmail: newEmail ?? currentUser.email);

    if (user != null) {
      await _firestoreService.updateUserEmail(
          newEmail ?? currentUser.email, currentUser.id);
    }
  }
}
