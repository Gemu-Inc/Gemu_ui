import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/services/firestore_service.dart';
import 'package:Gemu/services/cloud_storage_service.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/models/user.dart';

class NavScreenModel extends BaseModel {
  final AuthService _authService = locator<AuthService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final DialogService _dialogService = locator<DialogService>();
  final CloudStorageService _cloudStorageService =
      locator<CloudStorageService>();
}
