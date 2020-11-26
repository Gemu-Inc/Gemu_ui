import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/styles/styles.dart';

class DesignScreenModel extends BaseModel {
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();

  void navigateToProfilMenu() {
    _navigationService.pop();
  }

  Future openDialogLightPrimaryColor() async {
    await _dialogService.showDialogLightCustom(
        title: 'Primary Color',
        currentColor: lightThemeCustom.primaryColor,
        primaryColor: true);
  }

  Future openDialogLightAccentColor() async {
    await _dialogService.showDialogLightCustom(
        title: 'Accent Color',
        currentColor: lightThemeCustom.accentColor,
        primaryColor: false);
  }

  Future openDialogDarkPrimaryColor() async {
    await _dialogService.showDialogDarkCustom(
        title: 'Primary Color',
        currentColor: darkThemeCustom.primaryColor,
        primaryColor: true);
  }

  Future openDialogDarkAccentColor() async {
    await _dialogService.showDialogDarkCustom(
        title: 'Accent Color',
        currentColor: darkThemeCustom.accentColor,
        primaryColor: false);
  }
}
