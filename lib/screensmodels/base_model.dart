import 'package:Gemu/locator.dart';
import 'package:Gemu/models/user.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:flutter/widgets.dart';

class BaseModel extends ChangeNotifier {
  final AuthService _authenticationService = locator<AuthService>();

  UserC get currentUser => _authenticationService.currentUser;

  bool _busy = false;
  bool get busy => _busy;

  void setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }
}
