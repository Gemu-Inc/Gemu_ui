import 'dart:io';
import 'package:Gemu/locator.dart';
import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/firestore_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/models/user.dart';

class EditUserNameScreenModel extends BaseModel {
  final AuthService _authService = locator<AuthService>();
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final NavigationService _navigationService = locator<NavigationService>();

  void navigateToEditProfile() {
    _navigationService.navigateAndRemoveUntil(EditProfileScreenRoute);
  }

  Stream<UserC> get userData {
    var currentUser = _authService.currentUser;
    return _firestoreService.userData(currentUser.id);
  }

  Future updateUserPseudo(String currentName) async {
    var currentUser = _authService.currentUser;

    await _firestoreService.updateUserPseudo(
        currentName ?? currentUser.pseudo, currentUser.id);
  }
}
