import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/services/database_service.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/models/user.dart';

class ProfilScreenModel extends BaseModel {
  final NavigationService? _navigationService = locator<NavigationService>();
  final AuthService? _authService = locator<AuthService>();
  final DatabaseService? _firestoreService = locator<DatabaseService>();

  navigateToNavigation() {
    _navigationService!.navigateTo(NavScreenRoute);
  }

  navigateToReglages() {
    _navigationService!.navigateTo(ReglagesScreenRoute);
  }
}
