import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/navigation_service.dart';

class ProfilScreenModel extends BaseModel {
  final NavigationService _navigationService = locator<NavigationService>();

  navigateToNavigation() {
    _navigationService.pop();
  }

  navigateToReglages() {
    _navigationService.navigateTo(ReglagesScreenRoute);
  }
}
