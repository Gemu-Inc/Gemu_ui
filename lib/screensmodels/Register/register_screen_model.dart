import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/services/database_service.dart';
import 'package:Gemu/locator.dart';
import 'package:flutter/foundation.dart';
import 'package:Gemu/models/game.dart';

class RegisterScreenModel extends BaseModel {
  final AuthService _authService = locator<AuthService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();
  final DatabaseService _firestoreService = locator<DatabaseService>();

  List<Game> _gameList;
  List<Game> get gameList => _gameList;

  void listenToGames() {
    setBusy(true);

    _firestoreService.listenToGamesRealTime().listen((gamesData) {
      List<Game> games = gamesData;
      if (games != null && games.length > 0) {
        _gameList = games;
        notifyListeners();
      }

      setBusy(false);
    });
  }

  Future signUp(
      {@required String pseudo,
      @required String email,
      @required String password}) async {
    setBusy(true);

    var result = await _authService.signUpWithEmail(
        email: email,
        password: password,
        pseudo: pseudo,
        photoURL: null,
        points: '0');

    setBusy(false);

    if (result is bool) {
      if (result) {
        _navigationService.navigateAndRemoveUntil(NavScreenRoute);
      } else {
        await _dialogService.showDialog(
          title: 'Sign Up Failure',
          description: 'General sign up failure. Please try again later',
        );
      }
    } else {
      await _dialogService.showDialog(
        title: 'Sign Up Failure',
        description: result,
      );
    }
  }
}
