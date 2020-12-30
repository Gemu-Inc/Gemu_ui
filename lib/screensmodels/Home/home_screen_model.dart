import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/services/firestore_service.dart';
import 'package:Gemu/services/cloud_storage_service.dart';
import 'package:Gemu/models/post.dart';
import 'package:flutter/foundation.dart';

class HomeScreenModel extends BaseModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final DialogService _dialogService = locator<DialogService>();
  final CloudStorageService _cloudStorageService =
      locator<CloudStorageService>();

  List<Post> _posts;
  List<Post> get posts => _posts;

  void listenToPosts() {
    setBusy(true);

    _firestoreService.listenToPostsRealTime().listen((postsData) {
      List<Post> updatedPosts = postsData;
      if (updatedPosts != null && updatedPosts.length > 0) {
        _posts = updatedPosts;
        notifyListeners();
      }

      setBusy(false);
    });
  }
}
