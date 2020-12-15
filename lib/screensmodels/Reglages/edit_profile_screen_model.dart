import 'dart:io';
import 'package:Gemu/locator.dart';
import 'package:Gemu/models/user.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/services/cloud_storage_service.dart';
import 'package:Gemu/utils/image_selector.dart';
import 'package:Gemu/services/firestore_service.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:Gemu/services/auth_service.dart';

class EditProfileScreenModel extends BaseModel {
  final ImageSelector _imageSelector = locator<ImageSelector>();
  final CloudStorageService _cloudStorageService =
      locator<CloudStorageService>();
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();
  final AuthService _authService = locator<AuthService>();

  File _selectedImage;
  File get selectedImage => _selectedImage;

  Future selectImage() async {
    var tempImage = await _imageSelector.selectImage();
    if (tempImage != null) {
      _selectedImage = File(tempImage.path);
      notifyListeners();
    }
  }

  Future addImgProfile({@required String title}) async {
    setBusy(true);
    CloudStorageResult storageResult;
    var currentUser = _authService.currentUser;

    storageResult = await _cloudStorageService.uploadImage(
        imageToUpload: _selectedImage, title: title + currentUser.id);

    var result;

    result = await _firestoreService.updateUserImgProfile(
        storageResult.imageUrl, currentUser.id);

    setBusy(false);

    if (result is String) {
      await _dialogService.showDialog(
        title: 'Cound not change profile image',
        description: result,
      );
    } else {
      await _dialogService.showDialog(
        title: 'Profile image successfully added',
        description: 'Your image has been changed',
      );
    }

    _navigationService.pop();
  }

  Future deleteImgProfile({@required String title}) async {
    var currentUser = _authService.currentUser;
    String imageFileName = title + currentUser.id;

    var storage;

    storage =
        await _cloudStorageService.deleteImage(imageFileName: imageFileName);
    print(storage);

    var result;

    result = await _firestoreService.deleteUserImgProfile(currentUser.id);

    if (result is String) {
      await _dialogService.showDialog(
        title: 'Cound not delete profile image',
        description: result,
      );
    } else {
      await _dialogService.showDialog(
        title: 'Profile image successfully deleted',
        description: 'Your image has been deleted',
      );
    }

    _navigationService.pop();
  }
}
