import 'package:Gemu/services/auth_service.dart';
import 'package:flutter/material.dart';

class ProviderWidget extends InheritedWidget {
  final AuthService auth;
  final db;

  ProviderWidget({Key key, Widget child, this.auth, this.db})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static ProviderWidget of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<ProviderWidget>());
}
