import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/styles/styles.dart';

class DesignScreenModel extends BaseModel {
  final DialogService? _dialogService = locator<DialogService>();
  final NavigationService? _navigationService = locator<NavigationService>();

  void navigateToProfilMenu() {
    _navigationService!.pop();
  }

  /*Future openDialogThemeCustomLight() async {
    await _dialogService.showDialogThemeCustomLight(
        currentPrimaryColor: themeCustomLight.primaryColor,
        currentAccentColor: themeCustomLight.accentColor,
        primaryColor: true,
        accentColor: false);
  }

  Future openDialogThemeCustomDark() async {
    await _dialogService.showDialogThemeCustomDark(
        currentPrimaryColor: themeCustomDark.primaryColor,
        currentAccentColor: themeCustomDark.accentColor,
        primaryColor: true,
        accentColor: false);
  }*/
}
