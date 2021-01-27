import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/firestore_service.dart';
import 'package:Gemu/models/user.dart';

class HighlightScreenModel extends BaseModel {
  final AuthService _authService = locator<AuthService>();
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final NavigationService _navigationService = locator<NavigationService>();

  Stream<UserC> get userData {
    var currentUser = _authService.currentUser;
    return _firestoreService.userData(currentUser.id);
  }

  void navigateToProfil() {
    _navigationService.navigateTo(ProfilMenuRoute);
  }

  void navigateToSearch() {
    _navigationService.navigateTo(SearchScreenRoute);
  }
}
