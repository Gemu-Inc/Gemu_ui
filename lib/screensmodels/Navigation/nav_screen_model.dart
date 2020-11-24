import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NavScreenModel extends BaseModel {
  final NavigationService _navigationService = locator<NavigationService>();

  void navigateToProfil() {
    _navigationService.navigateTo(ProfilMenuRoute);
  }
}
