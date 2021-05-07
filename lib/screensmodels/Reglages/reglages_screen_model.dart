import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/constants/route_names.dart';

class ReglagesScreenModel extends BaseModel {
  final AuthService? _authService = locator<AuthService>();
  final NavigationService? _navigationService = locator<NavigationService>();
  final DialogService? _dialogService = locator<DialogService>();

  void navigateToProfile() {
    _navigationService!.pop();
  }

  void navigateToEditProfile() {
    _navigationService!.navigateTo(EditProfileScreenRoute);
  }

  void navigateToDesign() {
    _navigationService!.navigateTo(DesignScreenRoute);
  }

  Future userSignOut() async {
    var dialogResponse = await _dialogService!.showConfirmationDialog(
        title: 'Déconnexion',
        description: 'Êtes-vous sur?',
        confirmationTitle: 'Yes',
        cancelTitle: 'No');

    if (dialogResponse.confirmed!) {
      setBusy(true);
      await _authService!.signOut();
      setBusy(false);
      _navigationService!.navigateAndRemoveUntil(ConnectionScreenRoute);
    }
  }
}
