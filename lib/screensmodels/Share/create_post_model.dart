import 'dart:io';
import 'package:Gemu/models/post.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/cloud_storage_service.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/services/database_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/utils/image_selector.dart';
import 'package:flutter/foundation.dart';

class CreatePostModel extends BaseModel {
  final DatabaseService _firestoreService = locator<DatabaseService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final ImageSelector _imageSelector = locator<ImageSelector>();
  final CloudStorageService _cloudStorageService =
      locator<CloudStorageService>();

  File _selectedImage;
  File get selectedImage => _selectedImage;

  Future selectImage() async {
    var tempImage = await _imageSelector.selectImage();
    if (tempImage != null) {
      _selectedImage = File(tempImage.path);
      notifyListeners();
    }
  }

  Future addPost(
      {@required String game,
      @required String section,
      @required String content}) async {
    CloudStorageResult storageResult;
    var result;

    storageResult = await _cloudStorageService.uploadImagePost(
        imageToUpload: _selectedImage, title: 'post' + '${currentUser.id}');

    result = await _firestoreService.addPost(Post(
        userId: currentUser.id,
        game: game,
        section: section,
        content: content,
        imageUrl: storageResult.imageUrl,
        imageFileName: storageResult.imageFileName));

    if (result is String) {
      await _dialogService.showDialog(
        title: 'Could not create post',
        description: result,
      );
    } else {
      await _dialogService.showDialog(
        title: 'Post successfully Added',
        description: 'Your post has been created',
      );
    }

    _navigationService.pop();
  }
}
